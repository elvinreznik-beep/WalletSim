import Foundation
import SwiftData
import SwiftUI

struct MonthlySpending: Identifiable {
    let month: Date
    let total: Double
    var id: Date { month }
}

@MainActor
@Observable
final class CardDetailViewModel {
    var showingAddPurchase = false
    var showingDeleteConfirm = false

    func sortedTransactions(for card: Card) -> [CardTransaction] {
        card.transactions.sorted { $0.date > $1.date }
    }

    /// Summe pro Monat für die letzten `months` Monate (inkl. Monate ohne Umsatz).
    func monthlySpending(for card: Card, months: Int = 6) -> [MonthlySpending] {
        let calendar = Calendar.current
        guard let currentMonth = calendar.dateInterval(of: .month, for: Date())?.start else { return [] }

        var result: [MonthlySpending] = []
        for offset in stride(from: months - 1, through: 0, by: -1) {
            guard let start = calendar.date(byAdding: .month, value: -offset, to: currentMonth),
                  let end = calendar.date(byAdding: .month, value: 1, to: start) else { continue }
            let total = card.transactions
                .filter { $0.date >= start && $0.date < end }
                .reduce(0.0) { $0 + $1.amount }
            result.append(MonthlySpending(month: start, total: total))
        }
        return result
    }

    func spendingThisMonth(for card: Card) -> Double {
        monthlySpending(for: card, months: 1).first?.total ?? 0
    }

    func delete(_ transaction: CardTransaction, from card: Card, in context: ModelContext) {
        withAnimation(.snappy) {
            card.balance = max(0, card.balance - transaction.amount)
            card.transactions.removeAll { $0.id == transaction.id }
            context.delete(transaction)
        }
        try? context.save()
        Haptics.impact(.light)
    }
}
