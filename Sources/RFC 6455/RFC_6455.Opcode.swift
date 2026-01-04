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

// RFC_6455.Opcode.swift
// swift-rfc-6455
//
// RFC 6455 Section 5.2: Base Framing Protocol - Opcode

extension RFC_6455 {
    /// WebSocket Frame Opcode
    ///
    /// Defines the interpretation of the payload data.
    ///
    /// ## Data Frames
    ///
    /// - continuation (0x0): Continuation frame
    /// - text (0x1): Text frame (UTF-8)
    /// - binary (0x2): Binary frame
    ///
    /// ## Control Frames
    ///
    /// - close (0x8): Connection close
    /// - ping (0x9): Ping
    /// - pong (0xA): Pong
    public struct Opcode: RawRepresentable, Sendable, Hashable, Codable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            // Opcodes are 4 bits
            self.rawValue = rawValue & 0x0F
        }

        /// Creates an Opcode WITHOUT validation
        init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        // MARK: - Data Frames

        /// Continuation frame (0x0)
        ///
        /// Continues a fragmented message.
        public static let continuation = Self(__unchecked: (), rawValue: 0x0)

        /// Text frame (0x1)
        ///
        /// Payload is UTF-8 encoded text.
        public static let text = Self(__unchecked: (), rawValue: 0x1)

        /// Binary frame (0x2)
        ///
        /// Payload is arbitrary binary data.
        public static let binary = Self(__unchecked: (), rawValue: 0x2)

        // Values 0x3-0x7 are reserved for further non-control frames

        // MARK: - Control Frames

        /// Connection close (0x8)
        public static let close = Self(__unchecked: (), rawValue: 0x8)

        /// Ping (0x9)
        public static let ping = Self(__unchecked: (), rawValue: 0x9)

        /// Pong (0xA)
        public static let pong = Self(__unchecked: (), rawValue: 0xA)

        // Values 0xB-0xF are reserved for further control frames

        // MARK: - Classification

        /// Whether this is a control frame
        ///
        /// Control frames have opcodes 0x8 and higher.
        public var isControl: Bool {
            rawValue >= 0x8
        }

        /// Whether this is a data frame
        public var isData: Bool {
            rawValue < 0x8
        }

        /// Whether this opcode is reserved
        public var isReserved: Bool {
            switch rawValue {
            case 0x3...0x7, 0xB...0xF:
                return true
            default:
                return false
            }
        }
    }
}

extension RFC_6455.Opcode: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 0x0: return "continuation"
        case 0x1: return "text"
        case 0x2: return "binary"
        case 0x8: return "close"
        case 0x9: return "ping"
        case 0xA: return "pong"
        default: return "opcode(0x\(String(rawValue, radix: 16)))"
        }
    }
}
