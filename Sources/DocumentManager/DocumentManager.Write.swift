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

    /// Writes data to a specified URL.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - url: The destination file URL.
    /// - Returns: `true` if the write operation succeeds; otherwise, `false`.
    nonisolated func write(_ data: Data, to url: URL?) -> Bool {
        guard let url else { return false }

        do {
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    /// Writes data to a file in the local Documents directory.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - filename: The name of the target file.
    /// - Returns: `true` if the write operation succeeds; otherwise, `false`.
    @discardableResult
    nonisolated public func writeLocal(_ data: Data, filename: String) -> Bool {
        write(data, to: localFileURL(name: filename))
    }

    /// Writes data to a file at the specified storage location.
    ///
    /// - Parameters:
    ///   - data: The data to write.
    ///   - filename: The name of the target file.
    ///   - location: The targeted storage location (`local` or `cloud`).
    /// - Returns: `true` if the write operation succeeds; otherwise, `false`.
    @discardableResult
    public func write(_ data: Data, filename: String, at location: Location) -> Bool {
        guard let url = fileURL(name: filename, at: location) else { return false }

        switch location {
        case .local:
            return write(data, to: url)

        case .cloud:
            var coordinatorError: NSError?
            var result = false
            let coordinator = NSFileCoordinator(filePresenter: nil)

            coordinator.coordinate(
                writingItemAt: url,
                options: .forReplacing,
                error: &coordinatorError
            ) { coordinatedURL in
                result = write(data, to: coordinatedURL)
            }

            return coordinatorError == nil ? result : false
        }
    }
}
