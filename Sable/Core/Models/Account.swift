import Foundation

struct AccountRow: Identifiable, Hashable {
    let id: Int64
    let bank: String
    let last4: String
    let isCard: Bool
    let nickname: String?
    let balance: Int64?
    var disabled = false
    var hidden = false

    /// Wallets and the Cash account have no number to show.
    var title: String { nickname ?? (Int(last4) == nil ? bank : "\(bank) ••\(last4)") }
    var isWallet: Bool { last4 == "Wallet" }
    var kindLabel: String { isCard ? "Credit card" : isWallet ? "Wallet" : "Bank account" }
    var symbol: String { isCard ? "creditcard" : isWallet ? "wallet.bifold" : "building.columns" }
    /// "••••••••4321"; wallets and Cash have no number, so they show what they are.
    var masked: String { Int(last4) == nil ? kindLabel : "••••••••" + last4 }
}
