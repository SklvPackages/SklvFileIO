//
//  Copyright (c) 2026 Andrew Sokolov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

extension DocumentManager {

    /// Reads data from a specified URL.
    ///
    /// - Parameter url: The source file URL.
    /// - Returns: The file's `Data`, or `nil` if the read operation fails or the URL is `nil`.
    nonisolated func read(from url: URL?) -> Data? {
        guard let url else { return nil }
        return try? Data(contentsOf: url)
    }

    /// Reads data from a file in the local Documents directory.
    ///
    /// - Parameter filename: The name of the file to read.
    /// - Returns: The file's `Data`, or `nil` if the file cannot be read or found.
    nonisolated public func readLocal(filename: String) -> Data? {
        read(from: localFileURL(name: filename))
    }

    /// Reads data from a file at the specified storage location.
    ///
    /// When reading from iCloud Drive (`.cloud`), this method safely coordinates
    /// read access using `NSFileCoordinator`.
    ///
    /// - Parameters:
    ///   - filename: The name of the file to read.
    ///   - location: The targeted storage location (`local` or `cloud`).
    /// - Returns: The file's `Data`, or `nil` if the read operation fails or a coordination error occurs.
    public func read(filename: String, at location: Location) -> Data? {
        guard let url = fileURL(name: filename, at: location) else { return nil }

        switch location {
        case .local:
            return read(from: url)

        case .cloud:
            var coordinatorError: NSError?
            var result: Data?
            let coordinator = NSFileCoordinator(filePresenter: nil)

            coordinator.coordinate(
                readingItemAt: url,
                options: [],
                error: &coordinatorError
            ) { coordinatedURL in
                result = read(from: coordinatedURL)
            }

            return coordinatorError == nil ? result : nil
        }
    }
}
