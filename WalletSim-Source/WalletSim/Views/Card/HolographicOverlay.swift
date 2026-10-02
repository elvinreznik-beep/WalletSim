import SwiftUI

/// Liest nur hier die Neigung – so wird bei Bewegung nur diese Ebene neu gezeichnet,
/// nicht die ganze Karte.
struct HolographicOverlay: View {
    let holo: Double
    let specular: Double
    let size: CGSize
    let isInteractive: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let rainbow: [Color] = [
        Color(red: 1.00, green: 0.45, blue: 0.75),
        Color(red: 1.00, green: 0.86, blue: 0.40),
        Color(red: 0.45, green: 1.00, blue: 0.78),
        Color(red: 0.35, green: 0.75, blue: 1.00),
        Color(red: 0.76, green: 0.50, blue: 1.00),
        Color(red: 1.00, green: 0.45, blue: 0.75)
    ]

    var body: some View {
        let tilt = (isInteractive && !reduceMotion) ? MotionManager.shared.tilt : CGPoint(x: 0.15, y: -0.1)
        let shift = tilt.x * 0.55 + tilt.y * 0.25

        ZStack {
            // Irisierender Film
            LinearGradient(
                colors: Self.rainbow,
                startPoint: UnitPoint(x: -0.6 + tilt.x * 0.7, y: -0.4 + tilt.y * 0.5),
                endPoint: UnitPoint(x: 1.6 + tilt.x * 0.7, y: 1.4 + tilt.y * 0.5)
            )
            .blendMode(.overlay)
            .opacity(holo)

            // Wandernder Lichtstreifen
            LinearGradient(
                stops: [
                    .init(color: .white.opacity(0), location: 0.30),
                    .init(color: .white.opacity(0.6), location: 0.50),
                    .init(color: .white.opacity(0), location: 0.70)
                ],
                startPoint: UnitPoint(x: -0.4 + shift, y: -0.2 + shift * 0.4),
                endPoint: UnitPoint(x: 1.0 + shift, y: 1.2 + shift * 0.4)
            )
            .blendMode(.softLight)
            .opacity(specular)

            // Glanzpunkt
            RadialGradient(
                colors: [.white.opacity(0.5), .white.opacity(0)],
                center: UnitPoint(x: 0.5 + tilt.x * 0.6, y: 0.25 + tilt.y * 0.6),
                startRadius: 0,
                endRadius: max(size.width * 0.75, 1)
            )
            .blendMode(.screen)
            .opacity(specular * 0.35)
        }
        .allowsHitTesting(false)
    }
}
