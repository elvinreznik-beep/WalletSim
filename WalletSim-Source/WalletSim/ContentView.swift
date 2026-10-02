import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var walletViewModel = WalletViewModel()
    @State private var appLock = AppLockViewModel()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            WalletView(
                viewModel: walletViewModel,
                appLock: appLock,
                isRevealed: !showSplash && !appLock.isLocked
            )

            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(2)
            }

            if appLock.isLocked {
                LockView(viewModel: appLock)
                    .transition(.opacity)
                    .zIndex(3)
            }
        }
        .environment(\.locale, Formatters.locale)
        .task {
            MotionManager.shared.start()
            try? await Task.sleep(for: .milliseconds(1100))
            withAnimation(.easeOut(duration: 0.4)) {
                showSplash = false
            }
        }
        .onChange(of: scenePhase) { _, phase in
            appLock.handleScenePhase(phase)
            if phase == .active {
                MotionManager.shared.start()
            } else {
                MotionManager.shared.stop()
            }
        }
    }
}
