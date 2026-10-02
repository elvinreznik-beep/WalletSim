import SwiftUI

/// Die komplette Karte. Wird überall genutzt: Wallet-Stapel, Editor, Thumbnails.
struct CardView: View {
    let face: CardFace
    var isInteractive: Bool = true
    var showsDetails: Bool = true

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let shape = RoundedRectangle(cornerRadius: size.width * CardMetrics.cornerRatio, style: .continuous)

            CardBackgroundView(face: face, size: size)
                .frame(width: size.width, height: size.height)
                .overlay {
                    HolographicOverlay(
                        holo: face.holoIntensity,
                        specular: face.specularIntensity,
                        size: size,
                        isInteractive: isInteractive
                    )
                }
                .overlay {
                    CardContentView(face: face, size: size, showsDetails: showsDetails)
                }
                .clipShape(shape)
                .overlay {
                    shape.strokeBorder(edgeGradient, lineWidth: max(0.5, size.width * 0.0035))
                }
                .compositingGroup()
                .shadow(color: .black.opacity(0.45), radius: size.width * 0.03, x: 0, y: size.width * 0.02)
        }
        .aspectRatio(CardMetrics.aspectRatio, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "\(face.title), Karte endet auf \(face.displayLast4)"))
    }

    private var edgeGradient: LinearGradient {
        LinearGradient(
            colors: face.isLightSurface
                ? [.white.opacity(0.9), .white.opacity(0.2), .black.opacity(0.25)]
                : [.white.opacity(0.35), .white.opacity(0.05), .black.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct CardContentView: View {
    let face: CardFace
    let size: CGSize
    var showsDetails: Bool = true

    private func scaled(_ factor: CGFloat) -> CGFloat {
        max(1, size.width * factor)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(verbatim: face.title.uppercased())
                    .font(.system(size: scaled(0.05), weight: .semibold))
                    .tracking(scaled(0.008))
                    .foregroundStyle(face.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer(minLength: scaled(0.04))
                Image(systemName: "wave.3.right")
                    .font(.system(size: scaled(0.052), weight: .semibold))
                    .foregroundStyle(face.foreground.opacity(0.75))
            }

            Spacer(minLength: 0)

            ChipView()
                .frame(width: scaled(0.13), height: scaled(0.098))

            Spacer(minLength: 0)

            if showsDetails {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: scaled(0.018)) {
                        Text(verbatim: "••••  " + face.displayLast4)
                            .font(.system(size: scaled(0.058), weight: .medium, design: .monospaced))
                            .tracking(scaled(0.004))
                            .embossed(on: face.isLightSurface)
                        Text(verbatim: face.displayHolder)
                            .font(.system(size: scaled(0.04), weight: .medium))
                            .tracking(scaled(0.004))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .embossed(on: face.isLightSurface)
                    }
                    .foregroundStyle(face.foreground)

                    Spacer(minLength: scaled(0.03))

                    VStack(alignment: .trailing, spacing: scaled(0.012)) {
                        HStack(alignment: .center, spacing: scaled(0.012)) {
                            Text(verbatim: "VALID\nTHRU")
                                .font(.system(size: scaled(0.017), weight: .semibold))
                                .multilineTextAlignment(.trailing)
                                .lineSpacing(0)
                            Text(verbatim: face.expiryText)
                                .font(.system(size: scaled(0.04), weight: .medium, design: .monospaced))
                                .embossed(on: face.isLightSurface)
                        }
                        .foregroundStyle(face.foreground)

                        Text(verbatim: face.networkLabel.uppercased())
                            .font(.system(size: scaled(0.052), weight: .heavy).italic())
                            .foregroundStyle(face.accent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            } else {
                Color.clear.frame(height: scaled(0.06))
            }
        }
        .padding(scaled(0.065))
        .frame(width: size.width, height: size.height, alignment: .topLeading)
    }
}

struct EmbossedModifier: ViewModifier {
    let lightSurface: Bool

    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(lightSurface ? 0.25 : 0.55), radius: 0.5, x: 0.6, y: 0.9)
            .shadow(color: .white.opacity(lightSurface ? 0.7 : 0.25), radius: 0.3, x: -0.4, y: -0.6)
    }
}

extension View {
    /// Leichter Präge-Effekt wie bei echten Metallkarten.
    func embossed(on lightSurface: Bool) -> some View {
        modifier(EmbossedModifier(lightSurface: lightSurface))
    }
}
