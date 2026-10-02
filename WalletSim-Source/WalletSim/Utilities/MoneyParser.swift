import Foundation

/// Wandelt Eingaben wie "1.234,56", "1234.5" oder "12,5" in Double um.
/// Das letzte Komma/der letzte Punkt gilt als Dezimaltrenner, außer es folgen genau drei Ziffern
/// (dann ist es ein Tausenderpunkt, z. B. "1.500").
enum MoneyParser {
    static func parse(_ text: String) -> Double? {
        let digits: ClosedRange<Character> = "0"..."9"
        let chars = Array(text.filter { digits.contains($0) || $0 == "," || $0 == "." })
        guard chars.contains(where: { digits.contains($0) }) else { return nil }

        let lastComma = chars.lastIndex(of: ",")
        let lastDot = chars.lastIndex(of: ".")
        var decimalIndex: Int?

        if let comma = lastComma, let dot = lastDot {
            decimalIndex = max(comma, dot)
        } else if let separatorIndex = lastComma ?? lastDot {
            let separator = chars[separatorIndex]
            let occurrences = chars.filter { $0 == separator }.count
            let digitsAfter = chars.count - separatorIndex - 1
            if occurrences == 1 && digitsAfter != 3 {
                decimalIndex = separatorIndex
            }
        }

        var normalized = ""
        for (index, char) in chars.enumerated() {
            if digits.contains(char) {
                normalized.append(char)
            } else if index == decimalIndex {
                normalized.append(".")
            }
        }
        if normalized.hasSuffix(".") { normalized.removeLast() }
        if normalized.hasPrefix(".") { normalized = "0" + normalized }
        return Double(normalized)
    }

    /// Wert für ein Eingabefeld, ohne Tausenderpunkte: 25000 → "25000", 12.5 → "12,5"
    static func editString(_ value: Double) -> String {
        value.formatted(
            FloatingPointFormatStyle<Double>(locale: Formatters.locale)
                .grouping(.never)
                .precision(.fractionLength(0...2))
        )
    }
}
