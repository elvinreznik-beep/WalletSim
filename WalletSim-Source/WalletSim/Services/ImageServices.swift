import UIKit

// MARK: - Cache für dekodierte Kartenfotos

final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 40
    }

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func store(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

// MARK: - Fotos für Karten vorbereiten

@MainActor
enum ImageProcessing {
    /// Verkleinert große Fotos und "backt" die Ausrichtung ein.
    static func prepareForCard(_ image: UIImage, maxDimension: CGFloat = 1800) -> UIImage {
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > 0 else { return image }
        let factor = min(1, maxDimension / longest)
        let target = CGSize(width: (size.width * factor).rounded(), height: (size.height * factor).rounded())

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}

// MARK: - Prozedurale Texturen (gebürstetes Metall, Körnung)

struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        var z = state
        z = (z ^ (z >> 33)) &* 0xFF51AFD7ED558CCD
        z = (z ^ (z >> 33)) &* 0xC4CEB9FE1A85EC53
        return z ^ (z >> 33)
    }
}

@MainActor
enum TextureFactory {
    static let brushedMetal: UIImage = makeBrushedMetal(width: 600, height: 380)
    static let grain: UIImage = makeGrain(size: 256)

    private static func makeBrushedMetal(width: Int, height: Int) -> UIImage {
        var generator = SeededGenerator(seed: 0xC0FFEE)
        var pixels = [UInt8](repeating: 0, count: width * height)
        var row = [Double](repeating: 0, count: width)
        let radius = 14

        for y in 0..<height {
            let base = Double.random(in: 0.36...0.64, using: &generator)
            for x in 0..<width {
                row[x] = base + Double.random(in: -0.24...0.24, using: &generator)
            }
            // Horizontaler Weichzeichner erzeugt die typischen Schleifspuren.
            var sum = 0.0
            var count = 0
            for x in 0..<min(radius, width) {
                sum += row[x]
                count += 1
            }
            for x in 0..<width {
                let addIndex = x + radius
                if addIndex < width {
                    sum += row[addIndex]
                    count += 1
                }
                let removeIndex = x - radius - 1
                if removeIndex >= 0 {
                    sum -= row[removeIndex]
                    count -= 1
                }
                let value = min(max(sum / Double(max(count, 1)), 0), 1)
                pixels[y * width + x] = UInt8(value * 255)
            }
        }
        return grayImage(pixels: pixels, width: width, height: height, scale: 1)
    }

    private static func makeGrain(size: Int) -> UIImage {
        var generator = SeededGenerator(seed: 0xBADA55)
        var pixels = [UInt8](repeating: 0, count: size * size)
        for index in pixels.indices {
            pixels[index] = UInt8.random(in: 70...185, using: &generator)
        }
        return grayImage(pixels: pixels, width: size, height: size, scale: 2)
    }

    private static func grayImage(pixels: [UInt8], width: Int, height: Int, scale: CGFloat) -> UIImage {
        let data = Data(pixels) as CFData
        guard let provider = CGDataProvider(data: data),
              let cgImage = CGImage(
                width: width,
                height: height,
                bitsPerComponent: 8,
                bitsPerPixel: 8,
                bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
              )
        else { return UIImage() }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}
