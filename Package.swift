// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let rfc6455: Self = "RFC 6455"
}

extension Target.Dependency {
    static var rfc6455: Self { .target(name: .rfc6455) }
    static var rfc3986: Self { .product(name: "RFC 3986", package: "swift-rfc-3986") }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var incits41986: Self { .product(name: "ASCII", package: "swift-ascii") }
    static var binary: Self { .product(name: "Binary", package: "swift-binary") }
    static var bytePrimitivesSLI: Self { .product(name: "Byte", package: "swift-byte") }
    static var radixFormat: Self { .product(name: "Formatter", package: "swift-formatter") }
}

let package = Package(
    name: "swift-rfc-6455",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27)
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
        .package(url: "https://github.com/swift-atoms/swift-formatter.git", branch: "main", traits: ["Radix"])
    ],
    targets: [
        .target(
            name: "RFC 6455",
            dependencies: [
                .rfc3986,
                .standards,
                .incits41986,
                .radixFormat,
                .binary,
                .bytePrimitivesSLI
            ]
        ),
        .target(
            name: "RFC 6455 Standard Library Integration",
            dependencies: [
                .rfc6455,
                .bytePrimitivesSLI,
            ]
        ),
        .testTarget(
            name: "RFC 6455 Tests",
            dependencies: [
                "RFC 6455",
            ]
        ),
        .testTarget(
            name: "RFC 6455 Standard Library Integration Tests",
            dependencies: [
                "RFC 6455",
                "RFC 6455 Standard Library Integration",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

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
