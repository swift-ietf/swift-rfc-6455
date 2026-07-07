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

// RFC_6455.Frame+UInt8.swift
//
// Stdlib-interop UInt8 forwarders for WebSocket frame construction. Primary
// byte-domain API lives in `RFC 6455`; these forwarders bridge stdlib callers
// carrying `[UInt8]` payloads (e.g. from network buffers, file-read frames)
// via `[Byte](data)`. Per [API-BYTE-007] (byte-discipline skill).

internal import Byte_Primitives
public import RFC_6455

extension RFC_6455.Frame {
    /// Stdlib-interop forwarder: construction from `[UInt8]` payload.
    @_disfavoredOverload
    public init(
        fin: Bool = true,
        rsv1: Bool = false,
        rsv2: Bool = false,
        rsv3: Bool = false,
        opcode: RFC_6455.Opcode,
        mask: RFC_6455.MaskingKey? = nil,
        payload: [UInt8]
    ) throws(RFC_6455.Frame.Error) {
        try self.init(
            fin: fin,
            rsv1: rsv1,
            rsv2: rsv2,
            rsv3: rsv3,
            opcode: opcode,
            mask: mask,
            payload: [Byte](payload)
        )
    }

    /// Stdlib-interop forwarder: binary frame from `[UInt8]` data.
    @_disfavoredOverload
    public static func binary(_ data: [UInt8], mask: RFC_6455.MaskingKey? = nil) throws(RFC_6455.Frame.Error) -> Self {
        try Self(opcode: .binary, mask: mask, payload: [Byte](data))
    }
}
