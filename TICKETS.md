# Tickets platform-snapshot-swift

- [x] **#1 Package complet et release 1.0.** `Package.swift`, `PlatformSnapshot.swift` (les deux fonctions), test XCUITest d'exemple dans un projet fixture minimal, README avec l'exemple de `SnapshotTests` (un test par écran, `PLATFORM_APPEARANCE`), CI, tag `1.0.0`. — C06 §7 ; C03 §6.3.
- [x] **#2 Conformité C06 §7 v1.6 / C03 §6.3 v1.5.** Capture et attachment dans l'activité `screen:<name>`, README et fiche alignés sur l'extraction par titre d'activité, tag `1.0.0` reposé. — C06 §7 ; C03 §6.3.
- [x] **#3 macOS : capture de la fenêtre de l'app (1.0.1).** Sur macOS, `capture` active l'app, attend le premier plan (≤ 5 s) et capture `app.windows.firstMatch` ; sinon `XCTFail` sans capture, jamais l'écran entier. iOS inchangé. CHANGELOG 1.0.1, README. — C06 §7 v1.21 ; C03 §6.3 v1.30.
