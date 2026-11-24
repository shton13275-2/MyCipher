import SwiftUI

/// ルールの新規作成・編集（rule が nil なら新規）
struct RuleEditView: View {
    @EnvironmentObject var store: RuleStore
    @Environment(\.dismiss) private var dismiss

    private let original: CipherRule?
    @State private var name: String
    @State private var detail: String
    @State private var key: Int
    @State private var symbols: String
    @State private var errorMessage: String?

    init(rule: CipherRule?) {
        original = rule
        _name = State(initialValue: rule?.name ?? "")
        _detail = State(initialValue: rule?.detail ?? "")
        _key = State(initialValue: rule?.key ?? 13)
        _symbols = State(initialValue: rule?.symbols ?? CipherRule.defaultSymbols)
    }

    var body: some View {
        Form {
            Section("ルール名") { TextField("例：秘密ノート用", text: $name) }
            Section("説明") { TextField("メモ（任意）", text: $detail) }
            Section("暗号方式") { Text(CipherMethod.nexKana2.rawValue) }
            Section("鍵") { Stepper("鍵：\(key)", value: $key, in: 0...45) }
            Section {
                TextField("○△□☆◇♡♧", text: $symbols)
                    .font(.system(.body, design: .monospaced))
            } header: {
                Text("記号セット（重複しない7文字）")
            } footer: {
                Text("左から 0〜6 に対応します。最初の3つは清音・濁音・半濁音の目印にも使われます。")
            }
            if let errorMessage {
                Text(errorMessage).foregroundColor(.red)
            }
            Section {
                Button("保存") { save() }
                    .buttonStyle(PrimaryButtonStyle())
                    .listRowInsets(EdgeInsets())
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppBackdrop())
        .navigationTitle(original == nil ? "ルール作成" : "ルール編集")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { errorMessage = "ルール名を入力してください"; return }
        guard NexKanaCipher.isValidSymbolSet(Array(symbols)) else {
            errorMessage = "記号セットは重複しない7文字にしてください"; return
        }
        store.upsert(CipherRule(
            id: original?.id ?? UUID(),
            name: trimmed, detail: detail, method: .nexKana2,
            key: key, symbols: symbols, isPreset: original?.isPreset ?? false))
        dismiss()
    }
}
