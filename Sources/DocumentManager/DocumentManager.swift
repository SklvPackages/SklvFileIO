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

/// An actor that manages file URLs within the app's local Documents directory and iCloud Drive.
public actor DocumentManager {
    private let directoryName = "Documents"

    /// Represents the storage location for a document.
    public enum Location: Sendable {
        /// The local device storage.
        case local
        /// The user's iCloud Drive container.
        case cloud
    }

    /// The URL to the local Documents directory.
    let local: URL?

    /// Initializes a new document manager.
    public init() {
#if targetEnvironment(macCatalyst)
        let base = try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        if #available(iOS 16.0, *) {
            local = base?.appending(path: directoryName, directoryHint: .isDirectory)
        } else {
            local = base?.appendingPathComponent(directoryName, isDirectory: true)
        }

        if let local, !FileManager.default.fileExists(atPath: local.path) {
            try? FileManager.default.createDirectory(at: local, withIntermediateDirectories: true)
        }
#else
        local = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
#endif
    }

    /// Retrieves the directory URL for the specified storage location.
    ///
    /// - Parameter location: The targeted storage location (`local` or `cloud`).
    /// - Returns: The URL to the corresponding directory, or `nil` if the iCloud container is unavailable.
    func directory(for location: Location) -> URL? {
        switch location {
        case .local:
            return local

        case .cloud:
            guard FileManager.default.ubiquityIdentityToken != nil,
                  let container = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
                return nil
            }

            let documents: URL

            if #available(iOS 16.0, *) {
                documents = container.appending(path: directoryName, directoryHint: .isDirectory)
            } else {
                documents = container.appendingPathComponent(directoryName, isDirectory: true)
            }

            if !FileManager.default.fileExists(atPath: documents.path) {
                try? FileManager.default.createDirectory(at: documents, withIntermediateDirectories: true)
            }

            return documents
        }
    }

    /// Appends a filename to a given directory URL.
    ///
    /// - Parameters:
    ///   - filename: The name of the file to append.
    ///   - directory: The base directory URL.
    /// - Returns: The complete file URL, or `nil` if the directory is `nil` or the filename is empty.
    nonisolated func append(_ filename: String, to directory: URL?) -> URL? {
        guard let directory, !filename.isEmpty else { return nil }

        if #available(iOS 16.0, *) {
            return directory.appending(path: filename, directoryHint: .notDirectory)
        } else {
            return directory.appendingPathComponent(filename, isDirectory: false)
        }
    }

    /// Generates a file URL for a specified filename in the local Documents directory.
    ///
    /// - Parameter filename: The name of the file.
    /// - Returns: The complete local file URL, or `nil` if the filename is empty or the directory is unavailable.
    nonisolated public func localFileURL(name filename: String) -> URL? {
        append(filename, to: local)
    }

    /// Generates a file URL for a specified filename at the given storage location.
    ///
    /// - Parameters:
    ///   - filename: The name of the file.
    ///   - location: The targeted storage location.
    /// - Returns: The complete file URL, or `nil` if the storage location is unavailable or the filename is empty.
    func fileURL(name filename: String, at location: Location) -> URL? {
        append(filename, to: directory(for: location))
    }

    /// Forces an iCloud synchronization by writing and immediately deleting a hidden temporary file.
    public func kickSync() {
        let uuid = UUID().uuidString
        let tempFilename = ".\(uuid)"
        let data = Data(uuid.utf8)
        guard write(data, filename: tempFilename, at: .cloud) else { return }
        delete(filename: tempFilename, at: .cloud)
    }
}
