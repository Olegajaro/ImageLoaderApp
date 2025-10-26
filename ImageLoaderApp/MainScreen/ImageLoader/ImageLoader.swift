//
//  ImageLoader.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import UIKit

final class ImageLoader {
    private let memoryCache = MemoryCache()
    private let diskCache = DiskCache()
    private let downloader = ImageDownloader()
        
    func loadImage(from url: URL,
                   completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void) {
        // memory
        if let memoryImage = memoryCache.image(forKey: url.absoluteString) {
            print("DEBUG: from memory")
            completion(.success(memoryImage))
            return
        }
        
        // disk
        if let diskImage = diskCache.load(for: url) {
            memoryCache.insert(diskImage, forKey: url.absoluteString)
            print("DEBUG: from disk")
            completion(.success(diskImage))
            return
        }
        
        // downloading from network
        downloader.download(from: url) { [weak self] result in
            guard let self else { return }
            if case .success(let image) = result {
                self.memoryCache.insert(image, forKey: url.absoluteString)
                self.diskCache.save(image, for: url)
            }
            print("DEBUG: from network")
            completion(result)
        }
    }
    
    func cancelLoad(for url: URL) {
        downloader.cancel(for: url)
    }
    
    func clearAllCaches() {
        memoryCache.removeAllObjects()
        diskCache.deleteCache()
    }
}
