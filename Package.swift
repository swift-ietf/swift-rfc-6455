// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let rfc6455: Self = "RFC 6455"
}

extension Target.Dependency {
    static var rfc6455: Self { .target(name: .rfc6455) }
    static var rfc3986: Self { .product(name: "RFC 3986", package: "swift-rfc-3986") }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var incits41986: Self { .product(name: "ASCII Primitives", package: "swift-ascii-primitives") }
}

let package = Package(
    name: "swift-rfc-6455",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "RFC 6455", targets: ["RFC 6455"])
    ],
    dependencies: [
        .package(path: "../swift-rfc-3986"),
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-ascii-primitives")
    ],
    targets: [
        .target(
            name: "RFC 6455",
            dependencies: [
                .rfc3986,
                .standards,
                .incits41986
            ]
        ),
        .testTarget(
            name: "RFC 6455 Tests",
            dependencies: [
                "RFC 6455",
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
