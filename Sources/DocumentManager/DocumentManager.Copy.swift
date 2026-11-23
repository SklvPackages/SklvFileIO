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

    /// Copies a file from a source URL to a destination URL.
    ///
    /// - Parameters:
    ///   - source: The URL of the file to copy.
    ///   - destination: The URL where the file should be copied.
    /// - Returns: `true` if the file was successfully copied; otherwise, `false`.
    nonisolated func copy(from source: URL?, to destination: URL?) -> Bool {
        guard let source, let destination else { return false }

        do {
            try FileManager.default.copyItem(at: source, to: destination)
            return true
        } catch {
            return false
        }
    }

    /// Copies a file from one storage location to another.
    ///
    /// This method safely coordinates read access at the source and write access at the
    /// destination using `NSFileCoordinator`.
    ///
    /// - Parameters:
    ///   - filename: The name of the file to copy.
    ///   - source: The storage location to copy from (`local` or `cloud`).
    ///   - destination: The storage location to copy to (`local` or `cloud`).
    /// - Returns: `true` if the copy operation succeeds; otherwise, `false`.
    @discardableResult
    public func copy(filename: String, from source: Location, to destination: Location) -> Bool {
        guard source != destination,
              let sourceURL = fileURL(name: filename, at: source),
              let destinationURL = fileURL(name: filename, at: destination) else {
            return false
        }

        var coordinatorError: NSError?
        var result = false
        let coordinator = NSFileCoordinator(filePresenter: nil)

        coordinator.coordinate(
            readingItemAt: sourceURL,
            options: [],
            writingItemAt: destinationURL,
            options: [],
            error: &coordinatorError
        ) { coordinatedSource, coordinatedDestination in
            result = copy(from: coordinatedSource, to: coordinatedDestination)
        }

        return coordinatorError == nil ? result : false
    }
}
