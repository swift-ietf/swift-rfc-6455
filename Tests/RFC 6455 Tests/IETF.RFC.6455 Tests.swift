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

@testable import RFC_6455

enum `IETF.RFC.6455 Tests` {}

extension `IETF.RFC.6455 Tests` {
    @Suite
    struct `RFC 6455 WebSocket Tests` {
    }
}

extension `IETF.RFC.6455 Tests`.`RFC 6455 WebSocket Tests` {
    @Suite
    struct `Constants Tests` {
        @Test
        func `Version is 13`() {
            #expect(IETF.RFC.`6455`.version == 13)
        }

        @Test
        func `GUID value`() {
            #expect(IETF.RFC.`6455`.guid == "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
        }
    }

    @Suite
    struct `Opcode Tests` {
        @Test
        func `Data frame opcodes`() {
            #expect(IETF.RFC.`6455`.Opcode.continuation.rawValue == 0x0)
            #expect(IETF.RFC.`6455`.Opcode.text.rawValue == 0x1)
            #expect(IETF.RFC.`6455`.Opcode.binary.rawValue == 0x2)
        }

        @Test
        func `Control frame opcodes`() {
            #expect(IETF.RFC.`6455`.Opcode.close.rawValue == 0x8)
            #expect(IETF.RFC.`6455`.Opcode.ping.rawValue == 0x9)
            #expect(IETF.RFC.`6455`.Opcode.pong.rawValue == 0xA)
        }

        @Test
        func `Control frame classification`() {
            #expect(IETF.RFC.`6455`.Opcode.text.isControl == false)
            #expect(IETF.RFC.`6455`.Opcode.text.isData == true)
            #expect(IETF.RFC.`6455`.Opcode.ping.isControl == true)
            #expect(IETF.RFC.`6455`.Opcode.ping.isData == false)
        }

        @Test
        func `Reserved opcode detection`() {
            #expect(IETF.RFC.`6455`.Opcode(rawValue: 0x3).isReserved == true)
            #expect(IETF.RFC.`6455`.Opcode(rawValue: 0xB).isReserved == true)
            #expect(IETF.RFC.`6455`.Opcode.text.isReserved == false)
        }
    }

    @Suite
    struct `Close Code Tests` {
        @Test
        func `Standard close codes`() {
            #expect(IETF.RFC.`6455`.CloseCode.normalClosure.rawValue == 1000)
            #expect(IETF.RFC.`6455`.CloseCode.goingAway.rawValue == 1001)
            #expect(IETF.RFC.`6455`.CloseCode.protocolError.rawValue == 1002)
            #expect(IETF.RFC.`6455`.CloseCode.messageTooLarge.rawValue == 1009)
        }

        @Test
        func `Reserved codes are invalid`() {
            #expect(IETF.RFC.`6455`.CloseCode.noStatusReceived.isValid == false)
            #expect(IETF.RFC.`6455`.CloseCode.abnormalClosure.isValid == false)
            #expect(IETF.RFC.`6455`.CloseCode.tlsHandshakeFailed.isValid == false)
            #expect(IETF.RFC.`6455`.CloseCode.normalClosure.isValid == true)
        }

        @Test
        func `Codes outside 1000 to 4999 are invalid`() {
            #expect(IETF.RFC.`6455`.CloseCode(rawValue: 999).isValid == false)
            #expect(IETF.RFC.`6455`.CloseCode(rawValue: 4999).isValid == true)
            #expect(IETF.RFC.`6455`.CloseCode(rawValue: 5000).isValid == false)
            #expect(IETF.RFC.`6455`.CloseCode(rawValue: UInt16.max).isValid == false)
        }

        @Test
        func `Code range classification`() {
            #expect(IETF.RFC.`6455`.CloseCode.normalClosure.isProtocolDefined == true)
            #expect(IETF.RFC.`6455`.CloseCode(rawValue: 3000).isLibraryCode == true)
            #expect(IETF.RFC.`6455`.CloseCode(rawValue: 4000).isApplicationCode == true)
        }
    }

    @Suite
    struct `Masking Key Tests` {
        @Test
        func `Create from bytes`() {
            let key = IETF.RFC.`6455`.MaskingKey(0x12, 0x34, 0x56, 0x78)
            #expect(key.bytes.0 == 0x12)
            #expect(key.bytes.1 == 0x34)
            #expect(key.bytes.2 == 0x56)
            #expect(key.bytes.3 == 0x78)
        }

        @Test
        func `Create from value`() {
            let key = IETF.RFC.`6455`.MaskingKey(value: 0x1234_5678)
            #expect(key.bytes.0 == 0x12)
            #expect(key.bytes.1 == 0x34)
            #expect(key.bytes.2 == 0x56)
            #expect(key.bytes.3 == 0x78)
        }

        @Test
        func `Subscript access`() {
            let key = IETF.RFC.`6455`.MaskingKey(0xAA, 0xBB, 0xCC, 0xDD)
            #expect(key[0] == 0xAA)
            #expect(key[1] == 0xBB)
            #expect(key[2] == 0xCC)
            #expect(key[3] == 0xDD)
            #expect(key[4] == 0xAA)  // Wraps around
        }

        @Test
        func `Masking is reversible`() {
            let key = IETF.RFC.`6455`.MaskingKey(0x12, 0x34, 0x56, 0x78)
            // MaskingKey.apply takes inout [UInt8] in separate file scope;
            // test stays UInt8 at the apply call.
            let original: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]  // "Hello"

            var data = original
            key.apply(to: &data)
            #expect(data != original)

            key.apply(to: &data)
            #expect(data == original)
        }
    }

    @Suite
    struct `Frame Tests` {
        @Test
        func `Create text frame`() throws {
            let frame = try IETF.RFC.`6455`.Frame.text("Hello")

            #expect(frame.fin == true)
            #expect(frame.opcode == .text)
            #expect(frame.payload == [Byte](utf8: "Hello"))
        }

        @Test
        func `Create binary frame`() throws {
            let frame = try IETF.RFC.`6455`.Frame.binary([Byte(1), Byte(2), Byte(3), Byte(4)])

            #expect(frame.opcode == .binary)
            #expect(frame.payload == [Byte(1), Byte(2), Byte(3), Byte(4)])
        }

        @Test
        func `Create ping frame`() throws {
            let frame = try IETF.RFC.`6455`.Frame.ping()

            #expect(frame.opcode == .ping)
            #expect(frame.payload.isEmpty)
        }

        @Test
        func `Create close frame`() throws {
            let frame = try IETF.RFC.`6455`.Frame.close(code: .normalClosure, reason: "bye")

            #expect(frame.opcode == .close)
            // Payload: 2 bytes code + "bye"
            #expect(frame.payload.count == 5)
            #expect(frame.payload[0] == Byte(0x03))  // 1000 >> 8
            #expect(frame.payload[1] == Byte(0xE8))  // 1000 & 0xFF
        }

        @Test
        func `Close frame rejects codes that must not be sent`() {
            for code: UInt16 in [999, 1005, 1006, 1015, 5000] {
                #expect(throws: IETF.RFC.`6455`.Frame.Error.invalidCloseCode(code)) {
                    try IETF.RFC.`6455`.Frame.close(code: IETF.RFC.`6455`.CloseCode(rawValue: code))
                }
            }
        }

        @Test
        func `Control frames must be final`() {
            #expect(throws: IETF.RFC.`6455`.Frame.Error.self) {
                try IETF.RFC.`6455`.Frame(
                    fin: false,
                    opcode: .ping,
                    payload: []
                )
            }
        }

        @Test
        func `Reserved opcodes are rejected`() {
            for rawValue: UInt8 in [0x3, 0x7, 0xB, 0xF] {
                #expect(throws: IETF.RFC.`6455`.Frame.Error.reservedOpcode(rawValue)) {
                    try IETF.RFC.`6455`.Frame(opcode: IETF.RFC.`6455`.Opcode(rawValue: rawValue), payload: [])
                }
            }
        }

        @Test
        func `Control frame payload limit`() {
            let largePayload: [Byte] = Array(repeating: Byte(0), count: 126)

            #expect(throws: IETF.RFC.`6455`.Frame.Error.self) {
                try IETF.RFC.`6455`.Frame(opcode: .ping, payload: largePayload)
            }
        }

        @Test
        func `Serialize unmasked frame`() throws {
            let frame = try IETF.RFC.`6455`.Frame.text("Hi")

            var buffer: [Byte] = []
            IETF.RFC.`6455`.Frame.serialize(frame, into: &buffer)

            // FIN + text opcode, no mask + length 2, "Hi"
            #expect(buffer.count == 4)
            #expect(buffer[0] == Byte(0x81))  // FIN + text
            #expect(buffer[1] == Byte(0x02))  // no mask + length 2
            #expect(buffer[2] == Byte(0x48))  // 'H'
            #expect(buffer[3] == Byte(0x69))  // 'i'
        }

        @Test
        func `Serialize masked frame`() throws {
            let mask = IETF.RFC.`6455`.MaskingKey(0x37, 0xfa, 0x21, 0x3d)
            let frame = try IETF.RFC.`6455`.Frame.text("Hi", mask: mask)

            var buffer: [Byte] = []
            IETF.RFC.`6455`.Frame.serialize(frame, into: &buffer)

            // FIN + text, mask + length, 4 mask bytes, 2 masked bytes
            #expect(buffer.count == 8)
            #expect(buffer[0] == Byte(0x81))  // FIN + text
            #expect(buffer[1] == Byte(0x82))  // mask bit + length 2
            // Mask bytes
            #expect(buffer[2] == Byte(0x37))
            #expect(buffer[3] == Byte(0xfa))
            #expect(buffer[4] == Byte(0x21))
            #expect(buffer[5] == Byte(0x3d))
        }

        @Test
        func `Frame limits`() {
            #expect(IETF.RFC.`6455`.Frame.Limits.maxControlPayload == 125)
            #expect(IETF.RFC.`6455`.Frame.Limits.maxPayload7Bit == 125)
            #expect(IETF.RFC.`6455`.Frame.Limits.maxPayload16Bit == 65535)
        }
    }
}
