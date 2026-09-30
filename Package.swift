// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PlatformSnapshot",
    platforms: [
        .iOS("17.4"),
        .macOS("14.4"),
        .visionOS("1.1"),
    ],
    products: [
        .library(name: "PlatformSnapshot", targets: ["PlatformSnapshot"])
    ],
    targets: [
        .target(name: "PlatformSnapshot"),
        .testTarget(name: "PlatformSnapshotTests", dependencies: ["PlatformSnapshot"]),
    ]
)
