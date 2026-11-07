internal import Byte
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
            payload: payload.map(Byte.init(bitPattern:))
        )
    }

    /// Stdlib-interop forwarder: binary frame from `[UInt8]` data.
    @_disfavoredOverload
    public static func binary(_ data: [UInt8], mask: RFC_6455.MaskingKey? = nil) throws(RFC_6455.Frame.Error) -> Self {
        try Self(opcode: .binary, mask: mask, payload: data.map(Byte.init(bitPattern:)))
    }
}
