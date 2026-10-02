import SwiftUI
import UIKit

struct ImageCropView: View {
    let image: UIImage
    let face: CardFace
    @Binding var scale: CGFloat
    @Binding var offset: CGSize

    @Environment(\.dismiss) private var dismiss

    // Arbeitswerte (Versatz normalisiert auf die Kartenbreite)
    @State private var workingScale: CGFloat
    @State private var workingOffset: CGSize
    @State private var baseScale: CGFloat
    @State private var baseOffset: CGSize

    init(image: UIImage, face: CardFace, scale: Binding<CGFloat>, offset: Binding<CGSize>) {
        self.image = image
        self.face = face
        _scale = scale
        _offset = offset
        _workingScale = State(initialValue: scale.wrappedValue)
        _workingOffset = State(initialValue: offset.wrappedValue)
        _baseScale = State(initialValue: scale.wrappedValue)
        _baseOffset = State(initialValue: offset.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let width = max(1, min(geo.size.width - 32, 560))
                let size = CGSize(width: width, height: width / CardMetrics.aspectRatio)
                let shape = RoundedRectangle(cornerRadius: width * CardMetrics.cornerRatio, style: .continuous)

                VStack(spacing: 22) {
                    Spacer()

                    CardImageLayer(image: image, scale: workingScale, offset: workingOffset)
                        .frame(width: size.width, height: size.height)
                        .overlay {
                            CardContentView(face: face, size: size)
                                .opacity(0.85)
                                .allowsHitTesting(false)
                        }
                        .clipShape(shape)
                        .overlay { shape.strokeBorder(Color.white.opacity(0.6), lineWidth: 1) }
                        .contentShape(shape)
                        .gesture(dragGesture(frame: size).simultaneously(with: magnifyGesture(frame: size)))
                        .onTapGesture(count: 2) { reset(frame: size) }

                    Text("Ziehen zum Verschieben, mit zwei Fingern zoomen. Doppeltippen setzt zurück.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Foto anpassen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        scale = workingScale
                        offset = workingOffset
                        Haptics.success()
                        dismiss()
                    }
                }
            }
        }
    }

    private func dragGesture(frame size: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let proposed = CGSize(
                    width: baseOffset.width + value.translation.width / size.width,
                    height: baseOffset.height + value.translation.height / size.width
                )
                workingOffset = CropMath.clamp(offset: proposed, scale: workingScale, imageSize: image.size, frameSize: size)
            }
            .onEnded { _ in
                baseOffset = workingOffset
            }
    }

    private func magnifyGesture(frame size: CGSize) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                workingScale = min(max(baseScale * value.magnification, 1), 5)
                workingOffset = CropMath.clamp(offset: workingOffset, scale: workingScale, imageSize: image.size, frameSize: size)
            }
            .onEnded { _ in
                baseScale = workingScale
                baseOffset = workingOffset
            }
    }

    private func reset(frame size: CGSize) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            workingScale = 1
            workingOffset = .zero
        }
        baseScale = 1
        baseOffset = .zero
        Haptics.selection()
    }
}
