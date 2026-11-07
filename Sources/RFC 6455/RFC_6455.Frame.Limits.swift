extension RFC_6455.Frame {
    /// Frame size limits
    public enum Limits {
    }
}

extension RFC_6455.Frame.Limits {
    /// Maximum control frame payload (125 bytes)
    public static let maxControlPayload = 125

    /// Maximum payload length using 7-bit encoding
    public static let maxPayload7Bit = 125

    /// Maximum payload length using 16-bit encoding
    public static let maxPayload16Bit = 65535

    /// Minimum header size (2 bytes)
    public static let minHeaderSize = 2
}
