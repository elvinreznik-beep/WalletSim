import SwiftUI
import UIKit

enum CardStyleKind: String, CaseIterable, Identifiable {
    case preset
    case gradient
    case photo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .preset: "Vorlage"
        case .gradient: "Verlauf"
        case .photo: "Foto"
        }
    }
}

/// Alles, was zum Zeichnen einer Karte nötig ist – unabhängig von SwiftData.
/// So nutzen Wallet, Editor-Vorschau und Thumbnails denselben Renderer.
struct CardFace {
    var title: String = ""
    var holderName: String = ""
    var last4: String = "0000"
    var expiryMonth: Int = 1
    var expiryYear: Int = 2030
    var networkLabel: String = ""
    var kind: CardStyleKind = .preset
    var preset: CardPreset = .obsidianMetal
    var gradientStart: Color = Color(hex: "#2B5876")
    var gradientEnd: Color = Color(hex: "#0B1A2E")
    var gradientAngle: Double = 135
    var gradientBrushed: Bool = false
    var image: UIImage?
    var imageScale: CGFloat = 1
    var imageOffset: CGSize = .zero
    var darkText: Bool = false

    var foreground: Color {
        switch kind {
        case .preset:
            preset.textColor
        case .gradient, .photo:
            darkText ? Color(hex: "#1D1D1F") : Color(hex: "#F5F5F7")
        }
    }

    var accent: Color {
        kind == .preset ? preset.accentColor : foreground
    }

    var isLightSurface: Bool {
        kind == .preset ? preset.isLightSurface : darkText
    }

    var holoIntensity: Double {
        switch kind {
        case .preset: preset.holoIntensity
        case .gradient: 0.22
        case .photo: 0.12
        }
    }

    var specularIntensity: Double {
        switch kind {
        case .preset: preset.specularIntensity
        case .gradient: 0.55
        case .photo: 0.4
        }
    }

    var expiryText: String {
        String(format: "%02ld/%02ld", expiryMonth, expiryYear % 100)
    }

    var displayHolder: String {
        let trimmed = holderName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "DEIN NAME" : trimmed.uppercased()
    }

    var displayLast4: String {
        last4.isEmpty ? "0000" : last4
    }

    static func preview(for preset: CardPreset) -> CardFace {
        CardFace(title: preset.displayName, kind: .preset, preset: preset)
    }
}
