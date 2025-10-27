//
//  MemoryCache.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import UIKit

protocol MemoryCacheProtocol: AnyObject {
    func image(forKey key: String) -> UIImage?
    func insert(_ image: UIImage, forKey key: String)
    func removeAllObjects()
}

final class MemoryCache: MemoryCacheProtocol {
    private let cache = NSCache<NSString, UIImage>()
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func insert(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func removeAllObjects() {
        cache.removeAllObjects()
    }
}
