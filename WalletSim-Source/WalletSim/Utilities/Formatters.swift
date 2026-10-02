import Foundation

enum Formatters {
    static let locale = Locale(identifier: "de_DE")

    static func currency(_ value: Double, code: String) -> String {
        value.formatted(.currency(code: code).locale(locale))
    }

    static func currencySymbol(for code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = code
        return formatter.currencySymbol ?? code
    }

    /// Kurze Achsenbeschriftung: 950 · 1,5 Tsd. · 2 Mio.
    static func axisAmount(_ value: Double) -> String {
        let magnitude = abs(value)
        let style = FloatingPointFormatStyle<Double>(locale: locale).precision(.fractionLength(0...1))
        if magnitude >= 1_000_000 {
            return (value / 1_000_000).formatted(style) + " Mio."
        }
        if magnitude >= 1_000 {
            return (value / 1_000).formatted(style) + " Tsd."
        }
        return value.formatted(FloatingPointFormatStyle<Double>(locale: locale).precision(.fractionLength(0)))
    }

    static func transactionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let time = date.formatted(.dateTime.hour().minute().locale(locale))
        if calendar.isDateInToday(date) {
            return "Heute, \(time)"
        }
        if calendar.isDateInYesterday(date) {
            return "Gestern, \(time)"
        }
        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(locale))
    }
}
