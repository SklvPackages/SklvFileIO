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

    /// Retrieves the names of all files within a specified directory URL.
    ///
    /// - Parameter url: The directory URL to inspect.
    /// - Returns: An array of filenames, or an empty array if the directory cannot be read or is `nil`.
    nonisolated func files(at url: URL?) -> [String] {
        guard let url,
              let urls = try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: nil,
                options: []
              ) else {
            return []
        }

        return urls.map(\.lastPathComponent)
    }

    /// Retrieves the names of all files stored in the local Documents directory.
    ///
    /// - Returns: An array containing the names of the local files.
    nonisolated public func localFiles() -> [String] {
        files(at: local)
    }

    /// Retrieves the names of all files stored at the specified storage location.
    ///
    /// When accessing iCloud Drive (`.cloud`), this method safely coordinates
    /// read access using `NSFileCoordinator`.
    ///
    /// - Parameter location: The targeted storage location (`local` or `cloud`).
    /// - Returns: An array of filenames, or an empty array if the directory cannot be accessed or a coordination error occurs.
    public func files(at location: Location) -> [String] {
        guard let url = directory(for: location) else { return [] }

        switch location {
        case .local:
            return files(at: url)

        case .cloud:
            var coordinatorError: NSError?
            var result: [String] = []
            let coordinator = NSFileCoordinator(filePresenter: nil)

            coordinator.coordinate(
                readingItemAt: url,
                options: [],
                error: &coordinatorError
            ) { coordinatedURL in
                result = files(at: coordinatedURL)
            }

            return coordinatorError == nil ? result : []
        }
    }
}
