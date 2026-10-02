import SwiftUI

/// Leichtes Eindrücken beim Tippen.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Runder Icon-Button im Wallet-Header.
struct HeaderIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(Circle().fill(Color.white.opacity(0.14)))
            .contentShape(Circle())
    }
}

/// Logo für Splash und Sperrbildschirm (passt zum App-Icon).
struct AppLogoView: View {
    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: side * 0.225, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#2E2E33"), Color(hex: "#0A0A0C")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                RoundedRectangle(cornerRadius: side * 0.045, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#E2E5EA"), Color(hex: "#8E9299"), Color(hex: "#D1D4DA")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(alignment: .topLeading) {
                        ChipView()
                            .frame(width: side * 0.12, height: side * 0.09)
                            .padding(.top, side * 0.12)
                            .padding(.leading, side * 0.07)
                    }
                    .frame(width: side * 0.66, height: side * 0.42)
                    .rotationEffect(.degrees(-14))
                    .shadow(color: .black.opacity(0.5), radius: side * 0.04, y: side * 0.03)
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
