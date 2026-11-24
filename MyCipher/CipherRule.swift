import Foundation

/// 暗号方式（今は1種類。将来ここに追加できます）
enum CipherMethod: String, Codable, CaseIterable {
    case nexKana2 = "NEX-KANA 2"
}

/// 保存される暗号ルール1件
struct CipherRule: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var detail: String
    var method: CipherMethod
    var key: Int            // 0...45
    var symbols: String     // 7文字（0〜6に対応）
    var isPreset: Bool

    static let defaultSymbols = "○△□☆◇♡♧"
    /// 固定ID：プリセットの二重登録を防ぐために使う
    static let presetID = UUID(uuidString: "6E4E4B41-4E41-4E45-5832-000000000001")!

    static let nexKana2 = CipherRule(
        id: presetID,
        name: "NEX-KANA 2",
        detail: "ひらがな46文字を鍵でずらし、7進数の記号3つで表す初期ルール",
        method: .nexKana2,
        key: 13,
        symbols: defaultSymbols,
        isPreset: true
    )

    var symbolArray: [Character] { Array(symbols) }
}
