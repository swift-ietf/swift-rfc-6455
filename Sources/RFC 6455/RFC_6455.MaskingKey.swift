// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// RFC_6455.MaskingKey.swift
// swift-rfc-6455
//
// RFC 6455 Section 5.3: Client-to-Server Masking

import Radix_Format_Primitives

extension RFC_6455 {
    /// 32-bit Masking Key
    ///
    /// Used to mask frame payloads from client to server.
    ///
    /// ## Masking Algorithm
    ///
    /// Per RFC 6455 Section 5.3:
    /// ```
    /// j = i MOD 4
    /// transformed-octet-i = original-octet-i XOR masking-key-octet-j
    /// ```
    ///
    /// ## Security Note
    ///
    /// The masking key must be unpredictable for each frame to prevent
    /// cache poisoning attacks. Use `random()` for new keys.
    public struct MaskingKey: Sendable {
        /// The four bytes of the masking key
        public let bytes: (UInt8, UInt8, UInt8, UInt8)

        /// Creates a masking key from four bytes
        public init(_ b0: UInt8, _ b1: UInt8, _ b2: UInt8, _ b3: UInt8) {
            self.bytes = (b0, b1, b2, b3)
        }

        /// Creates a masking key from an array of exactly 4 bytes
        public init?(bytes: [UInt8]) {
            guard bytes.count == 4 else { return nil }
            self.bytes = (bytes[0], bytes[1], bytes[2], bytes[3])
        }

        /// Creates a masking key from a 32-bit value
        public init(value: UInt32) {
            self.bytes = (
                UInt8((value >> 24) & 0xFF),
                UInt8((value >> 16) & 0xFF),
                UInt8((value >> 8) & 0xFF),
                UInt8(value & 0xFF)
            )
        }

        /// Returns the key byte at the given index (0-3)
        public subscript(index: Int) -> UInt8 {
            switch index % 4 {
            case 0: return bytes.0
            case 1: return bytes.1
            case 2: return bytes.2
            case 3: return bytes.3
            default: fatalError("Invalid index")
            }
        }

        /// Applies the mask to data in-place
        ///
        /// XORs each byte with the corresponding mask byte.
        /// This operation is its own inverse.
        ///
        /// - Parameter data: The data to mask/unmask
        public func apply(to data: inout [UInt8]) {
            for i in data.indices {
                data[i] ^= self[i]
            }
        }

        /// Returns masked data
        ///
        /// - Parameter data: The data to mask
        /// - Returns: The masked data
        public func applying(to data: [UInt8]) -> [UInt8] {
            var result = data
            apply(to: &result)
            return result
        }

        /// Converts to array of bytes
        public var array: [UInt8] {
            [bytes.0, bytes.1, bytes.2, bytes.3]
        }
    }
}

// MARK: - Equatable

extension RFC_6455.MaskingKey: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.bytes.0 == rhs.bytes.0 && lhs.bytes.1 == rhs.bytes.1 && lhs.bytes.2 == rhs.bytes.2 && lhs.bytes.3 == rhs.bytes.3
    }
}

// MARK: - Hashable

extension RFC_6455.MaskingKey: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(bytes.0)
        hasher.combine(bytes.1)
        hasher.combine(bytes.2)
        hasher.combine(bytes.3)
    }
}

// MARK: - Codable

extension RFC_6455.MaskingKey: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(UInt32.self)
        self.init(value: value)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let value = (UInt32(bytes.0) << 24) | (UInt32(bytes.1) << 16) | (UInt32(bytes.2) << 8) | UInt32(bytes.3)
        try container.encode(value)
    }
}

// MARK: - CustomStringConvertible

extension RFC_6455.MaskingKey: CustomStringConvertible {
    public var description: String {
        bytes.0.formatted(Radix.Format.hex.zeroPadded(width: 2)) + bytes.1.formatted(Radix.Format.hex.zeroPadded(width: 2)) + bytes.2.formatted(Radix.Format.hex.zeroPadded(width: 2))
            + bytes.3.formatted(Radix.Format.hex.zeroPadded(width: 2))
    }
}
