import SwiftUI

struct HomeView: View {
    let launch: AppLaunch

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Fixture PlatformSnapshot")
                        .font(.title2.bold())
                        .accessibilityIdentifier(A11y.Home.title)
                    LabeledContent("Apparence", value: launch.appearance)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Apparence")
                        .accessibilityValue(launch.appearance)
                        .accessibilityIdentifier(A11y.Home.appearance)
                    LabeledContent("Données de démo", value: launch.isDemo ? "on" : "off")
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Données de démo")
                        .accessibilityValue(launch.isDemo ? "on" : "off")
                        .accessibilityIdentifier(A11y.Home.demoData)
                }
                Section {
                    NavigationLink("Réglages") { SettingsView() }
                        .accessibilityIdentifier(A11y.Home.settingsLink)
                }
            }
            .navigationTitle("Accueil")
        }
    }
}
