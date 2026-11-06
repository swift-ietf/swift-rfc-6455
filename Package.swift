// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-rfc-6455",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "RFC 6455", targets: ["RFC 6455"]),
        .library(name: "RFC 6455 Standard Library Integration", targets: ["RFC 6455 Standard Library Integration"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-3986.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-standard-library-extensions.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-binary.git", branch: "main", traits: ["Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-formatter.git", branch: "main", traits: ["Radix"]),
    ],
    targets: [
        .target(
            name: "RFC 6455",
            dependencies: [
                .product(name: "RFC 3986", package: "swift-rfc-3986"),
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Formatter", package: "swift-formatter"),
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
        .target(
            name: "RFC 6455 Standard Library Integration",
            dependencies: [
                .target(name: "RFC 6455"),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
        .testTarget(
            name: "RFC 6455 Tests",
            dependencies: [
                .target(name: "RFC 6455")
            ]
        ),
        .testTarget(
            name: "RFC 6455 Standard Library Integration Tests",
            dependencies: [
                .target(name: "RFC 6455"),
                .target(name: "RFC 6455 Standard Library Integration"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
