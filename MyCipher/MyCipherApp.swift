import SwiftUI

@main
struct MyCipherApp: App {
    @StateObject private var store = RuleStore()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(Theme.accent)
        }
    }
}
