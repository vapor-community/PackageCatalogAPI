// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "PackageCatalog",
    dependencies: [
        // 💧 A server-side Swift web framework. 
        .package(url: "https://github.com/vapor/vapor.git", .branch("beta")),
        .package(url: "https://github.com/vapor/fluent.git", .branch("beta")),
        .package(url: "https://github.com/vapor/mysql-driver.git", .branch("beta"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Fluent", "FluentMySQL"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

