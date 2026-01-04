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

// RFC_6455.Frame.Error.swift
// swift-rfc-6455

extension RFC_6455.Frame {
    /// Errors that can occur when working with WebSocket frames
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Control frame must have FIN bit set
        case controlFrameMustBeFinal

        /// Control frame payload exceeds 125 bytes
        case controlPayloadTooLarge(_ size: Int)

        /// Frame is truncated
        case truncated(_ size: Int)

        /// Reserved opcode used
        case reservedOpcode(_ opcode: UInt8)

        /// Invalid payload length encoding
        case invalidPayloadLength
    }
}

extension RFC_6455.Frame.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .controlFrameMustBeFinal:
            return "Control frames must have FIN bit set"
        case .controlPayloadTooLarge(let size):
            return "Control frame payload too large: \(size) bytes (max 125)"
        case .truncated(let size):
            return "Frame truncated: \(size) bytes"
        case .reservedOpcode(let opcode):
            return "Reserved opcode: 0x\(String(opcode, radix: 16))"
        case .invalidPayloadLength:
            return "Invalid payload length encoding"
        }
    }
}
