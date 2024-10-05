// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CollectionComposer",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "CollectionComposer",
            targets: ["CollectionComposer"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CollectionComposer",
            dependencies: [],
            path: "Sources/CollectionComposer"
        ),
        .testTarget(
            name: "CollectionComposerTests",
            dependencies: [],
            path: "Tests/CollectionComposerTests"
        )
    ]
)
