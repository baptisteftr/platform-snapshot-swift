# AGENTS.md — platform-snapshot-swift

Micro-package SPM public `PlatformSnapshot` pour les targets de tests UI des projets tenants : deux fonctions, ~80 lignes. Contrat : `../platform-contracts/contracts/06-agents.md` §7 et 03 §6.3 (ce que le runner extrait).

## Règles

- Dépend uniquement de XCTest. iOS 17.4 / iPadOS / macOS 14.4 / visionOS.
- `capture(_:_:settle:file:line:)` attache un `XCTAttachment` nommé `screen:<name>`, `lifetime = .keepAlways`.
- `launch(_:extraArguments:)` ajoute `--demo-data`, propage `PLATFORM_APPEARANCE` vers `launchEnvironment`.
- Rien d'autre. Pas de comparaison d'images, pas de tolérance, pas de stockage : ce package ne fait pas de snapshot testing, il produit des captures pour le runner.
