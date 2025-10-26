//
//  ImageDownloader.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import Foundation
import UIKit

enum ImageDownloadError: LocalizedError {
    case networkError(Error)
    case httpError(statusCode: Int)
    case noDataReceived
    case emptyData
    case invalidImageData
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let statusCode):
            return "Server error: HTTP \(statusCode)"
        case .noDataReceived:
            return "No image data received"
        case .emptyData:
            return "Received empty data"
        case .invalidImageData:
            return "Unable to create image from received data"
        case .invalidURL:
            return "Invalid URL address"
        }
    }
}

final class ImageDownloader {
    private var runningTasks: [URL: URLSessionDataTask] = [:]
    private var completions: [URL: [(Result<UIImage, ImageDownloadError>) -> Void]] = [:]
    private let lock = NSLock()
    
    func download(from url: URL,
                  completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void) {
        guard shouldStartNewDownloadTask(for: url, completion: completion) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.handleDownloadResult(url: url, data: data, response: response, error: error)
        }
        
        storeAndStartTask(task, for: url)
    }
    
    func cancel(for url: URL) {
        lock.withLock {
            runningTasks[url]?.cancel()
            runningTasks[url] = nil
            completions[url] = nil
        }
    }
}

// MARK: - Private Helper Methods
private extension ImageDownloader {
    func shouldStartNewDownloadTask(
        for url: URL,
        completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void
    ) -> Bool {
        return lock.withLock {
            if var existingCompletions = completions[url] {
                // URL is already downloading, add completion to existing ones
                existingCompletions.append(completion)
                completions[url] = existingCompletions
                return false
            } else {
                // First request for this URL, create new completions list
                completions[url] = [completion]
                return true
            }
        }
    }
    
    func storeAndStartTask(_ task: URLSessionDataTask, for url: URL) {
        lock.withLock {
            runningTasks[url] = task
        }
        task.resume()
    }
    
    func handleDownloadResult(url: URL, data: Data?,
                              response: URLResponse?, error: Error?) {
        let allCompletions = extractCompletionsAndCleanup(for: url)
        
        if let result = validateDownloadResult(data: data, response: response, error: error) {
            notifyCompletions(allCompletions, with: result)
            return
        }
        
        // If we reach here, download was successful
        guard let image = createImage(from: data) else { return }
        notifyCompletions(allCompletions, with: .success(image))
    }
    
    func extractCompletionsAndCleanup(for url: URL) -> [((Result<UIImage, ImageDownloadError>) -> Void)] {
        return lock.withLock {
            let completionsForURL = completions[url] ?? []
            completions[url] = nil
            runningTasks[url] = nil
            return completionsForURL
        }
    }
    
    func validateDownloadResult(data: Data?,
                                response: URLResponse?,
                                error: Error?) -> Result<UIImage, ImageDownloadError>? {
        // Check for network error
        if let error = error {
            return .failure(.networkError(error))
        }
        
        // Check HTTP status code
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            return .failure(.httpError(statusCode: httpResponse.statusCode))
        }
        
        // Check if data exists
        guard let data = data else {
            return .failure(.noDataReceived)
        }
        
        // Check if data is not empty
        guard !data.isEmpty else {
            return .failure(.emptyData)
        }
        
        // Check if we can create image from data
        guard UIImage(data: data) != nil else {
            return .failure(.invalidImageData)
        }
        
        return nil // No error
    }
    
    func createImage(from data: Data?) -> UIImage? {
        guard let data else { return nil }
        return UIImage(data: data)
    }
    
    func notifyCompletions(_ completions: [((Result<UIImage, ImageDownloadError>) -> Void)],
                           with result: Result<UIImage, ImageDownloadError>) {
        DispatchQueue.main.async {
            completions.forEach { $0(result) }
        }
    }
}
