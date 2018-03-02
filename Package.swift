// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "PackageCatalogAPI",
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0-rc")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

