import Charts
import SwiftUI

struct SpendingChartView: View {
    let data: [MonthlySpending]

    private var hasSpending: Bool {
        data.contains { $0.total > 0 }
    }

    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Monat", item.month, unit: .month),
                y: .value("Ausgaben", item.total)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color(hex: "#E9CB86"), Color(hex: "#9C7432")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(6)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).locale(Formatters.locale), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(Formatters.axisAmount(amount))
                    }
                }
            }
        }
        .chartYScale(domain: 0...(hasSpending ? (data.map(\.total).max() ?? 1) * 1.15 : 100))
        .frame(height: 190)
        .overlay {
            if !hasSpending {
                Text("Noch keine Ausgaben in den letzten Monaten")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: CardTransaction
    let currencyCode: String

    var body: some View {
        let category = transaction.category

        HStack(spacing: 12) {
            ZStack {
                Circle().fill(category.color.gradient)
                Image(systemName: category.symbol)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.merchant)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                Text("\(category.title), \(Formatters.transactionDate(transaction.date))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(Formatters.currency(transaction.amount, code: currencyCode))
                .font(.body.monospacedDigit().weight(.semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
