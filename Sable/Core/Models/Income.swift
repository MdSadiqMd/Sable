import Foundation

/// Where an income comes from: a salary, freelance work, rent. Each has its own pay history.
struct IncomeSource: Identifiable, Hashable {
    let id: Int64
    var name: String
    var isSalary: Bool
    /// The account it's paid into, if you've said.
    var accountId: Int64?
}

/// "From this month on": gross pay before tax, and the tax deducted from it. A raise or a new tax rate is a
/// new rate from its month; stopping an income is a rate of zero.
struct IncomeRate: Hashable {
    let sourceId: Int64
    let start: Int
    let gross: Int64
    let tax: Int64
    var note: String?
}

/// One month only, for one source: a different gross, a different tax deduction, or both (nil keeps the usual).
struct IncomeOverride: Hashable {
    let sourceId: Int64
    let month: Int
    var gross: Int64?
    var tax: Int64?
    var note: String?
}

/// A one-off: a bonus, a gift, a tax refund. Counts in its month only.
struct IncomeExtra: Identifiable, Hashable {
    let id: Int64
    let month: Int
    var title: String
    var gross: Int64
    var tax: Int64
}

/// Everything you've entered about income, and the arithmetic on it. Nothing here is stored as a total: every
/// figure is worked out from the entries when asked, so editing any entry changes every month it touches.
struct IncomeBook: Equatable {
    var sources: [IncomeSource] = []
    var rates: [IncomeRate] = []
    var overrides: [IncomeOverride] = []
    var extras: [IncomeExtra] = []

    struct Line: Hashable {
        let gross: Int64
        let tax: Int64
        var takeHome: Int64 { gross - tax }
    }

    var isEmpty: Bool { rates.isEmpty && extras.isEmpty }

    /// The rate in force for a source in a month: the latest one starting at or before it.
    func rate(_ source: Int64, in month: Int) -> IncomeRate? {
        rates.filter { $0.sourceId == source && $0.start <= month }.max { $0.start < $1.start }
    }

    /// What one source paid in a month, after any one-month change; nil before it started.
    func line(_ source: Int64, in month: Int) -> Line? {
        guard let rate = rate(source, in: month) else { return nil }
        let change = overrides.first { $0.sourceId == source && $0.month == month }
        return Line(gross: change?.gross ?? rate.gross, tax: change?.tax ?? rate.tax)
    }

    /// All sources and extras for a month; nil when nothing applies yet.
    func month(_ month: Int) -> Line? {
        let lines =
            sources.compactMap { line($0.id, in: month) } + extras.filter { $0.month == month }.map { Line(gross: $0.gross, tax: $0.tax) }
        guard !lines.isEmpty else { return nil }
        return Line(gross: lines.reduce(0) { $0 + $1.gross }, tax: lines.reduce(0) { $0 + $1.tax })
    }

    /// The first month anything was earned, for how far back the history goes.
    var firstMonth: Int? { (rates.map(\.start) + extras.map(\.month)).min() }
}

extension Date {
    /// yyyymm for the month this date falls in.
    var monthKey: Int {
        let parts = Calendar.current.dateComponents([.year, .month], from: self)
        return (parts.year ?? 0) * 100 + (parts.month ?? 0)
    }

    init?(monthKey: Int) {
        guard let date = Calendar.current.date(from: DateComponents(year: monthKey / 100, month: monthKey % 100, day: 1)) else {
            return nil
        }
        self = date
    }
}

extension Int {
    /// The yyyymm month before this one: 202601 -> 202512.
    var previousMonthKey: Int { self % 100 == 1 ? (self / 100 - 1) * 100 + 12 : self - 1 }
}
