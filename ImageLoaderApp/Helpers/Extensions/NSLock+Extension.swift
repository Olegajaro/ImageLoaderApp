//
//  NSLock+Extension.swift
//  ImageLoaderApp
//
//  Created by Олег Федоров on 26.10.2025.
//

import Foundation

extension NSLock {
    @discardableResult
    func withLock<T>(_ block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}
