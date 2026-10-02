import SwiftUI

enum CardFinish {
    case brushed
    case grain
    case gloss
}

/// Fiktive Premium-Designs. Bewusst ohne echte Bank- oder Netzwerk-Logos.
enum CardPreset: String, CaseIterable, Identifiable {
    case obsidianMetal
    case platinumMirror
    case roseGold
    case midnightReserve
    case sapphireBlue
    case titanium
    case emerald

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .obsidianMetal: "Obsidian Metal"
        case .platinumMirror: "Platinum Mirror"
        case .roseGold: "Rose Gold"
        case .midnightReserve: "Midnight Reserve"
        case .sapphireBlue: "Sapphire Blue"
        case .titanium: "Titanium"
        case .emerald: "Emerald"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .obsidianMetal:
            [Color(hex: "#2C2C30"), Color(hex: "#121214"), Color(hex: "#1E1E21"), Color(hex: "#08080A")]
        case .platinumMirror:
            [Color(hex: "#F5F6F8"), Color(hex: "#C5C9D0"), Color(hex: "#EEF0F3"), Color(hex: "#A7ACB4"), Color(hex: "#DCDFE4")]
        case .roseGold:
            [Color(hex: "#F8DCCF"), Color(hex: "#E1A691"), Color(hex: "#F4CBB8"), Color(hex: "#C58672")]
        case .midnightReserve:
            [Color(hex: "#1C2B57"), Color(hex: "#0E1839"), Color(hex: "#17244C"), Color(hex: "#070D25")]
        case .sapphireBlue:
            [Color(hex: "#2F74DC"), Color(hex: "#123F8F"), Color(hex: "#1B58BB"), Color(hex: "#0A2865")]
        case .titanium:
            [Color(hex: "#8D9095"), Color(hex: "#5D6065"), Color(hex: "#7B7E83"), Color(hex: "#44464A")]
        case .emerald:
            [Color(hex: "#15845F"), Color(hex: "#0B4F3B"), Color(hex: "#106D51"), Color(hex: "#052F20")]
        }
    }

    var finish: CardFinish {
        switch self {
        case .obsidianMetal, .midnightReserve, .emerald: .grain
        case .platinumMirror, .roseGold, .titanium: .brushed
        case .sapphireBlue: .gloss
        }
    }

    var textureOpacity: Double {
        switch self {
        case .platinumMirror: 0.45
        case .roseGold: 0.35
        case .titanium: 0.55
        case .obsidianMetal: 0.32
        case .midnightReserve: 0.22
        case .emerald: 0.22
        case .sapphireBlue: 0
        }
    }

    /// Farbe für Nummer, Name und Ablaufdatum.
    var textColor: Color {
        switch self {
        case .platinumMirror: Color(hex: "#2C2F35")
        case .roseGold: Color(hex: "#5A2E22")
        default: Color(hex: "#F2F2F4")
        }
    }

    /// Farbe für Kartentitel und Netzwerk-Label.
    var accentColor: Color {
        switch self {
        case .obsidianMetal: Color(hex: "#C3C7CD")
        case .platinumMirror: Color(hex: "#3A3E45")
        case .roseGold: Color(hex: "#6B3628")
        case .midnightReserve: Color(hex: "#D4B06A")
        case .sapphireBlue: Color(hex: "#E8F0FF")
        case .titanium: Color(hex: "#E6E7EA")
        case .emerald: Color(hex: "#E3C77E")
        }
    }

    var isLightSurface: Bool {
        self == .platinumMirror || self == .roseGold
    }

    var holoIntensity: Double {
        switch self {
        case .platinumMirror: 0.38
        case .roseGold: 0.3
        case .titanium: 0.26
        case .sapphireBlue: 0.24
        case .obsidianMetal: 0.16
        case .midnightReserve: 0.2
        case .emerald: 0.2
        }
    }

    var specularIntensity: Double {
        switch self {
        case .platinumMirror: 0.95
        case .roseGold: 0.8
        case .titanium: 0.7
        case .sapphireBlue: 0.6
        case .obsidianMetal: 0.45
        case .midnightReserve: 0.5
        case .emerald: 0.5
        }
    }
}
