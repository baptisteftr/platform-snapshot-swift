import SwiftUI

struct SettingsView: View {
    @State private var notifications = true

    var body: some View {
        Form {
            Text("Réglages")
                .font(.title2.bold())
                .accessibilityIdentifier(A11y.Settings.title)
            Toggle("Notifications", isOn: $notifications)
                .accessibilityIdentifier(A11y.Settings.notificationsToggle)
        }
        .navigationTitle("Réglages")
    }
}
