// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ChatClientKit",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "ChatClientKit", targets: ["ChatClientKit"]),
    ],
    targets: [
        .target(
            name: "ChatClientKit",
            dependencies: [
                "ServerEvent",
            ],
        ),
        .target(name: "ServerEvent"),
    ],
)
