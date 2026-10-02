import SwiftData
import SwiftUI

struct WalletView: View {
    @Bindable var viewModel: WalletViewModel
    let appLock: AppLockViewModel
    /// Erst wenn Splash/Sperre weg sind, fächern sich die Karten auf.
    let isRevealed: Bool

    @Environment(\.modelContext) private var context
    @Query(sort: \Card.sortIndex) private var cards: [Card]

    private let headerHeight: CGFloat = 64
    private let scrollSpace = "walletScroll"
    private let fanAnimation = Animation.spring(response: 0.62, dampingFraction: 0.78)

    private var selectedCard: Card? {
        guard let id = viewModel.selectedCardID else { return nil }
        return cards.first { $0.id == id }
    }

    var body: some View {
        GeometryReader { screen in
            let cardWidth = min(screen.size.width - 32, 430)
            let cardHeight = cardWidth / CardMetrics.aspectRatio

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        header
                            .frame(height: headerHeight)
                            .id("top")

                        if cards.isEmpty {
                            EmptyWalletView(
                                addCard: { viewModel.startNewCard() },
                                loadSamples: { viewModel.loadSampleData(into: context, existing: cards) }
                            )
                            .frame(maxWidth: 500)
                        } else {
                            cardStack(cardWidth: cardWidth, cardHeight: cardHeight)

                            if let card = selectedCard {
                                CardDetailView(card: card, walletViewModel: viewModel)
                                    .frame(maxWidth: 600)
                                    .transition(
                                        .asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                                            removal: .opacity
                                        )
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .coordinateSpace(.named(scrollSpace))
                .onChange(of: viewModel.selectedCardID) { _, newValue in
                    if newValue != nil {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.86)) {
                            proxy.scrollTo("top", anchor: .top)
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    miniDeck(cardWidth: cardWidth)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .sheet(item: $viewModel.editorTarget) { target in
            switch target {
            case .new:
                CardEditorView(card: nil, nextSortIndex: viewModel.nextSortIndex(for: cards))
            case .edit(let card):
                CardEditorView(card: card, nextSortIndex: card.sortIndex)
            }
        }
        .sheet(isPresented: $viewModel.showingSettings) {
            SettingsView(appLock: appLock, walletViewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingManage) {
            ManageCardsView(walletViewModel: viewModel)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Text("Wallet")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            if viewModel.selectedCardID != nil {
                Button("Fertig") { viewModel.deselect() }
                    .font(.headline)
                    .transition(.opacity)
            } else {
                Button {
                    viewModel.startNewCard()
                } label: {
                    HeaderIcon(systemName: "plus")
                }
                .accessibilityLabel("Karte hinzufügen")

                Menu {
                    Button("Karten verwalten", systemImage: "rectangle.stack") {
                        viewModel.showingManage = true
                    }
                    Button("Einstellungen", systemImage: "gearshape") {
                        viewModel.showingSettings = true
                    }
                } label: {
                    HeaderIcon(systemName: "ellipsis")
                }
                .accessibilityLabel("Mehr")
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Kartenstapel

    @ViewBuilder
    private func cardStack(cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        let peek = max(52, cardHeight * 0.26)
        let selectedIndex = cards.firstIndex { $0.id == viewModel.selectedCardID }
        let stackHeight = selectedIndex == nil
            ? cardHeight + CGFloat(max(cards.count - 1, 0)) * peek
            : cardHeight

        GeometryReader { geo in
            // Zieht man über den oberen Rand, fächern sich die Karten weiter auf.
            let pull = max(0, geo.frame(in: .named(scrollSpace)).minY - headerHeight)

            ZStack(alignment: .top) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    let isSelected = selectedIndex == index
                    let isHidden = selectedIndex != nil && !isSelected

                    CardView(face: card.face)
                        .frame(width: cardWidth)
                        .offset(y: yOffset(
                            index: index,
                            peek: peek,
                            pull: pull,
                            selectedIndex: selectedIndex,
                            cardHeight: cardHeight
                        ))
                        .scaleEffect(isHidden ? 0.92 : 1, anchor: .top)
                        .opacity(isHidden ? 0 : 1)
                        .zIndex(isSelected ? 1000 : Double(index))
                        .allowsHitTesting(!isHidden)
                        .onTapGesture {
                            viewModel.toggleSelection(card)
                        }
                        .animation(fanAnimation.delay(Double(index) * 0.05), value: isRevealed)
                }
            }
            .frame(width: geo.size.width, height: stackHeight, alignment: .top)
            .animation(.spring(response: 0.5, dampingFraction: 0.82), value: cards.map(\.id))
        }
        .frame(height: stackHeight)
        .padding(.top, 8)
    }

    private func yOffset(index: Int, peek: CGFloat, pull: CGFloat, selectedIndex: Int?, cardHeight: CGFloat) -> CGFloat {
        if let selectedIndex {
            if index == selectedIndex { return 0 }
            return cardHeight * 0.6 + CGFloat(index) * 10
        }
        let spacing = isRevealed ? peek : 7
        return CGFloat(index) * spacing + pull * CGFloat(index) * 0.3
    }

    // MARK: - Kartenstapel unten (wenn eine Karte geöffnet ist)

    @ViewBuilder
    private func miniDeck(cardWidth: CGFloat) -> some View {
        if let selected = selectedCard {
            let others = cards.filter { $0.id != selected.id }
            if !others.isEmpty {
                MiniDeckView(faces: others.prefix(4).map(\.face), cardWidth: cardWidth)
                    .onTapGesture { viewModel.deselect() }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Alle Karten anzeigen")
            }
        }
    }
}

struct MiniDeckView: View {
    let faces: [CardFace]
    let cardWidth: CGFloat
    private let strip: CGFloat = 14

    var body: some View {
        ZStack(alignment: .top) {
            ForEach(Array(faces.enumerated()), id: \.offset) { index, face in
                CardView(face: face, isInteractive: false, showsDetails: false)
                    .frame(width: cardWidth)
                    .offset(y: CGFloat(index) * strip)
            }
        }
        .frame(width: cardWidth, height: CGFloat(faces.count) * strip + 20, alignment: .top)
        .clipped()
        .contentShape(Rectangle())
        .padding(.bottom, 6)
    }
}

struct EmptyWalletView: View {
    let addCard: () -> Void
    let loadSamples: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.25), style: StrokeStyle(lineWidth: 1.5, dash: [7, 6]))
                .aspectRatio(CardMetrics.aspectRatio, contentMode: .fit)
                .overlay {
                    VStack(spacing: 10) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 34, weight: .light))
                        Text("Noch keine Karten")
                            .font(.headline)
                        Text("Leg deine erste Karte an oder lade Beispielkarten.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .foregroundStyle(.white.opacity(0.6))
                }

            Button(action: addCard) {
                Label("Karte hinzufügen", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button(action: loadSamples) {
                Label("Beispielkarten laden", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}
