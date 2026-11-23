# SklvFileIO

[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS_15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

A lightweight, thread-safe file manager for Swift 6.3. `SklvFileIO` follows the KISS and DRY principles, hiding boilerplate URL resolutions and `NSFileCoordinator` setups. It seamlessly handles both local sandbox storage and iCloud Drive synchronization out of the box.

## Features

- 🚀 **Actor-Based Concurrency:** `DocumentManager` is an actor. All iCloud operations are safely wrapped in `NSFileCoordinator`, eliminating data races.
- ☁️ **iCloud Ready:** Automatically resolves ubiquitous containers and forces synchronization on demand.
- 🛠 **Clean API:** Forget URL manipulation. Work directly with straightforward `Location` enums (`.local` or `.cloud`) and string filenames.

## Requirements

- **iOS** 15.0+
- **Xcode** 26.0+
- **Swift** 6.3+

## Installation

### Swift Package Manager

1. Inside Xcode, navigate to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/SklvPackages/SklvFileIO.git`
3. Define the dependency rules to **Up to Next Major** starting with `1.0.0`.

## Usage

### 1. Initialization

```swift
import SklvFileIO

let manager = DocumentManager()
```

### 2. Writing and Reading Data

```swift
let data = Data("payload".utf8)

manager.writeLocal(data, filename: "data.bin")
await manager.write(data, filename: "data.bin", at: .cloud)

let localData = manager.readLocal(filename: "data.bin")
let cloudData = await manager.read(filename: "data.bin", at: .cloud)
```

### 3. File Management (Copy & Delete)

```swift
await manager.copy(filename: "data.bin", from: .local, to: .cloud)

manager.deleteLocal(filename: "data.bin")
await manager.delete(filename: "data.bin", at: .cloud)
```

### 4. Exploring Directories

```swift
let localFiles = manager.localFiles()
let cloudFiles = await manager.files(at: .cloud)
```

### 5. Forcing iCloud Sync

```swift
await manager.kickSync()
```

## License

`SklvFileIO` is released under the MIT license. See [LICENSE](LICENSE) for details.
