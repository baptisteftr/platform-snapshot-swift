import PlatformSnapshot
import XCTest

/// Exemple de target `SnapshotTests` : un test par écran, qui navigue jusqu'à l'écran puis capture.
/// Le pipeline le lance une fois par apparence avec `PLATFORM_APPEARANCE=light|dark`.
@MainActor
final class SnapshotTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testHomeSnapshot() {
        let app = PlatformSnapshot.launch()
        XCTAssertTrue(app.staticTexts[A11y.Home.title].waitForExistence(timeout: 10))
        PlatformSnapshot.capture(app, "Home")
    }

    func testSettingsSnapshot() {
        let app = PlatformSnapshot.launch()
        let link = app.buttons[A11y.Home.settingsLink]
        XCTAssertTrue(link.waitForExistence(timeout: 10))
        link.tap()
        XCTAssertTrue(app.staticTexts[A11y.Settings.title].waitForExistence(timeout: 10))
        PlatformSnapshot.capture(app, "Settings")
    }

    /// Vérifie ce que `launch` transmet à l'app : `--demo-data` et `PLATFORM_APPEARANCE`.
    func testLaunchPropagatesDemoDataAndAppearance() {
        let app = PlatformSnapshot.launch()
        let demo = app.descendants(matching: .any)[A11y.Home.demoData]
        XCTAssertTrue(demo.waitForExistence(timeout: 10))
        XCTAssertEqual(demo.value as? String, "on")
        let expected = ProcessInfo.processInfo.environment["PLATFORM_APPEARANCE"] ?? "system"
        let appearance = app.descendants(matching: .any)[A11y.Home.appearance]
        XCTAssertEqual(appearance.value as? String, expected.isEmpty ? "system" : expected)
    }
}
