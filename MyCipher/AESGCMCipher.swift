import Foundation
import CryptoKit
import CommonCrypto

/// Password-based AES-GCM encryption for MyCipher.
/// Format: MC-AESGCM1:<base64(salt[16] || CryptoKit combined box)>
enum AESGCMCipher {
    static let formatPrefix = "MC-AESGCM1:"
    private static let saltLength = 16
    private static let keyLength = 32
    private static let rounds: UInt32 = 200_000

    enum CipherError: Error, LocalizedError {
        case emptyPassphrase
        case invalidFormat
        case authenticationFailed
        case keyDerivationFailed

        var errorDescription: String? {
            switch self {
            case .emptyPassphrase: return "パスフレーズを入力してください。"
            case .invalidFormat: return "AES暗号文の形式が正しくありません。"
            case .authenticationFailed: return "復号できませんでした。パスフレーズが違うか、暗号文が破損しています。"
            case .keyDerivationFailed: return "鍵の生成に失敗しました。"
            }
        }
    }

    static func encrypt(_ plaintext: String, passphrase: String) throws -> String {
        guard !passphrase.isEmpty else { throw CipherError.emptyPassphrase }
        let salt = randomData(count: saltLength)
        let key = try deriveKey(passphrase: passphrase, salt: salt)
        let nonce = AES.GCM.Nonce()
        let sealed = try AES.GCM.seal(Data(plaintext.utf8), using: key, nonce: nonce)
        guard let combined = sealed.combined else { throw CipherError.invalidFormat }
        return formatPrefix + (salt + combined).base64EncodedString()
    }

    static func decrypt(_ ciphertext: String, passphrase: String) throws -> String {
        guard !passphrase.isEmpty else { throw CipherError.emptyPassphrase }
        guard ciphertext.hasPrefix(formatPrefix),
              let payload = Data(base64Encoded: String(ciphertext.dropFirst(formatPrefix.count))),
              payload.count > saltLength else {
            throw CipherError.invalidFormat
        }

        let salt = payload.prefix(saltLength)
        let combined = payload.dropFirst(saltLength)
        let key = try deriveKey(passphrase: passphrase, salt: Data(salt))
        guard let sealed = try? AES.GCM.SealedBox(combined: Data(combined)) else {
            throw CipherError.invalidFormat
        }
        do {
            let plaintext = try AES.GCM.open(sealed, using: key)
            guard let text = String(data: plaintext, encoding: .utf8) else {
                throw CipherError.authenticationFailed
            }
            return text
        } catch {
            throw CipherError.authenticationFailed
        }
    }

    private static func deriveKey(passphrase: String, salt: Data) throws -> SymmetricKey {
        var derived = [UInt8](repeating: 0, count: keyLength)
        let status = passphrase.withCString { passwordPointer in
            salt.withUnsafeBytes { saltBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passwordPointer,
                    passphrase.utf8.count,
                    saltBytes.bindMemory(to: UInt8.self).baseAddress,
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    rounds,
                    &derived,
                    derived.count
                )
            }
        }
        guard status == kCCSuccess else { throw CipherError.keyDerivationFailed }
        return SymmetricKey(data: derived)
    }

    private static func randomData(count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)
        return Data(bytes)
    }
}
