import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: RuleStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("MyCipher")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(Theme.accent)
                    Text("自分だけの暗号ルールで日本語を変換")
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        NavigationLink { CipherView(mode: .encrypt) } label: {
                            Label("暗号化", systemImage: "lock.fill")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        NavigationLink { CipherView(mode: .decrypt) } label: {
                            Label("復号", systemImage: "lock.open.fill")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }

                    HStack {
                        Text("保存した暗号ルール").font(.headline)
                        Spacer()
                        NavigationLink("すべて見る") { RuleListView() }
                            .font(.subheadline)
                    }

                    ForEach(store.rules) { rule in
                        NavigationLink { RuleEditView(rule: rule) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rule.name).font(.headline).foregroundColor(.white)
                                Text("鍵 \(rule.key)　\(rule.symbols)")
                                    .font(.system(.footnote, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                            .card()
                        }
                    }

                    NavigationLink { RuleEditView(rule: nil) } label: {
                        Label("暗号ルールを作成", systemImage: "plus")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    DisclaimerView()
                }
                .padding(20)
            }
            .background(AppBackdrop())
        }
    }
}
