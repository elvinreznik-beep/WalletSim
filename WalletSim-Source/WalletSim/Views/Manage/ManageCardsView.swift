import SwiftData
import SwiftUI

struct ManageCardsView: View {
    let walletViewModel: WalletViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Card.sortIndex) private var cards: [Card]
    @AppStorage(AppSettings.currencyKey) private var currencyCode = "EUR"

    @State private var editMode: EditMode = .inactive
    @State private var editingCard: Card?
    @State private var cardToDelete: Card?

    private var deleteBinding: Binding<Bool> {
        Binding(
            get: { cardToDelete != nil },
            set: { if !$0 { cardToDelete = nil } }
        )
    }

    var body: some View {
        NavigationStack {
            List {
                if cards.isEmpty {
                    Text("Noch keine Karten vorhanden.")
                        .foregroundStyle(.secondary)
                } else {
                    Section {
                        ForEach(cards) { card in
                            row(for: card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if !editMode.isEditing {
                                        editingCard = card
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        cardToDelete = card
                                    } label: {
                                        Label("Löschen", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                        .onMove { source, destination in
                            walletViewModel.move(cards, from: source, to: destination, in: context)
                        }
                    } footer: {
                        Text("Tippe auf eine Karte, um sie zu bearbeiten. Nach links wischen zum Löschen. Mit „Sortieren“ änderst du die Reihenfolge im Stapel.")
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Karten verwalten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(editMode.isEditing ? "Fertig" : "Sortieren") {
                        withAnimation {
                            editMode = editMode.isEditing ? .inactive : .active
                        }
                    }
                    .disabled(cards.count < 2)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Schließen") { dismiss() }
                }
            }
            .sheet(item: $editingCard) { card in
                CardEditorView(card: card, nextSortIndex: card.sortIndex)
            }
            .confirmationDialog(
                "Karte löschen?",
                isPresented: deleteBinding,
                titleVisibility: .visible,
                presenting: cardToDelete
            ) { card in
                Button("Löschen", role: .destructive) {
                    walletViewModel.delete(card, in: context)
                }
                Button("Abbrechen", role: .cancel) {}
            } message: { card in
                Text("„\(card.displayTitle)“ und alle simulierten Umsätze werden entfernt.")
            }
        }
    }

    private func row(for card: Card) -> some View {
        HStack(spacing: 14) {
            CardView(face: card.face, isInteractive: false, showsDetails: false)
                .frame(width: 76)

            VStack(alignment: .leading, spacing: 3) {
                Text(card.displayTitle)
                    .font(.headline)
                    .lineLimit(1)
                Text(verbatim: "•••• \(card.last4)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Text(Formatters.currency(card.balance, code: currencyCode))
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
