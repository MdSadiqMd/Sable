extension String {
    /// FNV-1a over UTF-8: the same text always gives the same 64-bit value, on every launch and every phone
    /// (Swift's own Hasher is seeded per launch). Used to index SMS text without storing it twice.
    var stableHash: Int64 {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in utf8 { hash = (hash ^ UInt64(byte)) &* 0x0100_0000_01b3 }
        return Int64(bitPattern: hash)
    }
}
