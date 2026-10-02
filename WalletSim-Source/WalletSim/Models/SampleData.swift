import Foundation
import SwiftData

/// Erzeugt Beispielkarten mit Umsätzen über die letzten Monate,
/// damit Diagramm und Liste sofort etwas zeigen.
enum SampleData {
    private struct SamplePurchase {
        let merchant: String
        let amount: Double
        let category: TransactionCategory
        let daysAgo: Int
    }

    private struct SampleCard {
        let preset: CardPreset
        let title: String
        let network: String
        let last4: String
        let limit: Double
        let purchases: [SamplePurchase]
    }

    private static let cards: [SampleCard] = [
        SampleCard(
            preset: .obsidianMetal,
            title: "Obsidian",
            network: "Prestige",
            last4: "7781",
            limit: 50000,
            purchases: [
                SamplePurchase(merchant: "Café Central", amount: 8.90, category: .cafe, daysAgo: 0),
                SamplePurchase(merchant: "Sushi Bar Kyoto", amount: 186.40, category: .restaurant, daysAgo: 1),
                SamplePurchase(merchant: "Hotel Lumière", amount: 1240.00, category: .hotel, daysAgo: 4),
                SamplePurchase(merchant: "Boutique Milano", amount: 2390.00, category: .fashion, daysAgo: 13),
                SamplePurchase(merchant: "Flug FRA → JFK", amount: 3420.00, category: .travel, daysAgo: 38),
                SamplePurchase(merchant: "Elektronikmarkt", amount: 1499.00, category: .tech, daysAgo: 64),
                SamplePurchase(merchant: "Kino Royal", amount: 32.00, category: .entertainment, daysAgo: 71),
                SamplePurchase(merchant: "Tankstelle Nord", amount: 94.30, category: .fuel, daysAgo: 96),
                SamplePurchase(merchant: "Juwelier Rubin", amount: 4800.00, category: .gifts, daysAgo: 123)
            ]
        ),
        SampleCard(
            preset: .midnightReserve,
            title: "Meridian Reserve",
            network: "Elite",
            last4: "6604",
            limit: 30000,
            purchases: [
                SamplePurchase(merchant: "Steakhouse 1890", amount: 264.00, category: .restaurant, daysAgo: 2),
                SamplePurchase(merchant: "Lounge Terminal 1", amount: 59.00, category: .travel, daysAgo: 9),
                SamplePurchase(merchant: "Mietwagen Premium", amount: 512.75, category: .transport, daysAgo: 33),
                SamplePurchase(merchant: "Konzerthaus", amount: 189.00, category: .entertainment, daysAgo: 58),
                SamplePurchase(merchant: "Feinkost Markt", amount: 143.20, category: .groceries, daysAgo: 87)
            ]
        ),
        SampleCard(
            preset: .platinumMirror,
            title: "Platinum",
            network: "Aurora",
            last4: "1093",
            limit: 20000,
            purchases: [
                SamplePurchase(merchant: "Sneaker Store", amount: 219.99, category: .fashion, daysAgo: 3),
                SamplePurchase(merchant: "Game Store", amount: 69.99, category: .gaming, daysAgo: 20),
                SamplePurchase(merchant: "Supermarkt", amount: 54.37, category: .groceries, daysAgo: 45),
                SamplePurchase(merchant: "Taxi", amount: 23.80, category: .transport, daysAgo: 77)
            ]
        ),
        SampleCard(
            preset: .emerald,
            title: "Emerald Club",
            network: "Prestige",
            last4: "3357",
            limit: 15000,
            purchases: [
                SamplePurchase(merchant: "Golfclub", amount: 380.00, category: .entertainment, daysAgo: 6),
                SamplePurchase(merchant: "Weinhandlung", amount: 96.50, category: .shopping, daysAgo: 29)
            ]
        )
    ]

    static func insert(into context: ModelContext, startIndex: Int) {
        let calendar = Calendar.current
        let now = Date()
        let expiryBase = calendar.component(.year, from: now)

        for (offset, sample) in cards.enumerated() {
            let card = Card()
            card.sortIndex = startIndex + offset
            card.title = sample.title
            card.holderName = "Max Mustermann"
            card.last4 = sample.last4
            card.expiryMonth = (offset * 4) % 12 + 1
            card.expiryYear = expiryBase + 3 + offset % 2
            card.networkLabel = sample.network
            card.styleKind = .preset
            card.preset = sample.preset
            card.creditLimit = sample.limit
            context.insert(card)

            var total = 0.0
            for purchase in sample.purchases {
                let date = calendar.date(byAdding: .day, value: -purchase.daysAgo, to: now) ?? now
                let transaction = CardTransaction(
                    merchant: purchase.merchant,
                    amount: purchase.amount,
                    date: date,
                    category: purchase.category
                )
                context.insert(transaction)
                card.transactions.append(transaction)
                total += purchase.amount
            }
            card.balance = total
        }
    }
}
