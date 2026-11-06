import Foundation

/// Spending per payee: a hotel inside Food, for example.
struct PayeeTotal: Identifiable, Hashable {
    let key: String
    let name: String
    let total: Int64
    let count: Int
    let last: Date
    var id: String { key }
}

/// Net money between you and one person: positive means they owe you.
struct DebtRow: Identifiable, Hashable {
    let key: String
    let name: String
    /// Positive: they owe you. Negative: you owe them.
    let net: Int64
    let last: Date
    /// 1 lent, 2 borrowed (txns.debt of the latest marked payment).
    let kind: Int
    let due: Date?
    var id: String { key }
    var lent: Bool { kind == 1 }
    var open: Int64 { abs(net) }
    var overdue: Bool { due.map { $0 < Calendar.current.startOfDay(for: .now) } ?? false && net != 0 }
}
