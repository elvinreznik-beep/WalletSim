import SwiftUI
import UIKit

extension Color {
    /// Erwartet "#RRGGBB" oder "RRGGBB".
    init(hex: String) {
        let rgb = HexColor.rgb(from: hex)
        self.init(.sRGB, red: rgb.red, green: rgb.green, blue: rgb.blue, opacity: 1)
    }
}

enum HexColor {
    static func rgb(from hex: String) -> (red: Double, green: Double, blue: Double) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else {
            return (0.5, 0.5, 0.5)
        }
        return (
            Double((value >> 16) & 0xFF) / 255,
            Double((value >> 8) & 0xFF) / 255,
            Double(value & 0xFF) / 255
        )
    }

    static func hex(from color: Color) -> String {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return "#" + twoDigits(red) + twoDigits(green) + twoDigits(blue)
    }

    private static func twoDigits(_ component: CGFloat) -> String {
        let value = Int((min(max(component, 0), 1) * 255).rounded())
        let text = String(value, radix: 16, uppercase: true)
        return text.count == 1 ? "0" + text : text
    }
}

enum GradientMath {
    /// Wandelt einen Winkel (0–360°) in Start/End-Punkte eines LinearGradient.
    static func points(for angle: Double) -> (start: UnitPoint, end: UnitPoint) {
        let radians = angle * .pi / 180
        let dx = cos(radians) / 2
        let dy = sin(radians) / 2
        return (UnitPoint(x: 0.5 - dx, y: 0.5 - dy), UnitPoint(x: 0.5 + dx, y: 0.5 + dy))
    }
}

enum CropMath {
    /// Begrenzt den Versatz so, dass das Bild die Karte immer komplett füllt.
    /// `offset` ist normalisiert (geteilt durch die Kartenbreite).
    static func clamp(offset: CGSize, scale: CGFloat, imageSize: CGSize, frameSize: CGSize) -> CGSize {
        guard imageSize.width > 0, imageSize.height > 0,
              frameSize.width > 0, frameSize.height > 0 else { return .zero }
        let fill = max(frameSize.width / imageSize.width, frameSize.height / imageSize.height)
        let shownWidth = imageSize.width * fill * scale
        let shownHeight = imageSize.height * fill * scale
        let maxX = max(0, (shownWidth - frameSize.width) / 2) / frameSize.width
        let maxY = max(0, (shownHeight - frameSize.height) / 2) / frameSize.width
        return CGSize(
            width: min(max(offset.width, -maxX), maxX),
            height: min(max(offset.height, -maxY), maxY)
        )
    }
}
