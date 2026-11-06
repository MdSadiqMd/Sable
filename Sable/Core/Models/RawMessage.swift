import Foundation

/// An SMS exactly as received. Kept forever so a parser fix can re-read it.
struct RawRow: Identifiable, Hashable {
    let id: Int64
    let body: String
    let status: String  // parsed | ignored | review
    let note: String?
    let at: Date
    let seenCount: Int
}
