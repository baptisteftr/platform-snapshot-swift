import SwiftUI

@main
struct FixtureApp: App {
    private let launch = AppLaunch()

    var body: some Scene {
        WindowGroup {
            HomeView(launch: launch)
                .preferredColorScheme(launch.colorScheme)
        }
    }
}
