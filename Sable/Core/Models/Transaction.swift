import Foundation

struct TxnRow: Identifiable, Hashable {
    let id: Int64
    let amount: Int64
    let isCredit: Bool
    let channel: String
    let ref: String?
    let name: String  // this payment's title, else your name for the payee, else what the SMS said
    let smsName: String?  // the name or UPI ID as the SMS wrote it
    let vpa: String?
    let payeeKey: String?
    let at: Date
    let accountId: Int64
    let account: String
    let categoryId: Int64?
    let kind: TxnKind
    /// 0 none, 1 lent (you gave it), 2 borrowed (you took it); repayments carry the same kind.
    let debtKind: Int
    var debt: Bool { debtKind != 0 }
    let hidden: Bool
    let note: String?
    let title: String?
    let raw: String?
    let seenCount: Int
    let dupOf: Int64?
    let mandateId: Int64?
    let sharedOut: Int64  // friends' part of a split bill
    let shareId: Int64?  // set on the payment that settled someone's share
    /// yyyymm of the pay this payment moved on (or, for the pay itself, the month it's for); nil for everything else.
    let salaryMonth: Int?

    /// Spending is what most rows are, so it carries no sign; money coming in is marked "+".
    var signedAmount: String { (isCredit ? "+" : "") + Money.format(amount) }

    /// Your pay itself (a credit the salary rule attributed to a month): kept behind the passcode.
    var isPay: Bool { isCredit && salaryMonth != nil }

    /// Green is for money that actually came in. Transfers between your accounts and reversals stay neutral.
    var isIncome: Bool { isCredit && (kind == .normal || kind == .refund) && !hidden }
}

struct TxnFilter: Equatable {
    enum Mode: String, CaseIterable {
        case all = "All"
        case spent = "Spent"
        case received = "Received"
        case debts = "Debts"
        case uncategorized = "Uncategorised"
    }

    var search = ""
    var mode = Mode.all
    var account: Int64?
    var category: Int64?
    var payee: String?
    var mandate: Int64?
    var since: Date?
    var until: Date?
    var limit = 300
}
