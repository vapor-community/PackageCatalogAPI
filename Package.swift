// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "PackageCatalogAPI",
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", "3.0.0-beta.3"..<"3.0.0-beta.4"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", "1.0.0-beta.2"..<"1.0.0-beta.3")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

