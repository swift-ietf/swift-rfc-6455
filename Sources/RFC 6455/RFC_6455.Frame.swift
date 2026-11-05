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

// RFC_6455.Frame.swift
// swift-rfc-6455
//
// RFC 6455 Section 5.2: Base Framing Protocol

public import Binary
public import Byte

extension RFC_6455 {
    /// WebSocket Frame
    ///
    /// Represents a single WebSocket data frame.
    ///
    /// ## Wire Format
    ///
    /// ```
    ///  0                   1                   2                   3
    ///  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    /// +-+-+-+-+-------+-+-------------+-------------------------------+
    /// |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
    /// |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
    /// |N|V|V|V|       |S|             |   (if payload len==126/127)   |
    /// | |1|2|3|       |K|             |                               |
    /// +-+-+-+-+-------+-+-------------+-------------------------------+
    /// |     Extended payload length continued, if payload len == 127  |
    /// +-------------------------------+-------------------------------+
    /// |                               |Masking-key, if MASK set to 1  |
    /// +-------------------------------+-------------------------------+
    /// | Masking-key (continued)       |          Payload Data         |
    /// +-------------------------------+-------------------------------+
    /// |                     Payload Data continued ...                |
    /// +---------------------------------------------------------------+
    /// ```
    public struct Frame: Sendable, Hashable {
        /// FIN bit - indicates final fragment
        public let fin: Bool

        /// RSV1 bit - reserved (used by extensions)
        public let rsv1: Bool

        /// RSV2 bit - reserved
        public let rsv2: Bool

        /// RSV3 bit - reserved
        public let rsv3: Bool

        /// Frame opcode
        public let opcode: Opcode

        /// Masking key (required for client -> server)
        public let mask: MaskingKey?

        /// Payload data (unmasked, opaque byte-domain)
        public let payload: [Byte]

        /// Creates a WebSocket frame
        ///
        /// - Parameters:
        ///   - fin: Final fragment flag (default true)
        ///   - rsv1: Reserved bit 1 (default false)
        ///   - rsv2: Reserved bit 2 (default false)
        ///   - rsv3: Reserved bit 3 (default false)
        ///   - opcode: Frame opcode
        ///   - mask: Masking key (required for client frames)
        ///   - payload: Payload data
        /// - Throws: `Error` if frame is invalid
        public init(
            fin: Bool = true,
            rsv1: Bool = false,
            rsv2: Bool = false,
            rsv3: Bool = false,
            opcode: Opcode,
            mask: MaskingKey? = nil,
            payload: [Byte]
        ) throws(Error) {
            // Control frames must have FIN set
            if opcode.isControl && !fin {
                throw Error.controlFrameMustBeFinal
            }

            // Control frames limited to 125 bytes
            if opcode.isControl && payload.count > Limits.maxControlPayload {
                throw Error.controlPayloadTooLarge(payload.count)
            }

            self.fin = fin
            self.rsv1 = rsv1
            self.rsv2 = rsv2
            self.rsv3 = rsv3
            self.opcode = opcode
            self.mask = mask
            self.payload = payload
        }

        // Stdlib-interop UInt8 forwarder init lives in `RFC 6455 Standard
        // Library Integration` per [API-BYTE-007].

        /// Creates a frame WITHOUT validation
        init(
            __unchecked: Void,
            fin: Bool,
            rsv1: Bool,
            rsv2: Bool,
            rsv3: Bool,
            opcode: Opcode,
            mask: MaskingKey?,
            payload: [Byte]
        ) {
            self.fin = fin
            self.rsv1 = rsv1
            self.rsv2 = rsv2
            self.rsv3 = rsv3
            self.opcode = opcode
            self.mask = mask
            self.payload = payload
        }
    }
}

// MARK: - Binary.Serializable

extension RFC_6455.Frame: Binary.Serializable {
    /// Serializes the WebSocket frame to wire format
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ frame: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        // First byte: FIN + RSV + Opcode. Opcode.rawValue UInt8 stays
        // (separate file scope); bridge via Byte() at conformance boundary.
        var byte0: UInt8 = frame.opcode.rawValue
        if frame.fin { byte0 |= 0x80 }
        if frame.rsv1 { byte0 |= 0x40 }
        if frame.rsv2 { byte0 |= 0x20 }
        if frame.rsv3 { byte0 |= 0x10 }
        buffer.append(Byte(byte0))

        // Second byte: MASK + Payload length
        let masked = frame.mask != nil
        var byte1: UInt8 = masked ? 0x80 : 0

        let payloadLength = frame.payload.count
        if payloadLength < 126 {
            byte1 |= UInt8(payloadLength)
            buffer.append(Byte(byte1))
        } else if payloadLength <= 65535 {
            byte1 |= 126
            buffer.append(Byte(byte1))
            // 16-bit length via Byte-primary bytes(endianness:)
            buffer.append(contentsOf: UInt16(payloadLength).bytes(endianness: .big))
        } else {
            byte1 |= 127
            buffer.append(Byte(byte1))
            // 64-bit length via Byte-primary bytes(endianness:)
            buffer.append(contentsOf: UInt64(payloadLength).bytes(endianness: .big))
        }

        // Masking key and payload. mask.bytes is (UInt8,UInt8,UInt8,UInt8)
        // tuple in separate MaskingKey file scope; bridge via Byte().
        if let mask = frame.mask {
            buffer.append(Byte(mask.bytes.0))
            buffer.append(Byte(mask.bytes.1))
            buffer.append(Byte(mask.bytes.2))
            buffer.append(Byte(mask.bytes.3))

            // Masked payload. mask.applying takes [UInt8] in separate
            // MaskingKey file scope; bridge by bit pattern both ways.
            let maskedUInt8 = mask.applying(to: frame.payload.map(\.bitPattern))
            buffer.append(contentsOf: maskedUInt8.lazy.map(Byte.init(bitPattern:)))
        } else {
            buffer.append(contentsOf: frame.payload)
        }
    }
}

// MARK: - Convenience Constructors

extension RFC_6455.Frame {
    /// Creates a text frame
    ///
    /// - Parameters:
    ///   - text: The text message (UTF-8)
    ///   - mask: Optional masking key
    /// - Returns: A text frame
    public static func text(_ text: String, mask: RFC_6455.MaskingKey? = nil) throws(Error) -> Self {
        try Self(opcode: .text, mask: mask, payload: text.utf8.map(Byte.init(bitPattern:)))
    }

    /// Creates a binary frame
    ///
    /// - Parameters:
    ///   - data: The binary data
    ///   - mask: Optional masking key
    /// - Returns: A binary frame
    public static func binary(_ data: [Byte], mask: RFC_6455.MaskingKey? = nil) throws(Error) -> Self {
        try Self(opcode: .binary, mask: mask, payload: data)
    }

    // Stdlib-interop UInt8 forwarder `binary(_:mask:)` lives in `RFC 6455
    // Standard Library Integration` per [API-BYTE-007].

    /// Creates a ping frame
    ///
    /// - Parameters:
    ///   - data: Optional ping payload (max 125 bytes)
    ///   - mask: Optional masking key
    /// - Returns: A ping frame
    public static func ping(_ data: [Byte] = [], mask: RFC_6455.MaskingKey? = nil) throws(Error) -> Self {
        try Self(opcode: .ping, mask: mask, payload: data)
    }

    /// Creates a pong frame
    ///
    /// - Parameters:
    ///   - data: Pong payload (should match ping)
    ///   - mask: Optional masking key
    /// - Returns: A pong frame
    public static func pong(_ data: [Byte] = [], mask: RFC_6455.MaskingKey? = nil) throws(Error) -> Self {
        try Self(opcode: .pong, mask: mask, payload: data)
    }

    /// Creates a close frame
    ///
    /// - Parameters:
    ///   - code: Close status code
    ///   - reason: Optional close reason (UTF-8)
    ///   - mask: Optional masking key
    /// - Returns: A close frame
    public static func close(
        code: RFC_6455.CloseCode = .normalClosure,
        reason: String = "",
        mask: RFC_6455.MaskingKey? = nil
    ) throws(Error) -> Self {
        var payload: [Byte] = []
        // CloseCode.rawValue UInt16 stays — assumed; serialize via
        // Byte-primary bytes(endianness:).
        payload.append(contentsOf: code.rawValue.bytes(endianness: .big))
        // reason.utf8 is Sequence<UInt8>; bridge by bit pattern.
        payload.append(contentsOf: reason.utf8.lazy.map(Byte.init(bitPattern:)))
        return try Self(opcode: .close, mask: mask, payload: payload)
    }
}
