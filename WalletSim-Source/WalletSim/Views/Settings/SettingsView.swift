import SwiftData
import SwiftUI

struct SettingsView: View {
    let appLock: AppLockViewModel
    let walletViewModel: WalletViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query(sort: \Card.sortIndex) private var cards: [Card]
    @AppStorage(AppSettings.currencyKey) private var currencyCode = "EUR"
    @State private var showingResetConfirm = false

    private var lockBinding: Binding<Bool> {
        Binding(
            get: { appLock.isEnabled },
            set: { newValue in
                Task { await appLock.setEnabled(newValue) }
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: lockBinding) {
                        Label("Mit \(BiometricAuth.biometryName) sperren", systemImage: "lock.fill")
                    }
                    .disabled(appLock.isAuthenticating)

                    if let message = appLock.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Sicherheit")
                } footer: {
                    Text("Beim Öffnen der App wird Face ID abgefragt. Klappt das nicht, geht es mit deinem Gerätecode.")
                }

                Section("Darstellung") {
                    Picker("Währung", selection: $currencyCode) {
                        ForEach(AppSettings.currencies, id: \.self) { code in
                            Text(verbatim: "\(code) (\(Formatters.currencySymbol(for: code)))").tag(code)
                        }
                    }
                }

                Section("Daten") {
                    Button {
                        walletViewModel.loadSampleData(into: context, existing: cards)
                        dismiss()
                    } label: {
                        Label("Beispielkarten hinzufügen", systemImage: "sparkles")
                    }

                    Button(role: .destructive) {
                        showingResetConfirm = true
                    } label: {
                        Label("Alle Karten löschen", systemImage: "trash")
                    }
                    .disabled(cards.isEmpty)
                }

                Section {
                    EmptyView()
                } footer: {
                    Text("Wallet Sim ist eine reine Simulation. Karten, Salden und Umsätze sind fiktiv und existieren nur auf diesem Gerät. Es werden keine echten Zahlungen ausgeführt.")
                }
            }
            .navigationTitle("Einstellungen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
            .confirmationDialog("Alle Karten löschen?", isPresented: $showingResetConfirm, titleVisibility: .visible) {
                Button("Alle löschen", role: .destructive) {
                    walletViewModel.deleteAll(cards, in: context)
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Alle Karten und Umsätze werden entfernt. Das lässt sich nicht rückgängig machen.")
            }
        }
    }
}
