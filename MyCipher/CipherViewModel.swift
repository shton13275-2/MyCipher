import Foundation
import UIKit

enum CipherMode {
    case encrypt, decrypt
    var title: String { self == .encrypt ? "暗号化" : "復号" }
}

@MainActor
final class CipherViewModel: ObservableObject {
    @Published var input = ""
    @Published var output = ""
    @Published var keyText = "13"
    @Published var passphrase = ""
    @Published var selectedMethod: CipherMethod = .nexKana2
    @Published var selectedRuleID: UUID?
    @Published var errorMessage: String?

    func selectRule(_ rule: CipherRule?) {
        selectedRuleID = rule?.id
        if let rule { keyText = String(rule.key) }
    }

    func run(mode: CipherMode, rule: CipherRule?) {
        errorMessage = nil
        output = ""

        switch selectedMethod {
        case .aesGcm:
            guard !passphrase.isEmpty else {
                errorMessage = "パスフレーズを入力してください"; return
            }
            if mode == .encrypt && passphrase.count < 8 {
                errorMessage = "暗号化には8文字以上のパスフレーズを使用してください"; return
            }
            do {
                output = mode == .encrypt
                    ? try AESGCMCipher.encrypt(input, passphrase: passphrase)
                    : try AESGCMCipher.decrypt(input, passphrase: passphrase)
            } catch {
                errorMessage = error.localizedDescription
            }

        case .nexKana2:
            guard let rule else { errorMessage = "ルールを選んでください"; return }
            guard let key = Int(keyText), (0...45).contains(key) else {
                errorMessage = "鍵は0〜45の数字で入力してください"; return
            }
            let cipher = NexKanaCipher(symbols: rule.symbolArray)
            guard NexKanaCipher.isValidSymbolSet(cipher.symbols) else {
                errorMessage = "このルールの記号セットが正しくありません（重複なしの7文字が必要）"; return
            }
            output = mode == .encrypt ? cipher.encrypt(input, key: key)
                                      : cipher.decrypt(input, key: key)
        }
    }

    func copy() { UIPasteboard.general.string = output }

    func clear() {
        input = ""
        output = ""
        passphrase = ""
        errorMessage = nil
    }
}
