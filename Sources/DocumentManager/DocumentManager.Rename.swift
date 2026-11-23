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

    /// Renames or moves a file from a source URL to a destination URL.
    ///
    /// - Parameters:
    ///   - source: The current URL of the file.
    ///   - destination: The new URL for the file.
    /// - Returns: `true` if the file was successfully renamed; otherwise, `false`.
    @discardableResult
    nonisolated func rename(from source: URL?, to destination: URL?) -> Bool {
        guard let source, let destination, source != destination else { return false }

        do {
            try FileManager.default.moveItem(at: source, to: destination)
            return true
        } catch {
            return false
        }
    }

    /// Renames a file in the local Documents directory.
    ///
    /// - Parameters:
    ///   - filename: The current name of the file.
    ///   - newFilename: The new name for the file.
    /// - Returns: `true` if the rename operation succeeds; otherwise, `false`.
    @discardableResult
    nonisolated public func renameLocal(filename: String, to newFilename: String) -> Bool {
        rename(
            from: localFileURL(name: filename),
            to: localFileURL(name: newFilename)
        )
    }

    /// Renames a file within the specified storage location.
    ///
    /// When renaming in iCloud Drive (`.cloud`), this method safely coordinates
    /// write access using `NSFileCoordinator` with the `.forMoving` option.
    ///
    /// - Parameters:
    ///   - filename: The current name of the file.
    ///   - newFilename: The new name for the file.
    ///   - location: The targeted storage location (`local` or `cloud`).
    /// - Returns: `true` if the rename operation succeeds; otherwise, `false`.
    @discardableResult
    public func rename(filename: String, to newFilename: String, at location: Location) -> Bool {
        guard filename != newFilename,
              let sourceURL = fileURL(name: filename, at: location),
              let destinationURL = fileURL(name: newFilename, at: location) else {
            return false
        }

        switch location {
        case .local:
            return rename(from: sourceURL, to: destinationURL)

        case .cloud:
            var coordinatorError: NSError?
            var result = false
            let coordinator = NSFileCoordinator(filePresenter: nil)

            coordinator.coordinate(
                writingItemAt: sourceURL,
                options: .forMoving,
                writingItemAt: destinationURL,
                options: [],
                error: &coordinatorError
            ) { coordinatedSource, coordinatedDestination in
                result = rename(from: coordinatedSource, to: coordinatedDestination)
            }

            return coordinatorError == nil ? result : false
        }
    }
}
