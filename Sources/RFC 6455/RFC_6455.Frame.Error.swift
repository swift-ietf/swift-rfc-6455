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

        /// Close code that must not be sent in a close frame
        case invalidCloseCode(_ code: UInt16)
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
        case .invalidCloseCode(let code):
            return "Close code \(code) must not be sent in a close frame"
        }
    }
}
