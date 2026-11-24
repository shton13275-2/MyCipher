import Foundation

/// NEX-KANA 2 の暗号ロジック（画面とは完全に独立）
///
/// 1文字 = 3記号：[マーカー][7進数の上の桁][7進数の下の桁]
/// マーカー: 清音=symbols[0] / 濁音=symbols[1] / 半濁音=symbols[2]
/// 連続して変換できた文字の並び（単語）ごとにトークン順を逆にする。
/// 未対応文字（小文字・長音・漢字・英数字など）はそのまま残す。
struct NexKanaCipher {
    static let kana: [Character] = Array(
        "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん")
    static let modulus = 46

    private static let dakutenPairs: [Character: Character] = {
        let plain = Array("かきくけこさしすせそたちつてとはひふへほ")
        let voiced = Array("がぎぐげござじずぜぞだぢづでどばびぶべぼ")
        return Dictionary(uniqueKeysWithValues: zip(plain, voiced))
    }()
    private static let handakutenPairs: [Character: Character] = {
        Dictionary(uniqueKeysWithValues: zip(Array("はひふへほ"), Array("ぱぴぷぺぽ")))
    }()
    /// 濁音・半濁音 → (清音, マーカー)
    private static let reverseMarks: [Character: (Character, Int)] = {
        var d: [Character: (Character, Int)] = [:]
        for (p, v) in dakutenPairs { d[v] = (p, 1) }
        for (p, v) in handakutenPairs { d[v] = (p, 2) }
        return d
    }()

    let symbols: [Character]

    /// 記号セットが「7個・重複なし」かどうか
    static func isValidSymbolSet(_ s: [Character]) -> Bool {
        s.count == 7 && Set(s).count == 7
    }

    // MARK: 暗号化
    func encrypt(_ text: String, key: Int) -> String {
        guard Self.isValidSymbolSet(symbols) else { return text }
        let k = ((key % 46) + 46) % 46
        var result = ""
        var run: [String] = []

        func flush() {
            result += run.reversed().joined()
            run.removeAll()
        }

        for ch in text {
            if let token = encryptToken(Self.toHiragana(ch), key: k) {
                run.append(token)
            } else {
                flush()
                result.append(ch)
            }
        }
        flush()
        return result
    }

    private func encryptToken(_ ch: Character, key: Int) -> String? {
        var base = ch
        var marker = 0
        if let (b, m) = Self.reverseMarks[ch] { base = b; marker = m }
        guard let n = Self.kana.firstIndex(of: base) else { return nil }
        let c = (n + key) % Self.modulus
        return String([symbols[marker], symbols[c / 7], symbols[c % 7]])
    }

    // MARK: 復号
    func decrypt(_ text: String, key: Int) -> String {
        guard Self.isValidSymbolSet(symbols) else { return text }
        let k = ((key % 46) + 46) % 46
        var digit: [Character: Int] = [:]
        for (i, s) in symbols.enumerated() { digit[s] = i }

        var result = ""
        var run: [Character] = []

        func flush() {
            let count = run.count / 3
            var tokens: [String] = []
            for i in 0..<count {
                let chunk = Array(run[(i * 3)..<(i * 3 + 3)])
                tokens.append(decryptToken(chunk, key: k, digit: digit) ?? String(chunk))
            }
            result += tokens.reversed().joined()
            result += String(run[(count * 3)...])   // 3で割り切れない余りはそのまま
            run.removeAll()
        }

        for ch in text {
            if digit[ch] != nil {
                run.append(ch)
            } else {
                flush()
                result.append(ch)
            }
        }
        flush()
        return result
    }

    private func decryptToken(_ chunk: [Character], key: Int, digit: [Character: Int]) -> String? {
        guard let m = digit[chunk[0]], let hi = digit[chunk[1]], let lo = digit[chunk[2]],
              m <= 2 else { return nil }
        let c = hi * 7 + lo
        guard c < Self.modulus else { return nil }
        let n = (c - key + Self.modulus) % Self.modulus
        let base = Self.kana[n]
        switch m {
        case 1: return Self.dakutenPairs[base].map(String.init)
        case 2: return Self.handakutenPairs[base].map(String.init)
        default: return String(base)
        }
    }

    // MARK: カタカナ → ひらがな
    private static func toHiragana(_ ch: Character) -> Character {
        guard ch.unicodeScalars.count == 1, let s = ch.unicodeScalars.first,
              (0x30A1...0x30F6).contains(s.value),
              let h = Unicode.Scalar(s.value - 0x60) else { return ch }
        return Character(h)
    }
}
