# Changelog

## 1.0.1 — 2026-10-08

- **macOS : capture de la fenêtre de l'app, jamais de l'écran entier** (C06 §7 v1.21). Sur macOS,
  `app.screenshot()` renvoie tout l'écran du Mac : sur un premier projet macOS, les captures montraient le
  bureau de l'utilisateur et l'app au premier plan (une autre app) au lieu de l'app testée. `capture` active
  désormais l'app, attend qu'elle soit au premier plan (`app.state == .runningForeground`, 5 s au plus), puis
  capture `app.windows.firstMatch`. Si l'app ne passe pas au premier plan ou n'a pas de fenêtre, le test
  échoue (`XCTFail` à la ligne de l'appel) et **aucune** capture n'est attachée.
- iOS / iPadOS / visionOS : inchangé (`app.screenshot()`).

## 1.0.0 — 2026-09-30

- `PlatformSnapshot.launch` (`--demo-data`, `PLATFORM_APPEARANCE`) et `PlatformSnapshot.capture` (activité et
  attachment `screen:<Écran>`, `keepAlways`), fixture iOS, CI. C06 §7 v1.6, C03 §6.3 v1.5.
