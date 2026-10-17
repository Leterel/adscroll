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

Noch offen: echte Werbeanbindung/Anbieter, produktive Werbemotive, AAB/Store-
Prüfung, weitere Android-Versionen und weitere Accessibility-Tests.
