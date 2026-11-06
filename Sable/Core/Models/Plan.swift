import Foundation

/// A payment you make every month (rent, money home). Paid when a matching payment arrives that month.
struct PlanRow: Identifiable, Hashable {
    let id: Int64
    let title: String
    let payeeKey: String?
    let amount: Int64
    let day: Int
    let categoryId: Int64?
    let paid: Bool
    let active: Bool

    /// This month's due date; day 31 becomes the 30th or 28th in shorter months.
    func due(in month: Date) -> Date {
        let cal = Calendar.current
        let days = cal.range(of: .day, in: .month, for: month)?.count ?? 28
        return cal.date(byAdding: .day, value: min(day, days) - 1, to: month) ?? month
    }
}
