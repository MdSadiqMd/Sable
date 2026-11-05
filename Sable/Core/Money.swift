import Foundation

/// Money is stored as integer paise everywhere so sums are exact.
enum Money {
    private static let whole = formatter(fractionDigits: 0)
    private static let fractional = formatter(fractionDigits: 2)

    private static func formatter(fractionDigits: Int) -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_IN")
        f.currencyCode = "INR"
        f.minimumFractionDigits = fractionDigits
        f.maximumFractionDigits = fractionDigits
        return f
    }

    /// 12345678 -> "₹1,23,456.78", 50000 -> "₹500"
    static func format(_ paise: Int64) -> String {
        let value = NSDecimalNumber(mantissa: paise.magnitude, exponent: -2, isNegative: paise < 0)
        return (paise % 100 == 0 ? whole : fractional).string(from: value) ?? "₹\(paise / 100)"
    }

    private static let grouped: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: "en_IN")
        f.maximumFractionDigits = 0
        return f
    }()

    /// 12345678 -> ("1,23,456", "78"); 50000 -> ("500", nil). For text that styles rupees and paise apart.
    static func parts(_ paise: Int64) -> (rupees: String, paise: String?) {
        let rupees = grouped.string(from: NSNumber(value: paise.magnitude / 100)) ?? "\(paise.magnitude / 100)"
        let rest = paise.magnitude % 100
        return (rupees, rest == 0 ? nil : String(format: "%02d", rest))
    }

    /// Axis labels: 950 -> "₹950", 12500 -> "₹12.5k", 150000 -> "₹1.5L" (Indian lakh).
    static func short(_ rupees: Double) -> String {
        let value = abs(rupees)
        let text =
            switch value {
            case 100_000...: (value / 100_000).formatted(.number.precision(.fractionLength(0...1))) + "L"
            case 1_000...: (value / 1_000).formatted(.number.precision(.fractionLength(0...1))) + "k"
            default: value.formatted(.number.precision(.fractionLength(0)))
            }
        return "₹" + text
    }

    /// 12345678 -> "123456.78", for CSV.
    static func decimal(_ paise: Int64) -> String {
        "\(paise < 0 ? "-" : "")\(paise.magnitude / 100).\(String(format: "%02d", paise.magnitude % 100))"
    }

    /// "1,23,456.78" -> 12345678. Nil for anything that isn't a plain non-negative amount.
    static func paise(_ text: String) -> Int64? {
        let parts = text.replacingOccurrences(of: ",", with: "").split(separator: ".", omittingEmptySubsequences: false)
        guard (1...2).contains(parts.count), parts[0].count <= 13, let rupees = Int64(parts[0]) else { return nil }
        var fraction: Int64 = 0
        if parts.count == 2 {
            let digits = parts[1].prefix(2)
            guard !digits.isEmpty, let v = Int64(digits) else { return nil }
            fraction = digits.count == 1 ? v * 10 : v
        }
        return rupees * 100 + fraction
    }
}

extension Date {
    /// "Today", "Yesterday", "Sat, 1 Nov", or "Sat, 1 Nov 2025" when it's not this year.
    var dayLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(self) { return "Today" }
        if cal.isDateInYesterday(self) { return "Yesterday" }
        let sameYear = cal.isDate(self, equalTo: .now, toGranularity: .year)
        return formatted(
            sameYear
                ? .dateTime.weekday(.abbreviated).day().month(.abbreviated)
                : .dateTime.weekday(.abbreviated).day().month(.abbreviated).year())
    }

    /// "1 Nov", or "1 Nov 2025" when it's not this year.
    var shortDay: String {
        Calendar.current.isDate(self, equalTo: .now, toGranularity: .year)
            ? formatted(.dateTime.day().month(.abbreviated)) : formatted(.dateTime.day().month(.abbreviated).year())
    }
}

extension String {
    /// "Today" -> "today" inside a sentence; dates like "Sat, 1 Nov" stay as they are.
    var lowercasedFirstIfRelative: String { self == "Today" || self == "Yesterday" ? lowercased() : self }
}
