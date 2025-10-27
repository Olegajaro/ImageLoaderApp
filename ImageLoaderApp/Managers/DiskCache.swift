//
//  DiskCache.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import UIKit
import CryptoKit

protocol DiskCacheProtocol: AnyObject {
    func load(for url: URL) -> UIImage?
    func save(_ image: UIImage, for url: URL)
    func deleteCache()
}

final class DiskCache: DiskCacheProtocol {
    private let fileManager = FileManager.default
    private let ioQueue = DispatchQueue(label: "com.imageLoader.diskCacheQueue", qos: .utility)
    
    private lazy var cacheDirectory: URL = {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = caches.appendingPathComponent("ImageCache", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()
    
    func load(for url: URL) -> UIImage? {
        let fileURL = filePath(for: url)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    func save(_ image: UIImage, for url: URL) {
        ioQueue.async { [weak self] in
            guard let self else { return }
            let fileURL = filePath(for: url)
            guard let data = image.pngData() else { return }
            try? data.write(to: fileURL, options: [.atomic])
        }
    }
    
    func deleteCache() {
        ioQueue.async { [weak self] in
            guard
                let self, fileManager.fileExists(atPath: self.cacheDirectory.path())
            else { return }
            try? fileManager.removeItem(at: self.cacheDirectory)
            createCacheDirectoryIfNeeded()
        }
    }
    
    private func filePath(for url: URL) -> URL {
        let hashedName = sha256(url.absoluteString) + ".png"
        return cacheDirectory.appendingPathComponent(hashedName)
    }
    
    private func sha256(_ string: String) -> String {
        let digest = SHA256.hash(data: Data(string.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func createCacheDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}
