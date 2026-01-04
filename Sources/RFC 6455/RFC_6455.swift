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

// RFC_6455.swift
// swift-rfc-6455
//
// RFC 6455: The WebSocket Protocol (December 2011)
// https://www.rfc-editor.org/rfc/rfc6455.html
//
// This package implements the WebSocket protocol as defined by RFC 6455.

/// RFC 6455: The WebSocket Protocol
///
/// This namespace contains types for the WebSocket protocol as defined
/// in RFC 6455 from December 2011.
///
/// ## Key Types
///
/// - ``Frame``: WebSocket data frame
/// - ``Opcode``: Frame operation codes
/// - ``CloseCode``: Connection close status codes
/// - ``MaskingKey``: Frame masking key
///
/// ## Protocol Overview
///
/// WebSocket provides full-duplex communication over a single TCP connection.
/// After an HTTP upgrade handshake, data is exchanged in frames.
///
/// ## Frame Structure
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
/// ```
///
/// ## Example
///
/// ```swift
/// // Create a text frame
/// let frame = try RFC_6455.Frame(
///     opcode: .text,
///     payload: Array("Hello, WebSocket!".utf8)
/// )
///
/// // Serialize with masking (client -> server)
/// let key = RFC_6455.MaskingKey.random()
/// var masked = try RFC_6455.Frame(
///     opcode: .text,
///     mask: key,
///     payload: Array("Hello".utf8)
/// )
/// ```
///
/// ## See Also
///
/// - [RFC 6455](https://www.rfc-editor.org/rfc/rfc6455)
/// - ``RFC_3986`` for WebSocket URIs
public enum RFC_6455 {}

extension RFC_6455 {
    /// WebSocket protocol version
    ///
    /// The Sec-WebSocket-Version header value.
    public static let version: Int = 13

    /// WebSocket GUID for handshake
    ///
    /// Used in Sec-WebSocket-Accept calculation.
    public static let guid = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
}
