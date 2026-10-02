# Wallet Sim – IPA bauen unter Windows

Reine Simulation: fiktive Karten, simulierte Salden, keine echten Zahlungen.

## 1. IPA über GitHub bauen lassen
1. Konto auf github.com anlegen → oben rechts "+" → "New repository"
   Name: WalletSim · Public (Mac-Build-Minuten unbegrenzt) → Create
2. "uploading an existing file" klicken
3. ALLES aus diesem Ordner reinziehen (inkl. Ordner ".github") → Commit changes
4. Prüfen: Im Repo muss ".github/workflows/build-ipa.yml" existieren
5. Tab "Actions" → "Build IPA" → "Run workflow" (startet auch automatisch)
6. Nach ca. 5–10 Min: Lauf anklicken → unten "Artifacts" → WalletSim-ipa
   herunterladen → ZIP entpacken → WalletSim.ipa

Roter Lauf = Build-Fehler → Artifact "build-log" laden und Fehler melden.

## 2. Mit Sideloadly installieren
1. iTunes + iCloud von apple.com installieren (NICHT Microsoft Store)
2. Sideloadly von sideloadly.io installieren
3. iPhone per Kabel → "Vertrauen"
4. iPhone: Einstellungen → Datenschutz & Sicherheit → Entwicklermodus → an
5. Sideloadly: IPA reinziehen → Apple-ID eingeben → Start
6. iPhone: Einstellungen → Allgemein → VPN & Geräteverwaltung → Vertrauen

Gültig 7 Tage → danach in Sideloadly erneut installieren (Daten bleiben).
