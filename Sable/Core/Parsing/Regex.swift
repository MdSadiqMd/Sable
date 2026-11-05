import Foundation

/// Case-insensitive NSRegularExpression with the few helpers the parser needs.
struct Rx {
    let re: NSRegularExpression
    init(_ pattern: String) { re = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) }

    func first(_ s: String) -> NSTextCheckingResult? { re.firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) }
    func all(_ s: String) -> [NSTextCheckingResult] { re.matches(in: s, range: NSRange(s.startIndex..., in: s)) }
    func matches(_ s: String) -> Bool { first(s) != nil }
    func group(_ s: String, _ g: Int = 1) -> String? { first(s).flatMap { capture($0, g, s) } }
    func replacing(_ s: String, with t: String) -> String {
        re.stringByReplacingMatches(in: s, range: NSRange(s.startIndex..., in: s), withTemplate: t)
    }
}

func capture(_ m: NSTextCheckingResult, _ g: Int, _ s: String) -> String? {
    Range(m.range(at: g), in: s).map { String(s[$0]) }
}
