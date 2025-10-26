//
//  ImageURLProvider.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import Foundation

final class ImageURLProvider {
    static func getImageURLs() -> [URL] {
        let urlStrings = [
            "https://picsum.photos/id/1015/1200/900",
            "https://picsum.photos/id/1025/1200/900",
            "https://picsum.photos/id/1035/1200/900",
            "https://picsum.photos/id/1045/1200/900",
            "https://picsum.photos/id/1055/1200/900",
            "https://picsum.photos/id/1065/1200/900"
        ]
        
        let urls = urlStrings.compactMap { URL(string: $0) }
        
        if urls.count != urlStrings.count {
            print("⚠️ Some image URLs are invalid")
        }
        
        return urls
    }
    
    static func getSimpleImageURLs() -> [URL] {
        let urlStrings = [
            "https://placehold.co/1200x900/1E90FF/FFFFFF/png?text=Ocean+Blue",
            "https://placehold.co/1200x900/FF8C00/FFFFFF/png?text=Sunset+Orange",
            "https://placehold.co/1200x900/32CD32/FFFFFF/png?text=Fresh+Green",
            "https://placehold.co/1200x900/8A2BE2/FFFFFF/png?text=Purple+Vibe",
            "https://placehold.co/1200x900/DC143C/FFFFFF/png?text=Crimson+Red",
            "https://placehold.co/1200x900/2F4F4F/FFFFFF/png?text=Dark+Slate"
        ]
        
        let urls = urlStrings.compactMap { URL(string: $0) }
        
        if urls.count != urlStrings.count {
            print("⚠️ Some image URLs are invalid")
        }
        
        return urls
    }
}
