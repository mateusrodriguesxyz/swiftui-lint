// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MyBuildToolPlugin",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
//        .library(name: "PluginCore", targets: ["PluginCore"]),
        // Products can be used to vend plugins, making them visible to other packages.
        .plugin(
            name: "MyBuildToolPlugin",
            targets: ["MyBuildToolPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.

        .executableTarget(
            name: "PluginExecutable",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "PluginCore")
            ]
        ),
        .testTarget(
            name: "PluginExecutableTests",
            dependencies: ["PluginExecutable"]),
        .target(
            name: "PluginCore",
            dependencies: [
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ]
        ),
        .plugin(
            name: "MyBuildToolPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "PluginExecutable")
            ]
        )
    ]
)
