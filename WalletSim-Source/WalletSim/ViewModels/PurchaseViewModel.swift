import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class PurchaseViewModel {
    var merchant = ""
    var amountText = ""
    var category: TransactionCategory = .shopping
    var date = Date()

    var amount: Double? {
        MoneyParser.parse(amountText)
    }

    var isValid: Bool {
        let hasMerchant = !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasAmount = (amount ?? 0) > 0
        return hasMerchant && hasAmount
    }

    func exceedsLimit(for card: Card) -> Bool {
        guard let value = amount else { return false }
        return value > card.availableCredit
    }

    func selectCategory(_ newCategory: TransactionCategory) {
        category = newCategory
        Haptics.selection()
    }

    func save(to card: Card, in context: ModelContext) {
        guard isValid, let value = amount else { return }
        let transaction = CardTransaction(
            merchant: merchant.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: value,
            date: date,
            category: category
        )
        context.insert(transaction)
        card.transactions.append(transaction)
        card.balance += value
        try? context.save()
        Haptics.success()
    }
}
