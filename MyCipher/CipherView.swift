import SwiftUI

/// Encryption and decryption screen. Supports NEX-KANA 2 and AES-GCM.
struct CipherView: View {
    let mode: CipherMode
    @EnvironmentObject var store: RuleStore
    @StateObject private var vm = CipherViewModel()

    private var selectedRule: CipherRule? {
        store.rules.first { $0.id == vm.selectedRuleID && $0.method == .nexKana2 }
    }

    private var kanaRules: [CipherRule] {
        store.rules.filter { $0.method == .nexKana2 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("暗号方式").font(.subheadline).foregroundColor(.secondary)
                    Picker("暗号方式", selection: $vm.selectedMethod) {
                        ForEach(CipherMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .card()

                if vm.selectedMethod == .nexKana2 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ルール").font(.subheadline).foregroundColor(.secondary)
                        Picker("ルール", selection: $vm.selectedRuleID) {
                            ForEach(kanaRules) { Text($0.name).tag(Optional($0.id)) }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .card()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("鍵（0〜45）").font(.subheadline).foregroundColor(.secondary)
                        TextField("13", text: $vm.keyText)
                            .keyboardType(.numberPad)
                            .font(.system(.body, design: .monospaced))
                    }
                    .card()
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("パスフレーズ").font(.subheadline).foregroundColor(.secondary)
                        SecureField("8文字以上を推奨", text: $vm.passphrase)
                            .textContentType(.password)
                        Text(mode == .encrypt
                             ? "暗号化には8文字以上のパスフレーズを使用してください。パスフレーズは保存されません。"
                             : "暗号化時に使用したパスフレーズを入力してください。")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .card()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(mode == .encrypt ? "文章" : "暗号文")
                        .font(.subheadline).foregroundColor(.secondary)
                    TextEditor(text: $vm.input)
                        .scrollContentBackground(.hidden)
                        .font(mode == .decrypt ? .system(.body, design: .monospaced) : .body)
                        .frame(minHeight: 120)
                }
                .card()

                Button(mode.title) { vm.run(mode: mode, rule: selectedRule) }
                    .buttonStyle(PrimaryButtonStyle())

                if let error = vm.errorMessage {
                    Text(error).font(.footnote).foregroundColor(.red)
                }

                if !vm.output.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("結果").font(.subheadline).foregroundColor(.secondary)
                        Text(vm.output)
                            .font(.system(.title3, design: .monospaced))
                            .textSelection(.enabled)
                        HStack(spacing: 10) {
                            Button { vm.copy() } label: { Label("コピー", systemImage: "doc.on.doc") }
                                .buttonStyle(SecondaryButtonStyle())
                            if mode == .encrypt {
                                ShareLink(item: vm.output) { Label("共有", systemImage: "square.and.arrow.up") }
                                    .buttonStyle(SecondaryButtonStyle())
                            }
                        }
                    }
                    .card()
                }

                Button("クリア") { vm.clear() }
                    .buttonStyle(SecondaryButtonStyle())

                DisclaimerView()
            }
            .padding(20)
        }
        .background(AppBackdrop())
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if vm.selectedRuleID == nil { vm.selectRule(kanaRules.first) }
        }
        .onChange(of: vm.selectedRuleID) { _, _ in
            if let r = selectedRule { vm.keyText = String(r.key) }
        }
    }
}
