import SwiftUI

struct RuleListView: View {
    @EnvironmentObject var store: RuleStore

    var body: some View {
        List {
            ForEach(store.rules) { rule in
                NavigationLink { RuleEditView(rule: rule) } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.name).font(.headline)
                        Text(rule.detail.isEmpty ? "説明なし" : rule.detail)
                            .font(.footnote).foregroundColor(.secondary)
                    }
                }
                .listRowBackground(Theme.card)
            }
            .onDelete { store.delete(at: $0) }
        }
        .scrollContentBackground(.hidden)
        .background(AppBackdrop())
        .navigationTitle("暗号ルール")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink { RuleEditView(rule: nil) } label: { Image(systemName: "plus") }
            }
        }
    }
}
