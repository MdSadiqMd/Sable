import CryptoKit
import Foundation
import Security

/// Seals small private records (bank details) with AES-GCM. The 256-bit key is created on first use and kept in
/// this iPhone's Keychain, readable only while the phone is unlocked and never synced or backed up, so the
/// database on its own (or a Sable backup of it) can't be read anywhere else.
struct VaultError: Error {}

enum Vault {
    static func seal(_ plain: Data, key: SymmetricKey) throws -> String {
        guard let combined = try AES.GCM.seal(plain, using: key).combined else { throw VaultError() }
        return combined.base64EncodedString()
    }

    static func open(_ sealed: String, key: SymmetricKey) throws -> Data {
        guard let data = Data(base64Encoded: sealed) else { throw VaultError() }
        return try AES.GCM.open(AES.GCM.SealedBox(combined: data), using: key)
    }

    /// This phone's key, created the first time. Nil only if the Keychain refuses, in which case nothing is
    /// saved rather than saved unprotected.
    static func key() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.sadiq.sable.vault",
            kSecAttrAccount as String: "key",
        ]
        var found: CFTypeRef?
        if SecItemCopyMatching(query.merging([kSecReturnData as String: true]) { $1 } as CFDictionary, &found) == errSecSuccess,
            let data = found as? Data
        {
            return SymmetricKey(data: data)
        }
        let key = SymmetricKey(size: .bits256)
        let data = key.withUnsafeBytes { Data($0) }
        let add = query.merging([
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]) { $1 }
        return SecItemAdd(add as CFDictionary, nil) == errSecSuccess ? key : nil
    }
}
