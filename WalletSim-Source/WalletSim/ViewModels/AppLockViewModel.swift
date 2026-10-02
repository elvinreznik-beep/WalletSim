import Foundation
import SwiftUI

@MainActor
@Observable
final class AppLockViewModel {
    private(set) var isEnabled: Bool
    private(set) var isLocked: Bool
    private(set) var isAuthenticating = false
    var errorMessage: String?

    @ObservationIgnored private var unlockWhenActive = false

    init() {
        let enabled = UserDefaults.standard.bool(forKey: AppSettings.lockKey)
        isEnabled = enabled
        isLocked = enabled
    }

    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background:
            if isEnabled {
                isLocked = true
                unlockWhenActive = true
            }
        case .active:
            // Nur nach echtem Hintergrund neu fragen – sonst Endlosschleife nach "Abbrechen".
            if unlockWhenActive {
                unlockWhenActive = false
                Task { await unlock() }
            }
        default:
            break
        }
    }

    func unlock() async {
        guard isLocked, !isAuthenticating else { return }
        isAuthenticating = true
        let result = await BiometricAuth.authenticate(reason: "Entsperre Wallet Sim.")
        isAuthenticating = false

        switch result {
        case .success:
            errorMessage = nil
            withAnimation(.easeOut(duration: 0.25)) {
                isLocked = false
            }
        case .failure(let message):
            errorMessage = message
        case .unavailable(let message):
            // Sicherheitsventil: Ohne Face ID/Code würde man sich sonst aussperren.
            errorMessage = message
            disable()
            withAnimation(.easeOut(duration: 0.25)) {
                isLocked = false
            }
        }
    }

    func setEnabled(_ enabled: Bool) async {
        guard enabled != isEnabled else { return }
        if enabled {
            let result = await BiometricAuth.authenticate(reason: "Bestätige, um die Sperre einzuschalten.")
            switch result {
            case .success:
                errorMessage = nil
            case .failure(let message), .unavailable(let message):
                errorMessage = message
                return
            }
        }
        isEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: AppSettings.lockKey)
        Haptics.success()
    }

    private func disable() {
        isEnabled = false
        UserDefaults.standard.set(false, forKey: AppSettings.lockKey)
    }
}
