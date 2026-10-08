import XCTest

@testable import PlatformSnapshot

final class PlatformSnapshotTests: XCTestCase {
    func testAttachmentNameIsPrefixed() {
        XCTAssertEqual(PlatformSnapshot.attachmentName(for: "Settings"), "screen:Settings")
        XCTAssertEqual(PlatformSnapshot.attachmentName(for: "Onboarding/Step2"), "screen:Onboarding/Step2")
    }

    func testAttachmentNameRejectsEmptyNames() {
        XCTAssertNil(PlatformSnapshot.attachmentName(for: ""))
        XCTAssertNil(PlatformSnapshot.attachmentName(for: "  \n"))
    }

    func testLaunchArgumentsAddDemoDataOnceThenExtras() {
        XCTAssertEqual(
            PlatformSnapshot.launchArguments(existing: [], extra: []),
            ["--demo-data"])
        XCTAssertEqual(
            PlatformSnapshot.launchArguments(existing: ["-AppleLanguages", "(fr)"], extra: ["--skip-onboarding"]),
            ["-AppleLanguages", "(fr)", "--demo-data", "--skip-onboarding"])
        XCTAssertEqual(
            PlatformSnapshot.launchArguments(existing: ["--demo-data"], extra: []),
            ["--demo-data"])
    }

    func testLaunchEnvironmentPropagatesAppearance() {
        let environment = PlatformSnapshot.launchEnvironment(
            existing: ["FOO": "bar"], testProcess: ["PLATFORM_APPEARANCE": "dark", "HOME": "/tmp"])
        XCTAssertEqual(environment, ["FOO": "bar", "PLATFORM_APPEARANCE": "dark"])
    }

    func testLaunchEnvironmentLeavesAppearanceUnsetWhenAbsentOrEmpty() {
        XCTAssertEqual(PlatformSnapshot.launchEnvironment(existing: [:], testProcess: [:]), [:])
        XCTAssertEqual(
            PlatformSnapshot.launchEnvironment(existing: [:], testProcess: ["PLATFORM_APPEARANCE": ""]), [:])
    }

    func testLaunchEnvironmentOverridesExistingAppearance() {
        let environment = PlatformSnapshot.launchEnvironment(
            existing: ["PLATFORM_APPEARANCE": "light"], testProcess: ["PLATFORM_APPEARANCE": "dark"])
        XCTAssertEqual(environment["PLATFORM_APPEARANCE"], "dark")
    }

    func testMacOSCaptureSucceedsOnlyWithForegroundAppAndWindow() {
        XCTAssertNil(PlatformSnapshot.macOSCaptureFailure(name: "Home", isForeground: true, hasWindow: true))
    }

    func testMacOSCaptureFailsWhenAppIsNotForeground() {
        for hasWindow in [true, false] {
            let failure = PlatformSnapshot.macOSCaptureFailure(name: "Home", isForeground: false, hasWindow: hasWindow)
            XCTAssertNotNil(failure)
            XCTAssertTrue(failure?.contains("premier plan") == true)
            XCTAssertTrue(failure?.contains("\"Home\"") == true)
        }
    }

    func testMacOSCaptureFailsWithoutWindow() {
        let failure = PlatformSnapshot.macOSCaptureFailure(name: "Settings", isForeground: true, hasWindow: false)
        XCTAssertNotNil(failure)
        XCTAssertTrue(failure?.contains("aucune fenêtre") == true)
        XCTAssertTrue(failure?.contains("jamais l'écran entier") == true)
    }

    func testMacOSForegroundWaitIsBoundedToFiveSeconds() {
        XCTAssertLessThanOrEqual(PlatformSnapshot.foregroundTimeout, 5)
    }
}
