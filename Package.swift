// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftUILint",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .plugin(
            name: "SwiftUILintPlugin",
            targets: ["SwiftUILintPlugin"]
        ),
        .plugin(
            name: "SwiftUILintReleasePlugin",
            targets: ["SwiftUILintReleasePlugin"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "509.0.2"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftUILintExecutable",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ]
        ),
        .binaryTarget(
            name: "SwiftUILintBinary",
            path: "executable.artifactbundle.zip"
        ),
        .testTarget(
            name: "PluginExecutableTests",
            dependencies: ["SwiftUILintExecutable"],
            resources: [
                .process("Resources/")
            ]
        ),
        .plugin(
            name: "SwiftUILintPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "SwiftUILintExecutable")
            ]
        ),
        .plugin(
            name: "SwiftUILintReleasePlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "SwiftUILintBinary")
            ]
        )
    ]
)
