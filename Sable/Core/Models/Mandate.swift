import Foundation

struct MandateRow: Identifiable, Hashable {
    let id: Int64
    let name: String
    let amount: Int64?
    let frequency: String?
    let account: String?
    let status: String  // active | paused | cancelled
    let statusAt: Date
    let lastDebitAt: Date?
    let nextDueAt: Date?
    let charges: Int
    let charged: Int64

    /// Charges per month, so totals can be shown per month. "As presented" is treated as monthly.
    var monthlyShare: Double {
        switch frequency {
        case "daily": 30
        case "weekly": 4.33
        case "fortnightly": 2.17
        case "quarterly": 1.0 / 3
        case "half yearly", "half-yearly": 1.0 / 6
        case "yearly", "annually": 1.0 / 12
        default: 1
        }
    }

    /// The bank's "will be debited on" date when known, else one period after the last charge.
    var expectedNext: Date? {
        if let nextDueAt { return nextDueAt }
        guard let lastDebitAt else { return nil }
        let cal = Calendar.current
        return switch frequency {
        case "daily": cal.date(byAdding: .day, value: 1, to: lastDebitAt)
        case "weekly": cal.date(byAdding: .day, value: 7, to: lastDebitAt)
        case "quarterly": cal.date(byAdding: .month, value: 3, to: lastDebitAt)
        case "half yearly", "half-yearly": cal.date(byAdding: .month, value: 6, to: lastDebitAt)
        case "yearly", "annually": cal.date(byAdding: .year, value: 1, to: lastDebitAt)
        default: cal.date(byAdding: .month, value: 1, to: lastDebitAt)
        }
    }

    /// Active, but the expected charge is more than 10 days late: probably cancelled in the UPI app
    /// without the bank sending an SMS.
    var looksStale: Bool {
        guard status == "active", let expectedNext else { return false }
        return expectedNext.addingTimeInterval(10 * 86_400) < .now
    }
}
