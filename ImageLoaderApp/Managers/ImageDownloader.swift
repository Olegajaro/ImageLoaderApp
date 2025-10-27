//
//  ImageDownloader.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

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

protocol ImageDownloaderProtocol: AnyObject {
    func download(from url: URL,
                  completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void)
    func cancel(for url: URL)
}

final class ImageDownloader: ImageDownloaderProtocol {
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
    /// Determines whether a new download task should be started for the given URL
    /// Implements download deduplication by tracking completion handlers for each URL.
    /// If URL is already being downloaded, adds completion to existing handlers instead of starting new download.
    /// - Parameters:
    ///   - url: The URL for which download is requested
    ///   - completion: Completion handler to be called when download finishes
    /// - Returns: Boolean indicating whether a new download task should be started (true)
    ///            or completion was added to existing download (false)
    func shouldStartNewDownloadTask(
        for url: URL,
        completion: @escaping (Result<UIImage, ImageDownloadError>) -> Void
    ) -> Bool {
        return lock.withLock {
            if var existingCompletions = completions[url] {
                existingCompletions.append(completion)
                completions[url] = existingCompletions
                return false
            } else {
                completions[url] = [completion]
                return true
            }
        }
    }
    
    /// Stores the URLSessionDataTask and starts it immediately
    /// Thread-safely associates the task with the URL and begins network request
    /// - Parameters:
    ///   - task: The URLSessionDataTask to be stored and started
    ///   - url: The URL associated with this task for tracking and management
    func storeAndStartTask(_ task: URLSessionDataTask, for url: URL) {
        lock.withLock {
            runningTasks[url] = task
        }
        task.resume()
    }
    
    /// Processes the download result for a specific URL
    /// Validates the response, extracts completions, and notifies all waiting handlers
    /// - Parameters:
    ///   - url: The URL for which download completed
    ///   - data: Raw image data received from the server
    ///   - response: URLResponse containing HTTP status and headers
    ///   - error: Network error if the download failed
    func handleDownloadResult(url: URL, data: Data?,
                              response: URLResponse?, error: Error?) {
        let allCompletions = extractCompletionsAndCleanup(for: url)
        
        if let badResult = validateDownloadResult(data: data, response: response, error: error) {
            notifyCompletions(allCompletions, with: badResult)
            return
        }
        
        // If we reach here, download was successful
        guard let image = createImage(from: data) else { return }
        notifyCompletions(allCompletions, with: .success(image))
    }
    
    /// Extracts all completion handlers for a URL and cleans up related data
    /// Thread-safely removes the URL from tracking dictionaries
    /// - Parameter url: The URL to extract and clean up
    /// - Returns: Array of completion handlers waiting for this URL's result
    func extractCompletionsAndCleanup(for url: URL) -> [((Result<UIImage, ImageDownloadError>) -> Void)] {
        return lock.withLock {
            let completionsForURL = completions[url] ?? []
            completions[url] = nil
            runningTasks[url] = nil
            return completionsForURL
        }
    }
    
    /// Validates the image download result and returns corresponding Result
    /// Performs sequential checks: network errors, HTTP status code, data presence,
    /// image validity. Returns nil if all checks pass successfully.
    /// - Parameters:
    ///   - data: Data received from the download. Can be nil or empty.
    ///   - response: HTTP response from the server. Used for status code validation.
    ///   - error: Network error if occurred during download.
    /// - Returns: Result with ImageDownloadError if validation fails,
    ///            or nil if data passed all checks and is ready to use.
    func validateDownloadResult(data: Data?,
                                response: URLResponse?,
                                error: Error?) -> Result<UIImage, ImageDownloadError>? {
        if let error {
            return .failure(.networkError(error))
        }
        
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            return .failure(.httpError(statusCode: httpResponse.statusCode))
        }
        
        guard let data else {
            return .failure(.noDataReceived)
        }
        
        guard !data.isEmpty else {
            return .failure(.emptyData)
        }
        
        guard UIImage(data: data) != nil else {
            return .failure(.invalidImageData)
        }
        
        return nil
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
