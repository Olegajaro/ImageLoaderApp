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
    func getImageURLs() -> [URL] {
        let urlStrings = [
            "https://loremflickr.com/800/600/dog?lock=1",
            "https://loremflickr.com/800/600/cat?lock=2",
            "https://loremflickr.com/800/600/nature?lock=3",
            "https://loremflickr.com/1200/800/city?lock=4",
            "https://loremflickr.com/1200/800/beach?lock=5",
            "https://loremflickr.com/1200/800/mountain?lock=6"
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
