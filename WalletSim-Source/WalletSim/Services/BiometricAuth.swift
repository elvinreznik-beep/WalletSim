import Foundation
import LocalAuthentication

enum AuthResult {
    case success
    case failure(String)
    /// Gerät hat keine Sperre/Beschreibung fehlt – Sperre kann nicht genutzt werden.
    case unavailable(String)
}

@MainActor
enum BiometricAuth {
    /// Ohne diesen Info.plist-Eintrag darf die App Face ID nicht nutzen.
    static var hasUsageDescription: Bool {
        Bundle.main.object(forInfoDictionaryKey: "NSFaceIDUsageDescription") != nil
    }

    static var biometryName: String {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch context.biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Gerätecode"
        }
    }

    static func authenticate(reason: String) async -> AuthResult {
        guard hasUsageDescription else {
            return .unavailable("Der Eintrag „Privacy – Face ID Usage Description“ fehlt im Xcode-Projekt (siehe Anleitung).")
        }

        let context = LAContext()
        context.localizedCancelTitle = "Abbrechen"
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return .unavailable("Auf diesem Gerät ist kein Code bzw. kein Face ID eingerichtet.")
        }

        do {
            let success = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            return success ? .success : .failure("Entsperren fehlgeschlagen.")
        } catch let laError as LAError where laError.code == .userCancel || laError.code == .appCancel || laError.code == .systemCancel {
            return .failure("Entsperren abgebrochen.")
        } catch {
            return .failure("Entsperren fehlgeschlagen. Versuch es noch einmal.")
        }
    }
}
