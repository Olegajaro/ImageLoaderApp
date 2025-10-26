//
//  ImageURLProvider.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import Foundation

protocol ImageURLProviderProtocol {
    func getImageURLs() -> [URL]
    func getSimpleImageURLs() -> [URL]
}

final class ImageURLProvider: ImageURLProviderProtocol {
    // blocked in RF
    func getImageURLs() -> [URL] {
        let urlStrings = [
            "https://picsum.photos/id/1015/800/600",
            "https://picsum.photos/id/1025/800/600",
            "https://picsum.photos/id/1035/800/600",
            "https://picsum.photos/id/1045/800/600",
            "https://picsum.photos/id/1055/800/600",
            "https://picsum.photos/id/1065/800/600"
        ]
        
        let urls = urlStrings.compactMap { URL(string: $0) }
        
        if urls.count != urlStrings.count {
            print("⚠️ Some image URLs are invalid")
        }
        
        return urls
    }
    
    func getSimpleImageURLs() -> [URL] {
        let urlStrings = [
            "https://placehold.co/1980x1120/1E90FF/FFFFFF/png?text=Ocean+Blue",
            "https://placehold.co/1980x1120/FF8C00/FFFFFF/png?text=Sunset+Orange",
            "https://placehold.co/1980x1120/32CD32/FFFFFF/png?text=Fresh+Green",
            "https://placehold.co/1980x1120/8A2BE2/FFFFFF/png?text=Purple+Vibe",
            "https://placehold.co/1980x1120/DC143C/FFFFFF/png?text=Crimson+Red",
            "https://placehold.co/1980x1120/2F4F4F/FFFFFF/png?text=Dark+Slate"
        ]
        
        let urls = urlStrings.compactMap { URL(string: $0) }
        
        if urls.count != urlStrings.count {
            print("⚠️ Some image URLs are invalid")
        }
        
        return urls
    }
}
