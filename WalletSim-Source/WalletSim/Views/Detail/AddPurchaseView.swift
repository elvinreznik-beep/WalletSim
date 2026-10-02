import SwiftData
import SwiftUI

struct AddPurchaseView: View {
    let card: Card

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel = PurchaseViewModel()
    @AppStorage(AppSettings.currencyKey) private var currencyCode = "EUR"
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case merchant
        case amount
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        CardView(face: card.face, isInteractive: false, showsDetails: false)
                            .frame(width: 70)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(card.displayTitle)
                                .font(.headline)
                            Text("Verfügbar: \(Formatters.currency(card.availableCredit, code: currencyCode))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Kauf") {
                    TextField("Händler, z. B. Café Central", text: $viewModel.merchant)
                        .focused($focusedField, equals: .merchant)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .amount }

                    HStack {
                        TextField("Betrag", text: $viewModel.amountText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .amount)
                        Text(Formatters.currencySymbol(for: currencyCode))
                            .foregroundStyle(.secondary)
                    }

                    DatePicker(
                        "Datum",
                        selection: $viewModel.date,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Kategorie") {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(TransactionCategory.allCases) { category in
                            categoryButton(category)
                        }
                    }
                    .padding(.vertical, 6)
                }

                if viewModel.exceedsLimit(for: card) {
                    Section {
                        Label("Der Betrag übersteigt den verfügbaren Rahmen. Speichern geht trotzdem – es ist nur simuliert.", systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Kauf hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        viewModel.save(to: card, in: context)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") { focusedField = nil }
                }
            }
            .onAppear { focusedField = .merchant }
        }
    }

    private func categoryButton(_ category: TransactionCategory) -> some View {
        let isSelected = viewModel.category == category
        return Button {
            viewModel.selectCategory(category)
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color : Color.white.opacity(0.08))
                    Image(systemName: category.symbol)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : category.color)
                }
                .frame(width: 44, height: 44)

                Text(category.title)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
