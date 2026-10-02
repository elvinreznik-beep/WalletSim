import SwiftData
import SwiftUI

struct CardDetailView: View {
    let card: Card
    let walletViewModel: WalletViewModel

    @Environment(\.modelContext) private var context
    @State private var viewModel = CardDetailViewModel()
    @AppStorage(AppSettings.currencyKey) private var currencyCode = "EUR"

    var body: some View {
        let transactions = viewModel.sortedTransactions(for: card)

        VStack(alignment: .leading, spacing: 22) {
            balancePanel
            actionRow
            spendingSection
            transactionsSection(transactions)

            Text("Alle Beträge sind simuliert. Es werden keine echten Zahlungen ausgeführt.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.top, 22)
        .padding(.bottom, 140)
        .sheet(isPresented: $viewModel.showingAddPurchase) {
            AddPurchaseView(card: card)
        }
        .confirmationDialog(
            "Karte löschen?",
            isPresented: $viewModel.showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Karte löschen", role: .destructive) {
                walletViewModel.delete(card, in: context)
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Die Karte und alle simulierten Umsätze werden entfernt.")
        }
    }

    // MARK: - Saldo

    private var balancePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Aktueller Saldo")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(Formatters.currency(card.balance, code: currencyCode))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .animation(.snappy, value: card.balance)

            UtilizationBar(fraction: card.utilization)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Verfügbar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Formatters.currency(card.availableCredit, code: currencyCode))
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(card.availableCredit < 0 ? Color.red : Color.primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Kreditrahmen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(Formatters.currency(card.creditLimit, code: currencyCode))
                        .font(.callout.weight(.semibold))
                }
            }

            Text("Diesen Monat ausgegeben: \(Formatters.currency(viewModel.spendingThisMonth(for: card), code: currencyCode))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white.opacity(0.07)))
    }

    // MARK: - Aktionen

    private var actionRow: some View {
        HStack(spacing: 12) {
            ActionTile(title: "Kauf hinzufügen", systemImage: "plus.circle.fill", tint: Color(hex: "#D4B06A")) {
                viewModel.showingAddPurchase = true
            }
            ActionTile(title: "Bearbeiten", systemImage: "pencil", tint: .white) {
                walletViewModel.edit(card)
            }
            ActionTile(title: "Löschen", systemImage: "trash", tint: .red) {
                viewModel.showingDeleteConfirm = true
            }
        }
    }

    // MARK: - Diagramm

    private var spendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ausgaben pro Monat")
                .font(.title3.bold())

            SpendingChartView(data: viewModel.monthlySpending(for: card))
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white.opacity(0.06)))
        }
    }

    // MARK: - Umsätze

    private func transactionsSection(_ transactions: [CardTransaction]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Letzte Umsätze")
                .font(.title3.bold())

            if transactions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title2)
                    Text("Noch keine Umsätze. Füge einen Kauf hinzu, um ihn hier zu sehen.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white.opacity(0.06)))
            } else {
                VStack(spacing: 0) {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction, currencyCode: currencyCode)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.delete(transaction, from: card, in: context)
                                } label: {
                                    Label("Umsatz löschen", systemImage: "trash")
                                }
                            }
                        if transaction.id != transactions.last?.id {
                            Divider().padding(.leading, 66)
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color.white.opacity(0.06)))

                Text("Halte einen Umsatz gedrückt, um ihn zu löschen.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Bausteine

struct ActionTile: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.white.opacity(0.08)))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct UtilizationBar: View {
    let fraction: Double

    private var colors: [Color] {
        if fraction > 0.9 { return [.orange, .red] }
        if fraction > 0.6 { return [.yellow, .orange] }
        return [Color(hex: "#5AC8FA"), Color(hex: "#34C759")]
    }

    var body: some View {
        GeometryReader { geo in
            let clamped = min(max(fraction, 0), 1)
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .frame(width: clamped <= 0 ? 0 : max(8, geo.size.width * clamped))
            }
        }
        .frame(height: 8)
        .animation(.snappy, value: fraction)
    }
}
