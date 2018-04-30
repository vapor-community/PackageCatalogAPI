// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "PackageCatalogAPI",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: "3.0.0-rc.2.8.1"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
