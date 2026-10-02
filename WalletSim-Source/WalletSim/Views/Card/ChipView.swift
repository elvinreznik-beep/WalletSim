import SwiftUI

struct ChipView: View {
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let shape = RoundedRectangle(cornerRadius: width * 0.18, style: .continuous)
            ZStack {
                shape.fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "#EBD290"),
                            Color(hex: "#C9A24E"),
                            Color(hex: "#F5E3AA"),
                            Color(hex: "#B48A3A")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                ChipContactsShape()
                    .stroke(Color(hex: "#7A5A1E").opacity(0.55), lineWidth: max(0.5, width * 0.025))
                shape.strokeBorder(Color(hex: "#8C6A2A").opacity(0.6), lineWidth: max(0.5, width * 0.02))
            }
        }
    }
}

/// Stilisierte Kontaktflächen eines EMV-Chips.
struct ChipContactsShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let inner = CGRect(x: rect.minX + w * 0.35, y: rect.minY + h * 0.26, width: w * 0.30, height: h * 0.48)
        path.addRoundedRect(in: inner, cornerSize: CGSize(width: w * 0.05, height: w * 0.05))

        for fraction in [0.36, 0.64] {
            let y = rect.minY + h * fraction
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: inner.minX, y: y))
            path.move(to: CGPoint(x: inner.maxX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: inner.minY))
        path.move(to: CGPoint(x: rect.midX, y: inner.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

/// Feine diagonale Linien als Muster (Emerald-Vorlage).
struct DiagonalLinesShape: Shape {
    var spacing: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = max(spacing, 2)
        var x = rect.minX - rect.height
        while x < rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.maxY))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.minY))
            x += step
        }
        return path
    }
}
