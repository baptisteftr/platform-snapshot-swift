# PlatformSnapshot

Micro-package SPM qui produit les captures d'écran du pipeline Baptcave. Deux fonctions, dépendance
unique : XCTest. Il ne fait **pas** de snapshot testing (aucune comparaison d'images) : il attache des
captures nommées `screen:<Écran>` au résultat de test, que le runner de la plateforme extrait du `.xcresult`.

Plateformes : iOS / iPadOS 17.4, macOS 14.4, visionOS 1.1. Swift 6.

## Installation

À ajouter **uniquement au target de tests UI** (conventionnellement `SnapshotTests`), jamais à l'app :

```swift
// Package.swift, ou Xcode › Package Dependencies
.package(url: "https://github.com/baptisteftr/platform-snapshot-swift", from: "1.0.0")
```

## API

```swift
public enum PlatformSnapshot {
    /// Attend `settle` s puis, dans une activité intitulée `screen:<name>`, attache `app.screenshot()`
    /// sous le même nom (keepAlways).
    @MainActor public static func capture(_ app: XCUIApplication, _ name: String,
                                          settle: TimeInterval = 0.5, file: StaticString = #filePath, line: UInt = #line)

    /// Ajoute `--demo-data`, propage `PLATFORM_APPEARANCE` du process de test vers `launchEnvironment`, lance l'app.
    @MainActor @discardableResult
    public static func launch(_ app: XCUIApplication = XCUIApplication(), extraArguments: [String] = []) -> XCUIApplication
}
```

Un nom d'écran vide fait échouer le test (`XCTFail` à la ligne de l'appel). Nommez l'écran comme un humain
le nommerait : `"Settings"`, `"Onboarding/Step2"`.

## Exemple de target `SnapshotTests`

Un test par écran, nommé `test<Écran>Snapshot()`, qui lance l'app en mode démo, navigue jusqu'à l'écran
par ses `accessibilityIdentifier` et capture :

```swift
import PlatformSnapshot
import XCTest

@MainActor
final class SnapshotTests: XCTestCase {
    override func setUp() { continueAfterFailure = false }

    func testHomeSnapshot() {
        let app = PlatformSnapshot.launch()
        XCTAssertTrue(app.staticTexts[A11y.Home.title].waitForExistence(timeout: 10))
        PlatformSnapshot.capture(app, "Home")
    }

    func testSettingsSnapshot() {
        let app = PlatformSnapshot.launch()
        app.buttons[A11y.Home.settingsLink].tap()
        XCTAssertTrue(app.staticTexts[A11y.Settings.title].waitForExistence(timeout: 10))
        PlatformSnapshot.capture(app, "Settings")
    }
}
```

Côté app, lire les deux paramètres au lancement (`AppLaunch.swift`) :

```swift
let isDemo = ProcessInfo.processInfo.arguments.contains("--demo-data")      // état déterministe
let appearance = ProcessInfo.processInfo.environment["PLATFORM_APPEARANCE"]  // "light" | "dark" | nil
// en mode démo : .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
```

## `PLATFORM_APPEARANCE` et xcodebuild

Le pipeline lance le target une fois par apparence. **Une variable posée sur le process `xcodebuild` n'atteint
pas le process de test** : il faut la préfixer par `TEST_RUNNER_` (xcodebuild retire le préfixe et la transmet
au test runner), ou la déclarer dans le test plan. Vérifié sur la fixture (Xcode 27) :

```sh
PLATFORM_APPEARANCE=dark xcodebuild test …              # ✗ l'app reste en apparence système
TEST_RUNNER_PLATFORM_APPEARANCE=dark xcodebuild test …  # ✓ l'app reçoit PLATFORM_APPEARANCE=dark
```

## Extraire les captures d'un `.xcresult`

Chaque capture est une activité XCTest **intitulée `screen:<Écran>`** qui porte un attachment du même nom
(contrat 03 §6.3). Le runner lit les titres d'activités, puis exporte les fichiers :

```sh
xcrun xcresulttool get test-results activities --path Result.xcresult --test-id 'SnapshotTests/testHomeSnapshot()'
xcrun xcresulttool export attachments --path Result.xcresult --output-path out/
```

Les noms de fichiers exportés sont assainis par xcresulttool (`screenHome_0_<uuid>.png`, sans `:` ni `/`) et
ne servent jamais d'identifiant : `<Écran>` vient du titre de l'activité. XCTest ajoute sous l'activité une
sous-activité du même titre **sans** attachment (trace de l'ajout) : ne retenir que l'activité
`screen:<Écran>` qui porte l'attachment.

## Fixture

`Fixture/` contient une app SwiftUI minimale (deux écrans) et son target `SnapshotTests`, qui sert
d'exemple et de test d'intégration du package. Le `.xcodeproj` est généré par [XcodeGen](https://github.com/yonaskolb/XcodeGen)
et n'est pas versionné :

```sh
brew install xcodegen
cd Fixture && xcodegen generate
xcodebuild test -project SnapshotFixture.xcodeproj -scheme FixtureApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -resultBundlePath Result.xcresult
TEST_RUNNER_PLATFORM_APPEARANCE=dark xcodebuild test …   # même chose en sombre
```

## Développement

```sh
swift build && swift test                                   # macOS (logique pure testée unitairement)
xcodebuild -scheme PlatformSnapshot -destination 'generic/platform=iOS' build
xcodebuild -scheme PlatformSnapshot -destination 'generic/platform=visionOS' build
swift format lint --strict --recursive Package.swift Sources Tests Fixture
```

Contrats de référence : `platform-contracts/contracts/06-agents.md` §7, `03-runner-protocol.md` §6.3.
