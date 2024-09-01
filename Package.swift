// swift-tools-version:5.10

import PackageDescription

let package: Package = Package(name: "Snap", platforms: [
        .iOS(.v17),
        .visionOS(.v1)
    ], products: [
        .library(name: "Snap", targets: [
            "Snap"
        ])
    ], targets: [
        .target(name: "Snap")
    ])
