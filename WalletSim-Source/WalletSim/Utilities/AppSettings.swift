import CoreGraphics

enum AppSettings {
    static let currencyKey = "settings.currencyCode"
    static let lockKey = "settings.faceIDLock"
    static let currencies = ["EUR", "USD", "GBP", "CHF"]
}

enum CardMetrics {
    /// ISO/IEC 7810 ID-1: 85,60 × 53,98 mm
    static let aspectRatio: CGFloat = 1.586
    static let cornerRatio: CGFloat = 0.045
}
