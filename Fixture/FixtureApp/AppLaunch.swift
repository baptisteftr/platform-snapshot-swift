import Foundation
import SwiftUI

/// Lit les paramètres de lancement posés par `PlatformSnapshot.launch` : `--demo-data` et `PLATFORM_APPEARANCE`.
struct AppLaunch: Sendable {
    let isDemo: Bool
    /// Valeur brute de `PLATFORM_APPEARANCE` (`light`, `dark`) ou `system` si absente.
    let appearance: String

    init(processInfo: ProcessInfo = .processInfo) {
        isDemo = processInfo.arguments.contains("--demo-data")
        appearance = processInfo.environment["PLATFORM_APPEARANCE"] ?? "system"
    }

    /// L'apparence n'est imposée qu'en mode démo, comme le veut la convention de la plateforme.
    var colorScheme: ColorScheme? {
        guard isDemo else { return nil }
        switch appearance {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }
}
