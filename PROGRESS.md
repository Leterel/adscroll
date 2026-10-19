# AdScroll — 17.10.2026

Native Android-Demo für das gewünschte reine Swipe-Konzept implementiert.
Sechs fiktive Motive, immer sichtbare Demo-Kennzeichnung; keine echte Werbung.
Kein Netzwerk, keine Berechtigungen, kein Tracking und keine Einnahmen.

API-36-Build mit JDK 21, Signatur V2/V3 und Alignment geprüft.
API-34-Emulator: Start, Kennzeichnung, acht Vorwärtsswipes über einen Katalogumlauf,
Rückwärtsswipe, begrenzter UI-Baum, Rotation und Hintergrund/Fortsetzen geprüft.
Der Runner bewahrt alte Belege und stellt die ursprünglichen Emulator-Rotationswerte
wieder her. Kein physisches Gerät verwendet.

Zusätzlich 200 Prozent Schrift geprüft: lange Kartentexte bleiben scrollbar,
bevor die nächste Karte erscheint. Tastaturnavigation mit Pfeiltasten geprüft;
Android kann die erste Pfeiltaste zum Verlassen des Touch-Modus verwenden.
Der normale Runner stellt auch die vorherige Schriftgröße wieder her.
Finale APK-SHA256: E1ACB5AD58B36937283949E6E1CD86A6417A08CC2C383411DE3B0F1803F3A3C5.

## AAB ergänzt — 17.10.2026

Reproduzierbare Gradle-Konfiguration und `build-bundle.ps1` ergänzt. Offline-Build
mit Gradle 8.9, AGP 8.7.3, SDK/Build-Tools 36 und JDK 21 erfolgreich. Die AGP-
Warnung zu compileSdk 36 bleibt sichtbar und ist vor Store-Veröffentlichung durch
ein getestetes Werkzeug-Upgrade zu lösen.

Unsigniertes AAB mit bundletool 1.18.3 validiert. SHA256:
`3017C25076CEFFCF15FD01D72E884E0F4EAA9AFFA7A96C1F725ADA6DEDAF5024`.
Daraus lokal testsignierte Split-APKs erzeugt und ausschließlich auf QEMU
`emulator-5570`, API 34 installiert und gestartet. Erwartete Karte angezeigt,
App läuft ohne erfasste FATAL EXCEPTION. Derselbe installierte Bundle-Build besteht
acht Vorwärtsswipes, Rückwärtsswipe, begrenzten UI-Baum, Rotation und Fortsetzen.
Die ursprünglichen Emulator-Schrift- und Rotationswerte wurden wiederhergestellt.
Belege liegen in `tests/evidence/bundle-20261017/` und ergänzend in den lokalen
Output-Ordnern. Kein produktiver Signierschlüssel und kein physisches Gerät benutzt.

Noch offen: echte Werbeanbindung/Anbieter, produktive Werbemotive, produktive
Signierung und Store-Prüfung, weitere Android-Versionen und Accessibility-Tests.

## 19.10.2026 — Einfacher Ersttest

ERSTTEST.md ergänzt: Offline-Demo starten, Katalogumlauf, Rückwärtswischen,
Rotation, Fortsetzen und große Schrift. APK-SHA256 erneut mit dem dokumentierten
E1ACB5AD58B36937283949E6E1CD86A6417A08CC2C383411DE3B0F1803F3A3C5 abgeglichen.
Vorhandene Bundle-/QEMU-Belege gelesen; kein neuer Emulatorlauf und kein neuer Build.
Keine Anbieterentscheidung oder echte Werbung implementiert.
