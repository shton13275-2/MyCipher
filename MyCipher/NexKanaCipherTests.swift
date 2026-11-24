import XCTest
@testable import MyCipher

final class NexKanaCipherTests: XCTestCase {
    let cipher = NexKanaCipher(symbols: Array(CipherRule.defaultSymbols))

    func testRoundTripAllKeys() {
        let text = "こんにちは がぎぐげご ぱぴぷぺぽ、わをん！"
        for key in 0...45 {
            let enc = cipher.encrypt(text, key: key)
            XCTAssertEqual(cipher.decrypt(enc, key: key), text, "key=\(key)")
        }
    }

    func testSingleCharKnownValue() {
        // あ: N=0, K=13 → C=13 → 7進数 "1","6" → △♧、清音マーカー○
        XCTAssertEqual(cipher.encrypt("あ", key: 13), "○△♧")
    }

    func testDakutenAndHandakuten() {
        // が: か(5)+13=18 → "2","4" → □◇、濁音マーカー△
        XCTAssertEqual(cipher.encrypt("が", key: 13), "△□◇")
        // ぱ: は(25)+13=38 → "5","3" → ♡☆、半濁音マーカー□
        XCTAssertEqual(cipher.encrypt("ぱ", key: 13), "□♡☆")
    }

    func testWordOrderIsReversed() {
        let ab = cipher.encrypt("あい", key: 13)
        let a = cipher.encrypt("あ", key: 13), i = cipher.encrypt("い", key: 13)
        XCTAssertEqual(ab, i + a)
    }

    func testKatakanaBecomesHiragana() {
        XCTAssertEqual(cipher.encrypt("カタカナ", key: 5), cipher.encrypt("かたかな", key: 5))
    }

    func testUnsupportedCharactersAreKept() {
        let enc = cipher.encrypt("ABC 漢字 あ1", key: 13)
        XCTAssertTrue(enc.hasPrefix("ABC 漢字 "))
        XCTAssertEqual(cipher.decrypt(enc, key: 13), "ABC 漢字 あ1")
    }

    func testBrokenInputDoesNotCrash() {
        _ = cipher.decrypt("○○", key: 13)
        _ = cipher.decrypt("☆☆☆♧♧♧", key: 13)
        _ = cipher.encrypt("", key: 99)
    }
}
