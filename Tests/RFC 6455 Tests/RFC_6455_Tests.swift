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

@Suite("RFC 6455 WebSocket Tests")
struct RFC6455Tests {

    @Suite("Constants Tests")
    struct ConstantsTests {
        @Test("Version is 13")
        func versionIs13() {
            #expect(RFC_6455.version == 13)
        }

        @Test("GUID value")
        func guidValue() {
            #expect(RFC_6455.guid == "258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
        }
    }

    @Suite("Opcode Tests")
    struct OpcodeTests {
        @Test("Data frame opcodes")
        func dataFrameOpcodes() {
            #expect(RFC_6455.Opcode.continuation.rawValue == 0x0)
            #expect(RFC_6455.Opcode.text.rawValue == 0x1)
            #expect(RFC_6455.Opcode.binary.rawValue == 0x2)
        }

        @Test("Control frame opcodes")
        func controlFrameOpcodes() {
            #expect(RFC_6455.Opcode.close.rawValue == 0x8)
            #expect(RFC_6455.Opcode.ping.rawValue == 0x9)
            #expect(RFC_6455.Opcode.pong.rawValue == 0xA)
        }

        @Test("Control frame classification")
        func controlFrameClassification() {
            #expect(RFC_6455.Opcode.text.isControl == false)
            #expect(RFC_6455.Opcode.text.isData == true)
            #expect(RFC_6455.Opcode.ping.isControl == true)
            #expect(RFC_6455.Opcode.ping.isData == false)
        }

        @Test("Reserved opcode detection")
        func reservedOpcodeDetection() {
            #expect(RFC_6455.Opcode(rawValue: 0x3).isReserved == true)
            #expect(RFC_6455.Opcode(rawValue: 0xB).isReserved == true)
            #expect(RFC_6455.Opcode.text.isReserved == false)
        }
    }

    @Suite("Close Code Tests")
    struct CloseCodeTests {
        @Test("Standard close codes")
        func standardCloseCodes() {
            #expect(RFC_6455.CloseCode.normalClosure.rawValue == 1000)
            #expect(RFC_6455.CloseCode.goingAway.rawValue == 1001)
            #expect(RFC_6455.CloseCode.protocolError.rawValue == 1002)
            #expect(RFC_6455.CloseCode.messageTooLarge.rawValue == 1009)
        }

        @Test("Reserved codes are invalid")
        func reservedCodesInvalid() {
            #expect(RFC_6455.CloseCode.noStatusReceived.isValid == false)
            #expect(RFC_6455.CloseCode.abnormalClosure.isValid == false)
            #expect(RFC_6455.CloseCode.tlsHandshakeFailed.isValid == false)
            #expect(RFC_6455.CloseCode.normalClosure.isValid == true)
        }

        @Test("Code range classification")
        func codeRangeClassification() {
            #expect(RFC_6455.CloseCode.normalClosure.isProtocolDefined == true)
            #expect(RFC_6455.CloseCode(rawValue: 3000).isLibraryCode == true)
            #expect(RFC_6455.CloseCode(rawValue: 4000).isApplicationCode == true)
        }
    }

    @Suite("Masking Key Tests")
    struct MaskingKeyTests {
        @Test("Create from bytes")
        func createFromBytes() {
            let key = RFC_6455.MaskingKey(0x12, 0x34, 0x56, 0x78)
            #expect(key.bytes.0 == 0x12)
            #expect(key.bytes.1 == 0x34)
            #expect(key.bytes.2 == 0x56)
            #expect(key.bytes.3 == 0x78)
        }

        @Test("Create from value")
        func createFromValue() {
            let key = RFC_6455.MaskingKey(value: 0x12345678)
            #expect(key.bytes.0 == 0x12)
            #expect(key.bytes.1 == 0x34)
            #expect(key.bytes.2 == 0x56)
            #expect(key.bytes.3 == 0x78)
        }

        @Test("Subscript access")
        func subscriptAccess() {
            let key = RFC_6455.MaskingKey(0xAA, 0xBB, 0xCC, 0xDD)
            #expect(key[0] == 0xAA)
            #expect(key[1] == 0xBB)
            #expect(key[2] == 0xCC)
            #expect(key[3] == 0xDD)
            #expect(key[4] == 0xAA) // Wraps around
        }

        @Test("Masking is reversible")
        func maskingReversible() {
            let key = RFC_6455.MaskingKey(0x12, 0x34, 0x56, 0x78)
            let original: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F] // "Hello"

            var data = original
            key.apply(to: &data)
            #expect(data != original)

            key.apply(to: &data)
            #expect(data == original)
        }
    }

    @Suite("Frame Tests")
    struct FrameTests {
        @Test("Create text frame")
        func createTextFrame() throws {
            let frame = try RFC_6455.Frame.text("Hello")

            #expect(frame.fin == true)
            #expect(frame.opcode == .text)
            #expect(frame.payload == Array("Hello".utf8))
        }

        @Test("Create binary frame")
        func createBinaryFrame() throws {
            let frame = try RFC_6455.Frame.binary([1, 2, 3, 4])

            #expect(frame.opcode == .binary)
            #expect(frame.payload == [1, 2, 3, 4])
        }

        @Test("Create ping frame")
        func createPingFrame() throws {
            let frame = try RFC_6455.Frame.ping()

            #expect(frame.opcode == .ping)
            #expect(frame.payload.isEmpty)
        }

        @Test("Create close frame")
        func createCloseFrame() throws {
            let frame = try RFC_6455.Frame.close(code: .normalClosure, reason: "bye")

            #expect(frame.opcode == .close)
            // Payload: 2 bytes code + "bye"
            #expect(frame.payload.count == 5)
            #expect(frame.payload[0] == 0x03) // 1000 >> 8
            #expect(frame.payload[1] == 0xE8) // 1000 & 0xFF
        }

        @Test("Control frames must be final")
        func controlFramesMustBeFinal() {
            #expect(throws: RFC_6455.Frame.Error.self) {
                try RFC_6455.Frame(
                    fin: false,
                    opcode: .ping,
                    payload: []
                )
            }
        }

        @Test("Control frame payload limit")
        func controlFramePayloadLimit() {
            let largePayload = Array(repeating: UInt8(0), count: 126)

            #expect(throws: RFC_6455.Frame.Error.self) {
                try RFC_6455.Frame(opcode: .ping, payload: largePayload)
            }
        }

        @Test("Serialize unmasked frame")
        func serializeUnmaskedFrame() throws {
            let frame = try RFC_6455.Frame.text("Hi")

            var buffer: [UInt8] = []
            RFC_6455.Frame.serialize(frame, into: &buffer)

            // FIN + text opcode, no mask + length 2, "Hi"
            #expect(buffer.count == 4)
            #expect(buffer[0] == 0x81) // FIN + text
            #expect(buffer[1] == 0x02) // no mask + length 2
            #expect(buffer[2] == 0x48) // 'H'
            #expect(buffer[3] == 0x69) // 'i'
        }

        @Test("Serialize masked frame")
        func serializeMaskedFrame() throws {
            let mask = RFC_6455.MaskingKey(0x37, 0xfa, 0x21, 0x3d)
            let frame = try RFC_6455.Frame.text("Hi", mask: mask)

            var buffer: [UInt8] = []
            RFC_6455.Frame.serialize(frame, into: &buffer)

            // FIN + text, mask + length, 4 mask bytes, 2 masked bytes
            #expect(buffer.count == 8)
            #expect(buffer[0] == 0x81) // FIN + text
            #expect(buffer[1] == 0x82) // mask bit + length 2
            // Mask bytes
            #expect(buffer[2] == 0x37)
            #expect(buffer[3] == 0xfa)
            #expect(buffer[4] == 0x21)
            #expect(buffer[5] == 0x3d)
        }

        @Test("Frame limits")
        func frameLimits() {
            #expect(RFC_6455.Frame.Limits.maxControlPayload == 125)
            #expect(RFC_6455.Frame.Limits.maxPayload7Bit == 125)
            #expect(RFC_6455.Frame.Limits.maxPayload16Bit == 65535)
        }
    }
}
