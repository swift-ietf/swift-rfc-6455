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

// RFC_6455.CloseCode.swift
// swift-rfc-6455
//
// RFC 6455 Section 7.4: Status Codes

extension RFC_6455 {
    /// WebSocket Close Status Code
    ///
    /// Status codes indicate the reason for closing the connection.
    ///
    /// ## Defined Codes
    ///
    /// - 1000: Normal closure
    /// - 1001: Going away
    /// - 1002: Protocol error
    /// - 1003: Unsupported data
    /// - 1005: No status received (reserved)
    /// - 1006: Abnormal closure (reserved)
    /// - 1007: Invalid payload data
    /// - 1008: Policy violation
    /// - 1009: Message too big
    /// - 1010: Mandatory extension
    /// - 1011: Internal server error
    /// - 1015: TLS handshake failure (reserved)
    ///
    /// ## Ranges
    ///
    /// - 0-999: Not used
    /// - 1000-2999: Protocol-defined
    /// - 3000-3999: Library/framework use
    /// - 4000-4999: Application use
    public struct CloseCode: RawRepresentable, Sendable, Hashable, Codable, Comparable {
        public let rawValue: UInt16

        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }

        /// Creates a CloseCode WITHOUT validation
        init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        // MARK: - Protocol Codes

        /// Normal closure (1000)
        ///
        /// The connection successfully completed its purpose.
        public static let normalClosure = Self(__unchecked: (), rawValue: 1000)

        /// Going away (1001)
        ///
        /// Endpoint is going away (e.g., server shutdown, browser navigating away).
        public static let goingAway = Self(__unchecked: (), rawValue: 1001)

        /// Protocol error (1002)
        ///
        /// Endpoint received a message that violates the protocol.
        public static let protocolError = Self(__unchecked: (), rawValue: 1002)

        /// Unsupported data (1003)
        ///
        /// Endpoint received data of a type it cannot accept.
        public static let unsupportedData = Self(__unchecked: (), rawValue: 1003)

        /// No status received (1005) - Reserved
        ///
        /// Must not be sent in a close frame. Indicates no status was present.
        public static let noStatusReceived = Self(__unchecked: (), rawValue: 1005)

        /// Abnormal closure (1006) - Reserved
        ///
        /// Must not be sent in a close frame. Indicates connection closed abnormally.
        public static let abnormalClosure = Self(__unchecked: (), rawValue: 1006)

        /// Invalid frame payload data (1007)
        ///
        /// Endpoint received data that was not consistent with the message type
        /// (e.g., non-UTF-8 data in a text message).
        public static let invalidPayloadData = Self(__unchecked: (), rawValue: 1007)

        /// Policy violation (1008)
        ///
        /// Endpoint received a message that violates its policy.
        public static let policyViolation = Self(__unchecked: (), rawValue: 1008)

        /// Message too big (1009)
        ///
        /// Endpoint received a message that is too big to process.
        public static let messageTooLarge = Self(__unchecked: (), rawValue: 1009)

        /// Mandatory extension (1010)
        ///
        /// Client expected server to negotiate one or more extensions.
        public static let mandatoryExtension = Self(__unchecked: (), rawValue: 1010)

        /// Internal server error (1011)
        ///
        /// Server encountered an unexpected condition.
        public static let internalError = Self(__unchecked: (), rawValue: 1011)

        /// TLS handshake failure (1015) - Reserved
        ///
        /// Must not be sent in a close frame. Indicates TLS handshake failed.
        public static let tlsHandshakeFailed = Self(__unchecked: (), rawValue: 1015)

        // MARK: - Validation

        /// Whether this code is valid for use in a close frame
        ///
        /// Reserved codes (1005, 1006, 1015) must not be sent.
        public var isValid: Bool {
            switch rawValue {
            case 1005, 1006, 1015:
                return false
            case 0..<1000:
                return false
            default:
                return true
            }
        }

        /// Whether this is a protocol-defined code
        public var isProtocolDefined: Bool {
            rawValue >= 1000 && rawValue < 3000
        }

        /// Whether this is a library/framework code
        public var isLibraryCode: Bool {
            rawValue >= 3000 && rawValue < 4000
        }

        /// Whether this is an application code
        public var isApplicationCode: Bool {
            rawValue >= 4000 && rawValue < 5000
        }

        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

extension RFC_6455.CloseCode: CustomStringConvertible {
    public var description: String {
        switch rawValue {
        case 1000: return "normal closure"
        case 1001: return "going away"
        case 1002: return "protocol error"
        case 1003: return "unsupported data"
        case 1005: return "no status received"
        case 1006: return "abnormal closure"
        case 1007: return "invalid payload data"
        case 1008: return "policy violation"
        case 1009: return "message too large"
        case 1010: return "mandatory extension"
        case 1011: return "internal error"
        case 1015: return "TLS handshake failed"
        default: return "close code \(rawValue)"
        }
    }
}
