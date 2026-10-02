import Foundation
import SwiftData

/// Ein simulierter Kauf. Existiert nur in der App, nirgendwo sonst.
@Model
final class CardTransaction {
    var id: UUID = UUID()
    var merchant: String = ""
    var amount: Double = 0
    var date: Date = Date()
    var categoryRaw: String = "other"
    var card: Card?

    init(merchant: String, amount: Double, date: Date, category: TransactionCategory) {
        self.merchant = merchant
        self.amount = amount
        self.date = date
        self.categoryRaw = category.rawValue
    }

    var category: TransactionCategory {
        get { TransactionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}
