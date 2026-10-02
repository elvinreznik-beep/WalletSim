import SwiftUI

struct LockView: View {
    let viewModel: AppLockViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                AppLogoView()
                    .frame(width: 92, height: 92)

                VStack(spacing: 6) {
                    Text("Wallet Sim ist gesperrt")
                        .font(.title3.weight(.semibold))
                    if let message = viewModel.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Button {
                    Task { await viewModel.unlock() }
                } label: {
                    Label("Entsperren", systemImage: "faceid")
                        .font(.headline)
                        .padding(.horizontal, 12)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(viewModel.isAuthenticating)
            }
            .padding(32)
        }
        .task {
            await viewModel.unlock()
        }
    }
}

struct SplashView: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                AppLogoView()
                    .frame(width: 112, height: 112)
                    .scaleEffect(appeared ? 1 : 0.86)
                    .opacity(appeared ? 1 : 0)

                Text("Wallet Sim")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .opacity(appeared ? 0.9 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.72)) {
                appeared = true
            }
        }
    }
}
