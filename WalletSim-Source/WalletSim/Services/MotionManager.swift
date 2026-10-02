import CoreGraphics
import CoreMotion
import Foundation
import Observation

/// Liefert eine geglättete Neigung (-1…1) für den Schimmer auf den Karten.
/// Ohne Bewegungssensor (Simulator) läuft eine langsame Auto-Animation.
@MainActor
@Observable
final class MotionManager {
    static let shared = MotionManager()

    private(set) var tilt: CGPoint = .zero

    private let manager = CMMotionManager()
    @ObservationIgnored private var loopTask: Task<Void, Never>?
    @ObservationIgnored private var baselineY: Double?
    @ObservationIgnored private var simulatedTime: Double = 0

    private init() {}

    func start() {
        guard loopTask == nil else { return }
        if manager.isDeviceMotionAvailable && !manager.isDeviceMotionActive {
            manager.deviceMotionUpdateInterval = 1.0 / 60.0
            manager.startDeviceMotionUpdates()
        }
        loopTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.step()
                try? await Task.sleep(for: .milliseconds(16))
            }
        }
    }

    func stop() {
        loopTask?.cancel()
        loopTask = nil
        if manager.isDeviceMotionActive {
            manager.stopDeviceMotionUpdates()
        }
        baselineY = nil
    }

    private func step() {
        let target: CGPoint
        if let motion = manager.deviceMotion {
            let gravityX = motion.gravity.x
            let gravityY = motion.gravity.y
            // Die Grundhaltung passt sich langsam an, damit der Effekt auf Bewegung reagiert.
            let base = baselineY ?? gravityY
            let newBase = base + (gravityY - base) * 0.02
            baselineY = newBase
            target = CGPoint(x: clamp(gravityX * 1.6), y: clamp((gravityY - newBase) * 3))
        } else {
            simulatedTime += 0.016
            target = CGPoint(x: sin(simulatedTime * 0.8) * 0.6, y: cos(simulatedTime * 0.55) * 0.35)
        }

        let smoothed = CGPoint(
            x: tilt.x + (target.x - tilt.x) * 0.18,
            y: tilt.y + (target.y - tilt.y) * 0.18
        )
        if abs(smoothed.x - tilt.x) > 0.0005 || abs(smoothed.y - tilt.y) > 0.0005 {
            tilt = smoothed
        }
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, -1), 1)
    }
}
