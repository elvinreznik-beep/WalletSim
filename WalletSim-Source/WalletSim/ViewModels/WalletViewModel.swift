import SwiftData
import SwiftUI

enum EditorTarget: Identifiable {
    case new
    case edit(Card)

    var id: String {
        switch self {
        case .new: "new"
        case .edit(let card): card.id.uuidString
        }
    }
}

@MainActor
@Observable
final class WalletViewModel {
    var selectedCardID: UUID?
    var editorTarget: EditorTarget?
    var showingSettings = false
    var showingManage = false

    private let selectionAnimation = Animation.spring(response: 0.52, dampingFraction: 0.84)

    // MARK: Auswahl

    func toggleSelection(_ card: Card) {
        Haptics.impact(.light)
        withAnimation(selectionAnimation) {
            selectedCardID = selectedCardID == card.id ? nil : card.id
        }
    }

    func deselect() {
        guard selectedCardID != nil else { return }
        Haptics.impact(.light)
        withAnimation(selectionAnimation) {
            selectedCardID = nil
        }
    }

    // MARK: Editor

    func startNewCard() {
        Haptics.selection()
        editorTarget = .new
    }

    func edit(_ card: Card) {
        editorTarget = .edit(card)
    }

    func nextSortIndex(for cards: [Card]) -> Int {
        (cards.map(\.sortIndex).max() ?? -1) + 1
    }

    // MARK: Daten

    func delete(_ card: Card, in context: ModelContext) {
        let wasSelected = selectedCardID == card.id
        if wasSelected {
            withAnimation(selectionAnimation) {
                selectedCardID = nil
            }
        }
        Task {
            // Erst die Animation ausspielen, dann löschen – sonst greift die Detailansicht ins Leere.
            if wasSelected {
                try? await Task.sleep(for: .milliseconds(450))
            }
            context.delete(card)
            try? context.save()
            Haptics.warning()
        }
    }

    func deleteAll(_ cards: [Card], in context: ModelContext) {
        selectedCardID = nil
        for card in cards {
            context.delete(card)
        }
        try? context.save()
        Haptics.warning()
    }

    func move(_ cards: [Card], from source: IndexSet, to destination: Int, in context: ModelContext) {
        var reordered = cards
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, card) in reordered.enumerated() {
            card.sortIndex = index
        }
        try? context.save()
        Haptics.selection()
    }

    func loadSampleData(into context: ModelContext, existing cards: [Card]) {
        SampleData.insert(into: context, startIndex: nextSortIndex(for: cards))
        try? context.save()
        Haptics.success()
    }
}
