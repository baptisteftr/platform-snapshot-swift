import XCTest

/// Captures d'écran pour le pipeline de la plateforme.
///
/// À utiliser uniquement dans un target de tests UI (XCUITest), conventionnellement `SnapshotTests`.
/// Ce package ne compare aucune image : il produit des captures nommées que le runner extrait du
/// `.xcresult` : chaque capture est une activité intitulée `screen:<nom>` portant un attachment du même nom.
public enum PlatformSnapshot {
    /// Capture l'écran courant et l'attache au résultat de test sous le nom `screen:<name>`.
    /// Le runner de la plateforme extrait ces attachments du .xcresult.
    ///
    /// - Parameters:
    ///   - app: l'application sous test, déjà lancée (voir ``launch(_:extraArguments:)``).
    ///   - name: nom de l'écran tel qu'un humain le nommerait (`"Settings"`, `"Onboarding/Step2"`).
    ///   - settle: délai d'attente avant la capture, pour laisser finir les animations.
    @MainActor
    public static func capture(
        _ app: XCUIApplication, _ name: String,
        settle: TimeInterval = 0.5, file: StaticString = #filePath, line: UInt = #line
    ) {
        guard let attachmentName = attachmentName(for: name) else {
            XCTFail("PlatformSnapshot.capture : le nom d'écran ne peut pas être vide", file: file, line: line)
            return
        }
        if settle > 0 {
            _ = XCTWaiter.wait(for: [XCTestExpectation(description: "PlatformSnapshot.settle")], timeout: settle)
        }
        // Le titre de l'activité est l'identifiant lu par le runner (C03 §6.3) ; l'attachment porte le même nom.
        XCTContext.runActivity(named: attachmentName) { activity in
            let attachment = XCTAttachment(screenshot: app.screenshot())
            attachment.name = attachmentName
            attachment.lifetime = .keepAlways
            activity.add(attachment)
        }
    }

    /// Lance l'app avec les arguments attendus par la plateforme : ajoute `--demo-data` et propage
    /// `PLATFORM_APPEARANCE` depuis l'environnement du process de test vers `launchEnvironment`.
    @MainActor
    @discardableResult
    public static func launch(
        _ app: XCUIApplication = XCUIApplication(), extraArguments: [String] = []
    ) -> XCUIApplication {
        app.launchArguments = launchArguments(existing: app.launchArguments, extra: extraArguments)
        app.launchEnvironment = launchEnvironment(
            existing: app.launchEnvironment, testProcess: ProcessInfo.processInfo.environment)
        app.launch()
        return app
    }

    // MARK: - Logique pure (testée unitairement)

    static let attachmentPrefix = "screen:"
    static let demoDataArgument = "--demo-data"
    static let appearanceVariable = "PLATFORM_APPEARANCE"

    /// `screen:<name>`, ou `nil` si le nom est vide (après suppression des espaces).
    static func attachmentName(for name: String) -> String? {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : attachmentPrefix + name
    }

    /// Arguments existants, puis `--demo-data` (une seule fois), puis les arguments supplémentaires.
    static func launchArguments(existing: [String], extra: [String]) -> [String] {
        var arguments = existing
        if !arguments.contains(demoDataArgument) {
            arguments.append(demoDataArgument)
        }
        arguments.append(contentsOf: extra)
        return arguments
    }

    /// Recopie `PLATFORM_APPEARANCE` du process de test s'il est défini et non vide ; sinon ne touche à rien.
    static func launchEnvironment(existing: [String: String], testProcess: [String: String]) -> [String: String] {
        var environment = existing
        if let appearance = testProcess[appearanceVariable], !appearance.isEmpty {
            environment[appearanceVariable] = appearance
        }
        return environment
    }
}
