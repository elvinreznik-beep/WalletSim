import Foundation
import SwiftData
import SwiftUI
import UIKit

/// Eine simulierte Karte. Enums werden als String gespeichert,
/// damit SwiftData-Migrationen und Concurrency-Checks unkompliziert bleiben.
@Model
final class Card {
    var id: UUID = UUID()
    var sortIndex: Int = 0
    var createdAt: Date = Date()

    // Kartendaten
    var title: String = ""
    var holderName: String = ""
    var last4: String = "0000"
    var expiryMonth: Int = 1
    var expiryYear: Int = 2030
    var networkLabel: String = ""

    // Design
    var styleKindRaw: String = "preset"
    var presetRaw: String = "obsidianMetal"
    var gradientStartHex: String = "#2B5876"
    var gradientEndHex: String = "#0B1A2E"
    var gradientAngle: Double = 135
    var gradientBrushed: Bool = false
    var darkText: Bool = false

    // Eigenes Foto
    @Attribute(.externalStorage) var imageData: Data?
    var imageToken: String = ""
    var imageScale: Double = 1
    var imageOffsetX: Double = 0
    var imageOffsetY: Double = 0

    // Simuliertes Guthaben
    var creditLimit: Double = 10000
    var balance: Double = 0

    @Relationship(deleteRule: .cascade, inverse: \CardTransaction.card)
    var transactions: [CardTransaction] = []

    init() {}

    // MARK: - Abgeleitete Werte (werden nicht gespeichert)

    var styleKind: CardStyleKind {
        get { CardStyleKind(rawValue: styleKindRaw) ?? .preset }
        set { styleKindRaw = newValue.rawValue }
    }

    var preset: CardPreset {
        get { CardPreset(rawValue: presetRaw) ?? .obsidianMetal }
        set { presetRaw = newValue.rawValue }
    }

    var availableCredit: Double {
        creditLimit - balance
    }

    var utilization: Double {
        creditLimit > 0 ? balance / creditLimit : 0
    }

    var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Ohne Titel" : trimmed
    }

    /// Dekodiertes Bild aus dem Cache – die Daten werden nur einmal geladen.
    var cachedImage: UIImage? {
        guard !imageToken.isEmpty else { return nil }
        if let cached = ImageCache.shared.image(for: imageToken) {
            return cached
        }
        guard let data = imageData, let image = UIImage(data: data) else { return nil }
        ImageCache.shared.store(image, for: imageToken)
        return image
    }

    var face: CardFace {
        CardFace(
            title: title,
            holderName: holderName,
            last4: last4,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            networkLabel: networkLabel,
            kind: styleKind,
            preset: preset,
            gradientStart: Color(hex: gradientStartHex),
            gradientEnd: Color(hex: gradientEndHex),
            gradientAngle: gradientAngle,
            gradientBrushed: gradientBrushed,
            image: styleKind == .photo ? cachedImage : nil,
            imageScale: CGFloat(imageScale),
            imageOffset: CGSize(width: imageOffsetX, height: imageOffsetY),
            darkText: darkText
        )
    }
}
