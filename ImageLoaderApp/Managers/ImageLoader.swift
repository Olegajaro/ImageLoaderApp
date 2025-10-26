//
//  ImageLoader.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import UIKit

protocol ImageLoaderProtocol: AnyObject {
    func loadImage(from url: URL,
                   completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void)
    func cancelLoad(for url: URL)
    func clearAllCaches()
}

final class ImageLoader: ImageLoaderProtocol {
    private let memoryCache = MemoryCache()
    private let diskCache = DiskCache()
    private let downloader = ImageDownloader()
    
    func loadImage(from url: URL,
                   completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void) {
        if let memoryImage = memoryCache.image(forKey: url.absoluteString) {
            print("DEBUG: from memory")
            completion(.success(memoryImage))
        } else if let diskImage = diskCache.load(for: url) {
            memoryCache.insert(diskImage, forKey: url.absoluteString)
            print("DEBUG: from disk")
            completion(.success(diskImage))
        } else {
            downloader.download(from: url) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let image):
                    self.memoryCache.insert(image, forKey: url.absoluteString)
                    self.diskCache.save(image, for: url)
                case .failure(let failure):
                    print("DEBUG: download image error - \(failure.errorDescription ?? "unknown error")")
                }
                print("DEBUG: from network")
                completion(result)
            }
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
