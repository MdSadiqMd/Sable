import Foundation

/// One person's part of a split bill.
struct ShareRow: Identifiable, Hashable {
    let id: Int64
    let splitId: Int64
    let name: String
    let phone: String?
    let vpa: String?
    let amount: Int64
    let theyOwe: Bool  // true: they pay you back; false: you pay them
    let settledAt: Date?
    var isSettled: Bool { settledAt != nil }
}

struct SplitRow: Identifiable, Hashable {
    let id: Int64
    let txnId: Int64?
    let title: String
    let total: Int64
    let categoryId: Int64?
    let createdAt: Date
    let shares: [ShareRow]

    var open: [ShareRow] { shares.filter { !$0.isSettled } }
    var owedToYou: Int64 { open.filter(\.theyOwe).reduce(0) { $0 + $1.amount } }
    var youOwe: Int64 { open.filter { !$0.theyOwe }.reduce(0) { $0 + $1.amount } }
    /// Your own part: the bill minus what others pay you, or what you pay them when someone else paid.
    var yourShare: Int64 {
        let theirs = shares.filter(\.theyOwe).reduce(0) { $0 + $1.amount }
        return shares.contains(where: \.theyOwe) ? total - theirs : shares.reduce(0) { $0 + $1.amount }
    }
}

/// A person to split with, before the split is saved.
struct SplitPerson: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var phone: String?
    var vpa: String?
    var amount: Int64 = 0
}
