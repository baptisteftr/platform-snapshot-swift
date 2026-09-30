# Captures (`PlatformSnapshot`)
Dernière mise à jour : 2026-09-30 (ticket #1)

## Rôle
Fournit aux targets de tests UI des projets tenants deux fonctions : `launch` (lance l'app en mode démo avec
l'apparence demandée par le pipeline) et `capture` (attache une capture nommée `screen:<Écran>`). Le runner
extrait ces attachments du `.xcresult` pour les montrer à l'agent dev, au reviewer et à l'humain.

## Règles métier
- Le nom d'attachment est exactement `screen:` + le nom passé, sans transformation ; `lifetime = .keepAlways`. (#1)
- Un nom vide (ou uniquement des espaces) ne produit aucune capture et fait échouer le test à la ligne de l'appel. (#1)
- `launch` ajoute `--demo-data` une seule fois (pas de doublon s'il est déjà présent), puis les `extraArguments`. (#1)
- `PLATFORM_APPEARANCE` n'est recopié dans `launchEnvironment` que s'il est défini et non vide dans le process
  de test ; il écrase alors une valeur déjà posée sur `app.launchEnvironment`. (#1)

## Décisions
- 2026-09-30 #1 — `capture` et `launch` sont `@MainActor` : `XCUIApplication` l'est en Swift 6 ; les tests UI
  (`XCTestCase` UI) tournent déjà sur le main actor. Ajout d'isolation, pas de changement de signature.
- 2026-09-30 #1 — `launch` est `@discardableResult` pour pouvoir l'appeler sans récupérer l'app.
- 2026-09-30 #1 — L'attachment est ajouté via `XCTContext.runActivity(named: "screen:<name>")` : la fonction est
  statique et n'a pas de `XCTestCase` sous la main ; l'activité porte aussi le nom, ce qui la rend lisible
  dans le rapport Xcode.
- 2026-09-30 #1 — Fixture générée par XcodeGen (`Fixture/project.yml`), `.xcodeproj` non versionné : un
  `pbxproj` écrit à la main est trop fragile. Alternative écartée : versionner le projet généré.
- 2026-09-30 #1 — L'attente `settle` passe par `XCTWaiter` (fait tourner la run loop) plutôt que `Thread.sleep`.

## Points techniques
- xcodebuild ne transmet pas son environnement au process de test : le pipeline doit poser
  `TEST_RUNNER_PLATFORM_APPEARANCE=dark` (préfixe retiré par xcodebuild), pas `PLATFORM_APPEARANCE=dark`.
  Vérifié sur la fixture, Xcode 27 / iOS 27 : sans préfixe, l'app reste en apparence système.
- Dans le `.xcresult`, le nom exact `screen:<Écran>` n'est visible que via `xcresulttool get object --legacy`
  (champ `name` des `ActionTestAttachment`) ; `xcresulttool export attachments` et `get test-results activities`
  exposent un nom assaini `screen<Écran>_0_<uuid>.png` (le `:` disparaît). Le titre de l'activité, lui, vaut
  bien `screen:<Écran>`.
- La logique pure (nom, arguments, environnement) est isolée dans des fonctions `internal` testées par
  `swift test` sur macOS ; l'intégration réelle est couverte par la fixture sur simulateur.

## Tickets
- #1 — Package complet et release 1.0 — 2026-09-30
