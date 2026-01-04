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

// RFC_6455.Frame.Limits.swift
// swift-rfc-6455
//
// RFC 6455 Section 5.2: Base Framing Protocol

extension RFC_6455.Frame {
    /// Frame size limits
    public enum Limits {
        /// Maximum control frame payload (125 bytes)
        public static let maxControlPayload = 125

        /// Maximum payload length using 7-bit encoding
        public static let maxPayload7Bit = 125

        /// Maximum payload length using 16-bit encoding
        public static let maxPayload16Bit = 65535

        /// Minimum header size (2 bytes)
        public static let minHeaderSize = 2
    }
}
