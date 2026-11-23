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

    /// Deletes the file at the specified URL.
    ///
    /// - Parameter url: The URL of the file to remove.
    /// - Returns: `true` if the deletion succeeds; otherwise, `false`.
    @discardableResult
    nonisolated func delete(at url: URL?) -> Bool {
        guard let url else { return false }

        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }

    /// Deletes a file in the local Documents directory.
    ///
    /// - Parameter filename: The name of the file to delete.
    /// - Returns: `true` if the deletion succeeds; otherwise, `false`.
    @discardableResult
    nonisolated public func deleteLocal(filename: String) -> Bool {
        delete(at: localFileURL(name: filename))
    }

    /// Deletes a file at the specified storage location.
    ///
    /// When deleting from iCloud Drive (`.cloud`), this method safely coordinates
    /// write access using `NSFileCoordinator` with the `.forDeleting` option.
    ///
    /// - Parameters:
    ///   - filename: The name of the file to delete.
    ///   - location: The targeted storage location (`local` or `cloud`).
    /// - Returns: `true` if the deletion succeeds or if a coordination error occurs; otherwise, `false`.
    @discardableResult
    public func delete(filename: String, at location: Location) -> Bool {
        guard let url = fileURL(name: filename, at: location) else { return false }

        switch location {
        case .local:
            return delete(at: url)

        case .cloud:
            var coordinatorError: NSError?
            var result = false
            let coordinator = NSFileCoordinator(filePresenter: nil)

            coordinator.coordinate(
                writingItemAt: url,
                options: .forDeleting,
                error: &coordinatorError
            ) { coordinatedURL in
                result = delete(at: coordinatedURL)
            }

            return coordinatorError == nil ? result : false
        }
    }
}
