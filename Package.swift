// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Pier",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "Pier",
            path: "Sources/Pier"
        )
    ]
)
