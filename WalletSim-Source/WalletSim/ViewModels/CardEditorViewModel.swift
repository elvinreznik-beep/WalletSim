import PhotosUI
import SwiftData
import SwiftUI
import UIKit

@MainActor
@Observable
final class CardEditorViewModel {
    let editingCard: Card?

    // Kartendaten
    var title: String
    var holderName: String
    var last4: String
    var expiryMonth: Int
    var expiryYear: Int
    var networkLabel: String

    // Design
    var styleKind: CardStyleKind
    var preset: CardPreset
    var gradientStart: Color
    var gradientEnd: Color
    var gradientAngle: Double
    var gradientBrushed: Bool
    var darkText: Bool

    // Foto
    var image: UIImage?
    var imageScale: CGFloat
    var imageOffset: CGSize
    var isLoadingImage = false
    var imageError: String?
    private var imageChanged = false

    // Guthaben (als Text, damit Komma-Eingaben sauber funktionieren)
    var creditLimitText: String
    var balanceText: String

    init(card: Card?) {
        editingCard = card
        if let card {
            title = card.title
            holderName = card.holderName
            last4 = card.last4
            expiryMonth = card.expiryMonth
            expiryYear = card.expiryYear
            networkLabel = card.networkLabel
            styleKind = card.styleKind
            preset = card.preset
            gradientStart = Color(hex: card.gradientStartHex)
            gradientEnd = Color(hex: card.gradientEndHex)
            gradientAngle = card.gradientAngle
            gradientBrushed = card.gradientBrushed
            darkText = card.darkText
            image = card.cachedImage
            imageScale = CGFloat(card.imageScale)
            imageOffset = CGSize(width: card.imageOffsetX, height: card.imageOffsetY)
            creditLimitText = MoneyParser.editString(card.creditLimit)
            balanceText = MoneyParser.editString(card.balance)
        } else {
            let now = Calendar.current.dateComponents([.year, .month], from: Date())
            title = "Reserve"
            holderName = ""
            last4 = CardEditorViewModel.randomLast4()
            expiryMonth = now.month ?? 1
            expiryYear = (now.year ?? 2026) + 4
            networkLabel = "Prestige"
            styleKind = .preset
            preset = .obsidianMetal
            gradientStart = Color(hex: "#2B5876")
            gradientEnd = Color(hex: "#0B1A2E")
            gradientAngle = 135
            gradientBrushed = false
            darkText = false
            image = nil
            imageScale = 1
            imageOffset = .zero
            creditLimitText = "25000"
            balanceText = "0"
        }
    }

    // MARK: Abgeleitete Werte

    var isNew: Bool { editingCard == nil }

    var creditLimit: Double? { MoneyParser.parse(creditLimitText) }

    var balance: Double? {
        balanceText.trimmingCharacters(in: .whitespaces).isEmpty ? 0 : MoneyParser.parse(balanceText)
    }

    var yearRange: [Int] {
        let current = Calendar.current.component(.year, from: Date())
        let lower = min(current, expiryYear)
        return Array(lower...(current + 12))
    }

    var validationMessage: String? {
        if last4.count != 4 { return "Die Kartennummer-Endung braucht genau 4 Ziffern." }
        if creditLimit == nil { return "Gib einen gültigen Kreditrahmen ein." }
        if balance == nil { return "Gib einen gültigen Saldo ein." }
        if styleKind == .photo && image == nil { return "Wähle ein Foto aus oder nutze eine Vorlage." }
        return nil
    }

    var isValid: Bool { validationMessage == nil }

    var previewFace: CardFace {
        CardFace(
            title: title,
            holderName: holderName,
            last4: last4,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            networkLabel: networkLabel,
            kind: styleKind,
            preset: preset,
            gradientStart: gradientStart,
            gradientEnd: gradientEnd,
            gradientAngle: gradientAngle,
            gradientBrushed: gradientBrushed,
            image: image,
            imageScale: imageScale,
            imageOffset: imageOffset,
            darkText: darkText
        )
    }

    // MARK: Aktionen

    static func randomLast4() -> String {
        String(format: "%04ld", Int.random(in: 0...9999))
    }

    func randomizeLast4() {
        last4 = CardEditorViewModel.randomLast4()
        Haptics.selection()
    }

    /// Erlaubt nur bis zu 4 Ziffern.
    func sanitizeLast4(_ value: String) {
        let digits: ClosedRange<Character> = "0"..."9"
        let filtered = String(value.filter { digits.contains($0) }.prefix(4))
        if filtered != value {
            last4 = filtered
        }
    }

    func selectPreset(_ newPreset: CardPreset) {
        preset = newPreset
        Haptics.selection()
    }

    func randomizeGradient() {
        let hue = Double.random(in: 0...1)
        let secondHue = (hue + Double.random(in: 0.06...0.22)).truncatingRemainder(dividingBy: 1)
        gradientStart = Color(hue: hue, saturation: .random(in: 0.55...0.9), brightness: .random(in: 0.55...0.9))
        gradientEnd = Color(hue: secondHue, saturation: .random(in: 0.6...0.95), brightness: .random(in: 0.16...0.42))
        gradientAngle = [45.0, 90, 120, 135, 160, 200, 225].randomElement() ?? 135
        darkText = false
        Haptics.selection()
    }

    func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        isLoadingImage = true
        imageError = nil
        defer { isLoadingImage = false }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let loaded = UIImage(data: data) else {
                imageError = "Das Foto konnte nicht geladen werden."
                return
            }
            image = ImageProcessing.prepareForCard(loaded)
            imageScale = 1
            imageOffset = .zero
            imageChanged = true
            styleKind = .photo
            Haptics.success()
        } catch {
            imageError = "Das Foto konnte nicht geladen werden."
        }
    }

    func removeImage() {
        image = nil
        imageScale = 1
        imageOffset = .zero
        imageChanged = true
    }

    func save(in context: ModelContext, nextSortIndex: Int) {
        guard isValid else { return }
        let card = editingCard ?? Card()

        card.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        card.holderName = holderName.trimmingCharacters(in: .whitespacesAndNewlines)
        card.last4 = last4
        card.expiryMonth = expiryMonth
        card.expiryYear = expiryYear
        card.networkLabel = networkLabel.trimmingCharacters(in: .whitespacesAndNewlines)

        card.styleKind = styleKind
        card.preset = preset
        card.gradientStartHex = HexColor.hex(from: gradientStart)
        card.gradientEndHex = HexColor.hex(from: gradientEnd)
        card.gradientAngle = gradientAngle
        card.gradientBrushed = gradientBrushed
        card.darkText = darkText

        if imageChanged {
            card.imageData = image?.jpegData(compressionQuality: 0.85)
            card.imageToken = image == nil ? "" : UUID().uuidString
        }
        card.imageScale = Double(imageScale)
        card.imageOffsetX = Double(imageOffset.width)
        card.imageOffsetY = Double(imageOffset.height)

        card.creditLimit = creditLimit ?? 0
        card.balance = balance ?? 0

        if editingCard == nil {
            card.sortIndex = nextSortIndex
            context.insert(card)
        }
        try? context.save()
        Haptics.success()
    }
}
