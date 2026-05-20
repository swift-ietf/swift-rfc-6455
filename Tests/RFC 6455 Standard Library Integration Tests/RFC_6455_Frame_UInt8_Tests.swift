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

import Testing
import RFC_6455
import RFC_6455_Standard_Library_Integration

@Suite("RFC 6455 Frame UInt8 forwarder")
struct RFC_6455_Frame_UInt8_Tests {
    @Test
    func `init forwarder accepts [UInt8] payload`() throws {
        let uint8Payload: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F] // "Hello"
        let frame = try RFC_6455.Frame(opcode: .binary, payload: uint8Payload)
        #expect(frame.opcode == .binary)
        #expect(frame.payload.count == 5)
    }

    @Test
    func `binary forwarder accepts [UInt8] data`() throws {
        let uint8Data: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        let frame = try RFC_6455.Frame.binary(uint8Data)
        #expect(frame.opcode == .binary)
        #expect(frame.payload.count == 4)
    }
}
