import Foundation

/// 暗号ルールの保存・読み込み（端末内のJSONファイル）
@MainActor
final class RuleStore: ObservableObject {
    @Published private(set) var rules: [CipherRule] = []

    private let fileURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("rules.json")
    }()
    private let seededKey = "didSeedPreset_NEXKANA2"

    init() {
        load()
        seedPresetIfNeeded()
    }

    func upsert(_ rule: CipherRule) {
        if let i = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[i] = rule
        } else {
            rules.append(rule)
        }
        save()
    }

    func delete(at offsets: IndexSet) {
        rules.remove(atOffsets: offsets)
        save()
    }

    private func seedPresetIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: seededKey) else { return }
        if !rules.contains(where: { $0.id == CipherRule.presetID }) {
            rules.insert(CipherRule.nexKana2, at: 0)
            save()
        }
        defaults.set(true, forKey: seededKey)
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CipherRule].self, from: data) else { return }
        rules = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(rules) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
