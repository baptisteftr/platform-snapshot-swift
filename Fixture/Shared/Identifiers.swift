// Identifiants d'accessibilité partagés entre l'app fixture et ses tests UI.
// Convention : <ecran>.<element>[.<qualifieur>], minuscules, séparés par des points.

enum A11y {
    enum Home {
        static let title = "home.title.label"
        static let appearance = "home.appearance.label"
        static let demoData = "home.demodata.label"
        static let settingsLink = "home.settings.link"
    }
    enum Settings {
        static let title = "settings.title.label"
        static let notificationsToggle = "settings.notifications.toggle"
    }
}
