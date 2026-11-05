import Foundation

/// A run of whole calendar months that the Overview and Categories look at: one month by default, or a range
/// chosen in the month picker ("Aug – Nov", "FY 2026–27").
struct Period: Hashable {
    /// First day of the first month.
    let start: Date
    let months: Int

    init(start: Date, months: Int = 1) {
        self.start = Calendar.current.dateInterval(of: .month, for: start)?.start ?? start
        self.months = max(1, months)
    }

    /// From one month to another, in either order, both included.
    init(from a: Date, to b: Date) {
        let cal = Calendar.current
        let first = cal.dateInterval(of: .month, for: min(a, b))?.start ?? a
        let last = cal.dateInterval(of: .month, for: max(a, b))?.start ?? b
        self.init(start: first, months: (cal.dateComponents([.month], from: first, to: last).month ?? 0) + 1)
    }

    static var thisMonth: Period { Period(start: .now) }

    /// Exclusive.
    var end: Date { Calendar.current.date(byAdding: .month, value: months, to: start) ?? start }
    var lastMonth: Date { Calendar.current.date(byAdding: .month, value: months - 1, to: start) ?? start }
    var isSingleMonth: Bool { months == 1 }
    var containsToday: Bool { start <= .now && .now < end }
    var isThisMonth: Bool { isSingleMonth && containsToday }

    /// The same length of time, moved back (negative) or forward by whole periods.
    func shifted(by steps: Int) -> Period {
        Period(start: Calendar.current.date(byAdding: .month, value: steps * months, to: start) ?? start, months: months)
    }

    var previous: Period { shifted(by: -1) }
    /// The next period has started, so there's something to see there.
    var hasNext: Bool { end <= .now }

    /// "November", "Nov 2025", "Aug – Nov", "Dec 2025 – Feb 2026", or "FY 2026–27" for April to March.
    var title: String {
        let cal = Calendar.current
        let thisYear = { (d: Date) in cal.isDate(d, equalTo: .now, toGranularity: .year) }
        let year = cal.component(.year, from: start)
        if isSingleMonth {
            return start.formatted(thisYear(start) ? .dateTime.month(.wide) : .dateTime.month(.abbreviated).year())
        }
        if months == 12, cal.component(.month, from: start) == 4 { return "FY \(year)–\((year + 1) % 100)" }
        let from = start.formatted(.dateTime.month(.abbreviated))
        let to = lastMonth.formatted(.dateTime.month(.abbreviated))
        if cal.isDate(start, equalTo: lastMonth, toGranularity: .year) {
            return thisYear(start) ? "\(from) – \(to)" : "\(from) – \(to) \(year)"
        }
        return "\(start.formatted(.dateTime.month(.abbreviated).year())) – \(lastMonth.formatted(.dateTime.month(.abbreviated).year()))"
    }

    /// For headings: "Spent this month", "Spent in October", "Spent in Aug – Nov".
    var spentLabel: String { isThisMonth ? "Spent this month" : "Spent in \(title)" }
}
