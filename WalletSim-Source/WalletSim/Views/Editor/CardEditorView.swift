import PhotosUI
import SwiftData
import SwiftUI

struct CardEditorView: View {
    let nextSortIndex: Int

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel: CardEditorViewModel
    @State private var pickerItem: PhotosPickerItem?
    @State private var showingCrop = false
    @AppStorage(AppSettings.currencyKey) private var currencyCode = "EUR"
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case title, holder, network, last4, limit, balance
    }

    init(card: Card?, nextSortIndex: Int) {
        self.nextSortIndex = nextSortIndex
        _viewModel = State(initialValue: CardEditorViewModel(card: card))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CardView(face: viewModel.previewFace)
                        .padding(.vertical, 6)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
                }

                designSection
                detailsSection
                balanceSection

                if let message = viewModel.validationMessage {
                    Section {
                        Label(message, systemImage: "info.circle")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(viewModel.isNew ? "Neue Karte" : "Karte bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        viewModel.save(in: context, nextSortIndex: nextSortIndex)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Fertig") { focusedField = nil }
                }
            }
            .onChange(of: pickerItem) { _, newItem in
                Task { await viewModel.loadImage(from: newItem) }
            }
            .fullScreenCover(isPresented: $showingCrop) {
                if let image = viewModel.image {
                    ImageCropView(
                        image: image,
                        face: viewModel.previewFace,
                        scale: $viewModel.imageScale,
                        offset: $viewModel.imageOffset
                    )
                }
            }
        }
    }

    // MARK: - Design

    private var designSection: some View {
        Section("Design") {
            Picker("Stil", selection: $viewModel.styleKind) {
                ForEach(CardStyleKind.allCases) { kind in
                    Text(kind.title).tag(kind)
                }
            }
            .pickerStyle(.segmented)

            switch viewModel.styleKind {
            case .preset:
                presetPicker
            case .gradient:
                gradientControls
            case .photo:
                photoControls
            }
        }
    }

    private var presetPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CardPreset.allCases) { preset in
                    let isSelected = viewModel.preset == preset
                    Button {
                        viewModel.selectPreset(preset)
                    } label: {
                        VStack(spacing: 6) {
                            CardView(face: .preview(for: preset), isInteractive: false, showsDetails: false)
                                .frame(width: 112)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 112 * CardMetrics.cornerRatio + 3, style: .continuous)
                                        .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                                        .padding(-3)
                                }
                            Text(preset.displayName)
                                .font(.caption2.weight(isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 3)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
        }
    }

    @ViewBuilder
    private var gradientControls: some View {
        ColorPicker("Farbe oben", selection: $viewModel.gradientStart, supportsOpacity: false)
        ColorPicker("Farbe unten", selection: $viewModel.gradientEnd, supportsOpacity: false)
        VStack(alignment: .leading, spacing: 6) {
            Text(verbatim: "Winkel: \(Int(viewModel.gradientAngle))°")
            Slider(value: $viewModel.gradientAngle, in: 0...360, step: 1)
        }
        Toggle("Gebürstete Metall-Textur", isOn: $viewModel.gradientBrushed)
        Toggle("Dunkle Schrift", isOn: $viewModel.darkText)
        Button {
            viewModel.randomizeGradient()
        } label: {
            Label("Zufälligen Verlauf erzeugen", systemImage: "dice")
        }
    }

    @ViewBuilder
    private var photoControls: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            Label(viewModel.image == nil ? "Foto auswählen" : "Anderes Foto auswählen", systemImage: "photo.on.rectangle")
        }

        if viewModel.isLoadingImage {
            HStack(spacing: 10) {
                ProgressView()
                Text("Foto wird geladen …")
                    .foregroundStyle(.secondary)
            }
        }

        if let error = viewModel.imageError {
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
        }

        if viewModel.image != nil {
            Button {
                showingCrop = true
            } label: {
                Label("Zuschneiden und positionieren", systemImage: "crop")
            }
            Toggle("Dunkle Schrift", isOn: $viewModel.darkText)
            Button(role: .destructive) {
                viewModel.removeImage()
            } label: {
                Label("Foto entfernen", systemImage: "trash")
            }
        }
    }

    // MARK: - Kartendaten

    private var detailsSection: some View {
        Section("Kartendaten") {
            TextField("Kartentitel, z. B. Reserve", text: $viewModel.title)
                .textInputAutocapitalization(.words)
                .focused($focusedField, equals: .title)

            TextField("Name auf der Karte", text: $viewModel.holderName)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .textContentType(.name)
                .focused($focusedField, equals: .holder)

            TextField("Netzwerk-Label, frei wählbar", text: $viewModel.networkLabel)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .network)

            HStack {
                Text("Endet auf")
                TextField("1234", text: $viewModel.last4)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.body.monospacedDigit())
                    .focused($focusedField, equals: .last4)
                    .onChange(of: viewModel.last4) { _, newValue in
                        viewModel.sanitizeLast4(newValue)
                    }
                Button {
                    viewModel.randomizeLast4()
                } label: {
                    Image(systemName: "shuffle")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Zufällige Ziffern")
            }

            HStack {
                Text("Gültig bis")
                Spacer()
                Picker("Monat", selection: $viewModel.expiryMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(verbatim: String(format: "%02ld", month)).tag(month)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)

                Text(verbatim: "/")
                    .foregroundStyle(.secondary)

                Picker("Jahr", selection: $viewModel.expiryYear) {
                    ForEach(viewModel.yearRange, id: \.self) { year in
                        Text(verbatim: String(year)).tag(year)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }
        }
    }

    // MARK: - Guthaben

    private var balanceSection: some View {
        Section {
            amountRow(title: "Kreditrahmen", text: $viewModel.creditLimitText, field: .limit)
            amountRow(title: "Aktueller Saldo", text: $viewModel.balanceText, field: .balance)
        } header: {
            Text("Guthaben (simuliert)")
        } footer: {
            Text("Der Saldo ist der bereits ausgegebene Betrag. Verfügbar ist Kreditrahmen minus Saldo.")
        }
    }

    private func amountRow(title: String, text: Binding<String>, field: Field) -> some View {
        HStack {
            Text(title)
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.body.monospacedDigit())
                .focused($focusedField, equals: field)
            Text(Formatters.currencySymbol(for: currencyCode))
                .foregroundStyle(.secondary)
        }
    }
}
