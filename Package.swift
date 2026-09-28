// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Zones",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "ZonesKit", targets: ["ZonesKit"])
    ],
    targets: [
        .target(name: "ZonesKit"),
        .testTarget(name: "ZonesKitTests", dependencies: ["ZonesKit"]),
    ]
)
