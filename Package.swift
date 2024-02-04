// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MyBuildToolPlugin",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .plugin(
            name: "MyBuildToolPlugin",
            targets: ["MyBuildToolPlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.0.2"),
    ],
    targets: [
        .executableTarget(
            name: "PluginExecutable",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "PluginCore"),
            ]
        ),
        .testTarget(
            name: "PluginExecutableTests",
            dependencies: ["PluginExecutable"],
            resources: [
                .process("Resources/")
            ]
        ),
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
