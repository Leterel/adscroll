# Direkte Sponsoren vorbereiten

Keine AdMob-Integration. Ein Feed ausschließlich aus Werbung braucht passende
direkte Sponsorenvereinbarungen. Es sind derzeit keine Sponsoren, bezahlten Motive
oder Einnahmen vorhanden. Der Generator ersetzt weder Vereinbarung noch Freigabe.

Der Katalog ist lokales JSON, ohne Netzwerk, HTML, Skripte, Tracking-Pixel,
Klicklinks oder Messung bezahlter Impressionen. Jede Karte besteht aus Text und
zwei Farben. Es werden keine neuen Buttons oder sonstigen Inhalte eingebaut.

```json
{
  "version": 1,
  "ads": [
    {
      "brand": "FIKTIVES TESTMOTIV",
      "headline": "Nur eine technische Vorschau",
      "body": "Keine bezahlte Werbung und kein echter Vertrag.",
      "background": "#FFFFFF",
      "foreground": "#111111"
    }
  ]
}
```

Private Originaldatei außerhalb des Repositorys aufbewahren. 1–48 Karten,
Marke maximal 40 Zeichen/eine Zeile, Überschrift 100 Zeichen/drei Zeilen,
Beschreibung 240 Zeichen/vier Zeilen. Farben exakt `#RRGGBB`, Textkontrast
mindestens 4,5:1. Unbekannte Felder, URL-Schemata, HTML und Steuerzeichen
werden abgelehnt. Dateigrenze 64 KiB. Keine fremden Java-Quellen übernehmen.

Vorschauquelltext (weiter deutlich als unbezahlte Demo gekennzeichnet):

```powershell
node tools/generate-catalog.mjs C:/private/catalog.json C:/private/catalog-preview-new
node --test tests/catalog.test.mjs
```

Ausgabeordner muss neu sein, sein Elternordner muss existieren. Die vorhandene
Demo und die Eingabe werden nicht überschrieben. Java-Escaping und echte
Java-Kompilation sind Teil der Tests. Der Generator schreibt nur `Catalog.java`.

**Erst nach tatsächlicher Rechteklärung und direkter Sponsorenvereinbarung**:

```powershell
./build.ps1 -SdkPath C:/Android/Sdk -JavaHome C:/Java/jdk-21 -SponsorCatalog C:/private/catalog.json -ConfirmSponsorRightsAndContract
```

Die ausdrückliche Option bestätigt Rechte an Marken/Text und den konkreten
Sponsorvertrag. Ohne sie bricht der Sponsorbuild ab. Der Build validiert die
Originaldatei erneut und kompiliert einen separaten generierten Katalog.
`app/src/main/.../Catalog.java` und der Demo-Manifest bleiben erhalten.
Das Paket heißt `de.leterel.adscroll.sponsors`, die APK
`adscroll-sponsors-0.1.0.apk`, die Beschriftung „SPONSOREN“/„WERBUNG“.
Dadurch ersetzt die APK keine installierte Demo und vermischt deren Appdaten nicht.
Die APK verwendet weiterhin die lokale Entwicklungssignatur, keine Store-Freigabe.
Der Gradle-/AAB-Weg baut weiterhin ausschließlich die Demo.

Die Bestätigungsoption ist eine bewusste Betreiberentscheidung, keine technische
Prüfung von Verträgen. Dieser Arbeitsstand enthält keinen freigegebenen
Produktionskatalog; Testdaten bleiben fiktiv und werden nicht als echte Kampagne gebaut.
