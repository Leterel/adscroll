# AdScroll

Sechstes Projekt in dieser Projektzentrale, aufgenommen am 17.10.2026.

Eine App, deren einziger Zweck es ist, unendlich durch Werbung zu scrollen.

## Gewünschter Ablauf

- App öffnen → Werbung.
- Scrollen oder swipen → nächste Werbung.
- Endlos wiederholen.

Keine zusätzlichen Inhalte, Story oder Spielfunktionen. Keine zusätzlichen
App-Buttons im vorgesehenen Hauptablauf.

## Stand

Erster Android-Prototyp: ein endlos wiederholter Feed aus sechs selbst erstellten,
fiktiven Werbekarten. Deutlich als Demo gekennzeichnet, ohne Werbe-SDK,
Netzwerkverbindung, Berechtigungen oder Einnahmen. Wischen nach oben/unten,
Tastatur und Accessibility-Scrollaktionen wechseln Karten. Rotation und
Hintergrund behalten die aktuelle Position. Der Feed baut keine wachsende Liste auf.

Privates Repository: https://github.com/Leterel/adscroll.
Android 8+, APK `adscroll-0.1.0.apk`, lokale Entwicklungssignatur.

## Bauen und testen

JDK 21, PowerShell 7, Android SDK API 36/Build-Tools 36.0.0:

```powershell
./build.ps1 -SdkPath 'C:/Android/Sdk' -JavaHome 'C:/Java/jdk-21'
```

APK unter `build/outputs`. Der Schlüssel in `build/debug.keystore` bleibt lokal.
Emulatorprüfung: `tests/emulator-smoke.ps1` mit `-AdbPath`, `-ApkPath`,
`-OutputDirectory` (neuer Ordner) und explizitem `-Serial emulator-5570`.
Der Runner prüft vor jeder Geräteaktion QEMU und verwendet kein echtes Handy.

## Echte Werbung noch offen

Die Demo bildet nur das Bedienkonzept ab. Googles Anzeigenrichtlinie untersagt
Google-Anzeigen auf Flächen ohne eigene Publisher-Inhalte:
https://support.google.com/publisherpolicies/answer/11112688?hl=en
(geprüft am 17.10.2026). Daher kein AdMob in dieser reinen Anzeigen-Demo.
Für echte Werbung ist ein Anbieter mit passenden Bedingungen oder eine direkte
Sponsorenvereinbarung nötig. Das ist noch nicht entschieden. Kein AAB und
keine Play-Store-Zulassung oder Monetarisierung behauptet.

## Quelle

Die vom Nutzer genannte Konzeptdatei wurde gelesen:
`Y:/KONZEPTE/01 NICHT ARBEIT/DESKTOP/♪♫/Adscroll/README.md`.
Sie bleibt am ursprünglichen Ort unverändert. Gesprächsangebote in dieser Datei
gehören zum alten Konzepttext und sind keine neuen Arbeitsaufträge.
