import SwiftUI
import SwiftData

@main
struct WalletSimApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Color(hex: "#D4B06A"))
        }
        .modelContainer(for: [Card.self, CardTransaction.self])
    }
}
