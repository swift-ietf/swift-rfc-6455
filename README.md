# swift-rfc-6455

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The WebSocket framing and opening-handshake protocol of RFC 6455.

## Standard Reference

- **RFC**: 6455
- **Title**: The WebSocket Protocol

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-6455.git", from: "0.0.1")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 6455", package: "swift-rfc-6455")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
