---
id: celsius-fahrenheit
title: Temperatur-Umrechner (Celsius ↔ Fahrenheit)
status: active
version: 3
---

# Spec: Temperatur-Umrechner (Celsius ↔ Fahrenheit)  (`celsius-fahrenheit`)

> **Schicht 3 von 3.** Testbares Verhalten + Verträge, sprach-/paradigma-unabhängig.
> Source of Truth für `coder` (baut daraus), `tester` (testet die Acceptance-Kriterien), `reviewer` (prüft den Diff dagegen).

## Zweck
Eine statische Seite, auf der man einen Temperaturwert eingibt und den umgerechneten Wert sieht — wahlweise **°C → °F** oder, per Umschalt-Button, **°F → °C**.

## Verhalten
- Given die Seite ist geladen, When der Nutzer eine Zahl ins Eingabefeld eingibt, Then erscheint der berechnete Wert in der jeweils anderen Einheit.
- Vorwärts: **°F = °C × 9/5 + 32**. Rückwärts: **°C = (°F − 32) × 5/9**.
- Die Anzeige aktualisiert sich **ohne Seitenneuladen**.
- Given das Eingabefeld ist leer oder enthält keine gültige Zahl, When sich die Eingabe ändert, Then wird **kein** berechneter Wert angezeigt, sondern eine verständliche Fehlermeldung.
- Given oben steht ein Umschalt-Button, When der Nutzer ihn drückt, Then kippt die Richtung (°C→°F ↔ °F→°C): Eingabe-/Ausgabe-Beschriftung und Formel wechseln, und der zuletzt angezeigte Ausgabewert wird zur neuen Eingabe.

## Acceptance-Kriterien
- **AC1** — Es gibt ein numerisches Eingabefeld für Grad Celsius und eine sichtbare Ausgabe für Grad Fahrenheit.
- **AC2** — Für eine gültige Zahl wird `°F = °C × 9/5 + 32` korrekt berechnet und angezeigt (Referenzwerte: `100 → 212`, `0 → 32`, `-40 → -40`).
- **AC3** — Die Umrechnung erfolgt clientseitig ohne Seitenneuladen (live bei Eingabe oder per Umrechnen-Button).
- **AC4** — Bei leerer oder nicht-numerischer Eingabe wird statt eines Werts eine verständliche Fehlermeldung angezeigt (konkreter Wortlaut: „Bitte eine gültige Zahl eingeben."); sobald wieder eine gültige Zahl eingegeben wird, erscheint der korrekte Wert. Gilt in **beiden** Richtungen.
- **AC5** — **Ganz oben** steht ein Button, der die Umrechnungsrichtung umschaltet (°C→°F ↔ °F→°C). Nach dem Umschalten gelten die getauschten Einheiten für Eingabe-Label und Ausgabe, und es wird die passende Formel verwendet. Rückrichtung `°C = (°F − 32) × 5/9` korrekt (Referenzwerte: `212 → 100`, `32 → 0`, `-40 → -40`). Der Button zeigt erkennbar die Zielrichtung an.
- **AC6** — Beim Umschalten wird der zuletzt angezeigte **Ausgabewert zur neuen Eingabe** (Kontinuität): steht z. B. `100 °C → 212 °F` und man schaltet um, enthält das Eingabefeld `212` (jetzt °F) und die Ausgabe zeigt `100 °C`. Ist die Ausgabe gerade ungültig/leer, startet die andere Richtung mit leerem Feld (Fehler-/Leerzustand gemäß AC4).

## Verträge
- **Eingabe:** ein Zahlenwert in der aktiven Quell-Einheit (Eingabefeld).
- **Ausgabe:** der berechnete Wert in der Ziel-Einheit als Text auf der Seite.
- **Formeln:** `fahrenheit = celsius * 9 / 5 + 32` · `celsius = (fahrenheit - 32) * 5 / 9`.
- **Richtung:** Zustand „aktive Richtung" (°C→°F oder °F→°C), umschaltbar per Button (AC5).

## Edge-Cases & Fehlerverhalten
- Negative Werte und Null sind gültige Eingaben (siehe Referenzwerte beider Richtungen).
- Leere Eingabe und nicht-numerische Eingabe → Fehlermeldung statt Wert (AC4), in beiden Richtungen.
- Umschalten bei ungültiger/leerer Ausgabe → andere Richtung startet leer (AC6).

## NFRs
- Rein clientseitig (statisches HTML/JS), keine Netzwerkaufrufe.

## Nicht-Ziele
- Weitere Einheiten (Kelvin etc.).

## Änderungshistorie
- **v3** — Richtungs-Toggle °C↔°F (AC5) + Werte-Kontinuität beim Umschalten (AC6); Rückrichtung ist nun in Scope (war in v1/v2 Nicht-Ziel).
- **v2** — Eingabe-Validierung/Fehlermeldung (AC4) aufgenommen (war in v1 Nicht-Ziel).

## Abhängigkeiten
- keine.
