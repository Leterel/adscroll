# AdScroll zum ersten Mal ausprobieren

Die Datei `adscroll-0.1.0.apk` ist eine offline nutzbare Android-Demo.
Sie zeigt sechs fiktive Werbemotive. Echte Anzeigen und Einnahmen sind noch nicht implementiert.
Ein Server oder Konto ist nicht nötig.

## Manueller Test im Android-Emulator

1. Die vorhandene Entwicklungs-APK im ausdrücklich ausgewählten Emulator installieren und AdScroll öffnen.
2. Demo-Kennzeichnung prüfen. Nach oben wischen: die nächste Karte erscheint.
3. Mindestens achtmal weiterwischen: Nach sechs Motiven beginnt der Katalog erneut.
4. Nach unten wischen: die vorherige Karte erscheint.
5. Drehen sowie kurz in den Hintergrund wechseln und zurückkehren: die Position bleibt erhalten.
6. Große Systemschrift ausprobieren: lange Kartentexte müssen erreichbar bleiben.

Eine sichtbare fiktive Karte bestätigt nur die Demo, keine echte Werbeanbindung.
Es gibt keine zusätzlichen Spiel- oder Inhaltsfunktionen.

## Automatisierter Emulator-Test

Build- und Runner-Aufruf stehen in [README.md](README.md#bauen-und-testen).
`tests/emulator-smoke.ps1` verlangt eine explizite Emulator-Seriennummer und prüft
vor jeder Geräteaktion QEMU. Einen neuen Ausgabeordner wählen; alte Belege erhalten.
Keine physische Geräteaktion ist durch diese Anleitung autorisiert.

## Was für echte Werbung fehlt

Vor einer Implementierung einen geeigneten Anbieter mit aktuell geprüften offiziellen
Bedingungen oder direkte Sponsoren festlegen. Dazu kommen echte Motive,
gegebenenfalls Einwilligung und Store-Vorbereitung. Der vorhandene AAB-Build ist
unsigniert und kein fertiger Store-Release. Diese Änderung entscheidet keinen Anbieter.
