import Foundation

enum TxnKind: String {
    case normal  // counts as spending or income
    case refund  // money back from a merchant: reduces spending
    case transfer  // between your own accounts, or a card bill payment: not spending
    case reversed  // a payment and its reversal: both cancel out
}

struct ParsedTxn: Equatable {
    var amount: Int64  // paise, always positive
    var isCredit: Bool
    var bank: String?
    var last4: String?
    var isCard: Bool
    /// The card is a credit card (its own account); a debit card charges the bank account it's linked to.
    var creditCard = false
    var channel: String
    var ref: String?
    var name: String?
    var vpa: String?
    var date: Date
    var balance: Int64?  // paise, balance after this txn when the bank includes it
    var kind = TxnKind.normal
    var mandateKey: String?  // set on AutoPay / e-mandate debits
}

struct MandateEvent: Equatable {
    enum Kind: String { case created, upcoming, paused, resumed, cancelled }
    var kind: Kind
    var key: String  // UMN or mandate id when present, else the merchant name
    var name: String
    var amount: Int64?
    var frequency: String?
    var bank: String?
    var last4: String?
    var due: Date?  // only for "will be debited on ..." notices
    var at: Date
}

struct BalanceUpdate: Equatable {
    var bank: String?
    var last4: String
    var balance: Int64
    var at: Date
}

enum ParseResult: Equatable {
    case txn(ParsedTxn)
    case mandate(MandateEvent)
    case balance(BalanceUpdate)
    case ignored(String)
    case unrecognized(String)
}
