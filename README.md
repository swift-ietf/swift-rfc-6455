# swift-rfc-6455

Use this package when you need to build WebSocket frames and write them in RFC 6455 wire format. Start from `RFC_6455.Frame`, with `RFC_6455.Opcode`, `RFC_6455.CloseCode` and `RFC_6455.MaskingKey` for its parts. The package writes frames but doesn't read them from the wire, and it doesn't perform the opening handshake beyond providing `RFC_6455.version` and `RFC_6455.guid`. If your payloads are `[UInt8]`, add the `RFC 6455 Standard Library Integration` product.

## Laws

- A control frame (close, ping, pong) must be final and carry at most 125 payload bytes. A close frame's reason therefore fits in 123 bytes after the two byte code. Data frames have no such limits.
- `RFC_6455.Frame.payload` always holds the unmasked bytes. A frame that has a mask is masked only when it is serialized, with the mask bit set and the key written before the payload.
- Serialization picks the shortest length form: 7 bits up to 125 bytes, then a 16 bit big-endian length up to 65535, then a 64 bit big-endian length.
- `RFC_6455.Frame.close(code:reason:mask:)` writes the code as two big-endian bytes followed by the reason in UTF-8.
- `RFC_6455.CloseCode.isValid` is false below 1000 and for the reserved codes 1005, 1006 and 1015, which must not be sent. Building a close frame doesn't check it.
- `RFC_6455.Opcode.init(rawValue:)` keeps only the low four bits. Reserved opcodes are accepted and reported by `RFC_6455.Opcode.isReserved`.
- `RFC_6455.MaskingKey` applies its bytes in turn, so byte `i` of the data is XORed with key byte `i` modulo 4. Applying the same key twice restores the data.
