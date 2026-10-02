import SwiftUI
import UIKit

struct CardBackgroundView: View {
    let face: CardFace
    let size: CGSize

    var body: some View {
        switch face.kind {
        case .preset:
            PresetBackground(preset: face.preset, size: size)
        case .gradient:
            GradientBackground(
                start: face.gradientStart,
                end: face.gradientEnd,
                angle: face.gradientAngle,
                brushed: face.gradientBrushed
            )
        case .photo:
            if let image = face.image {
                CardImageLayer(image: image, scale: face.imageScale, offset: face.imageOffset)
                    .overlay {
                        // Leichte Abdunklung unten, damit helle Schrift lesbar bleibt.
                        LinearGradient(
                            colors: [.black.opacity(0), .black.opacity(face.darkText ? 0 : 0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            } else {
                PhotoPlaceholderBackground()
            }
        }
    }
}

// MARK: - Vorlagen

struct PresetBackground: View {
    let preset: CardPreset
    let size: CGSize

    var body: some View {
        LinearGradient(colors: preset.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay { finishLayer }
            .overlay { decoration }
    }

    @ViewBuilder
    private var finishLayer: some View {
        switch preset.finish {
        case .brushed:
            Image(uiImage: TextureFactory.brushedMetal)
                .resizable()
                .blendMode(.overlay)
                .opacity(preset.textureOpacity)
        case .grain:
            Image(uiImage: TextureFactory.grain)
                .resizable(resizingMode: .tile)
                .blendMode(.softLight)
                .opacity(preset.textureOpacity)
        case .gloss:
            LinearGradient(
                colors: [.white.opacity(0.26), .white.opacity(0), .white.opacity(0.08), .white.opacity(0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    private var decoration: some View {
        let w = size.width
        switch preset {
        case .midnightReserve:
            RoundedRectangle(cornerRadius: w * 0.035, style: .continuous)
                .strokeBorder(Color(hex: "#C9A45C").opacity(0.5), lineWidth: max(0.5, w * 0.0028))
                .padding(w * 0.028)
        case .sapphireBlue:
            ZStack {
                ForEach(0..<6, id: \.self) { ring in
                    let diameter = w * (0.45 + CGFloat(ring) * 0.17)
                    Circle()
                        .stroke(Color.white.opacity(0.07), lineWidth: max(0.5, w * 0.004))
                        .frame(width: diameter, height: diameter)
                }
            }
            .offset(x: w * 0.38, y: w * 0.08)
        case .emerald:
            DiagonalLinesShape(spacing: max(3, w * 0.022))
                .stroke(Color.white.opacity(0.05), lineWidth: max(0.5, w * 0.002))
        default:
            EmptyView()
        }
    }
}

// MARK: - Eigener Verlauf

struct GradientBackground: View {
    let start: Color
    let end: Color
    let angle: Double
    let brushed: Bool

    var body: some View {
        let points = GradientMath.points(for: angle)
        LinearGradient(colors: [start, end], startPoint: points.start, endPoint: points.end)
            .overlay {
                LinearGradient(
                    colors: [.white.opacity(0.18), .white.opacity(0), .black.opacity(0.18)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .blendMode(.softLight)
            }
            .overlay {
                if brushed {
                    Image(uiImage: TextureFactory.brushedMetal)
                        .resizable()
                        .blendMode(.overlay)
                        .opacity(0.4)
                }
            }
    }
}

// MARK: - Foto

/// Zeigt ein Foto mit Zoom/Versatz. `offset` ist relativ zur Kartenbreite,
/// damit es in jeder Größe (Wallet, Editor, Thumbnail) gleich aussieht.
struct CardImageLayer: View {
    let image: UIImage
    let scale: CGFloat
    let offset: CGSize

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .scaleEffect(scale)
                .offset(x: offset.width * size.width, y: offset.height * size.width)
                .frame(width: size.width, height: size.height)
                .clipped()
        }
    }
}

struct PhotoPlaceholderBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(hex: "#3A3A3C"), Color(hex: "#1C1C1E")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "photo")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(.white.opacity(0.25))
        }
    }
}
