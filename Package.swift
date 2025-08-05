// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MacBoard",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MacBoard", targets: ["MacBoard"])
    ],
    dependencies: [
        // External dependencies for enhanced functionality
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.16.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin", from: "5.0.0"),
        .package(url: "https://github.com/sindresorhus/Defaults", from: "7.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "MacBoard",
            dependencies: [
                "KeyboardShortcuts",
                "LaunchAtLogin", 
                "Defaults"
            ],
            path: "MacBoard/MacBoard"
        )
    ]
)