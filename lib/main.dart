import 'package:flutter/material.dart';

void main() => runApp(const TemperaturApp());

/// Umrechnungsrichtung (AC5): aktive Quell- → Ziel-Einheit.
enum Richtung {
  cToF, // °C → °F
  fToC, // °F → °C
}

const String fehlerText = 'Bitte eine gültige Zahl eingeben.';

class TemperaturApp extends StatelessWidget {
  const TemperaturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperatur-Umrechner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const UmrechnerSeite(),
    );
  }
}

class UmrechnerSeite extends StatefulWidget {
  const UmrechnerSeite({super.key});

  @override
  State<UmrechnerSeite> createState() => _UmrechnerSeiteState();
}

class _UmrechnerSeiteState extends State<UmrechnerSeite> {
  final TextEditingController _eingabe = TextEditingController();

  Richtung _richtung = Richtung.cToF;

  @override
  void initState() {
    super.initState();
    // Live-Umrechnung ohne Seitenneuladen (AC3): jede Eingabe-Änderung
    // löst einen Rebuild aus, der Ausgabe bzw. Fehlermeldung neu berechnet.
    _eingabe.addListener(_onEingabeGeaendert);
  }

  @override
  void dispose() {
    // Controller freigeben (flutter/R02).
    _eingabe.removeListener(_onEingabeGeaendert);
    _eingabe.dispose();
    super.dispose();
  }

  void _onEingabeGeaendert() => setState(() {});

  /// Parst die Eingabe zu einer Zahl oder null (leer / nicht-numerisch → AC4).
  double? get _eingabeWert {
    final text = _eingabe.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.'));
  }

  /// Quell-Einheit der aktuellen Richtung.
  String get _quellEinheit => _richtung == Richtung.cToF ? '°C' : '°F';

  /// Ziel-Einheit der aktuellen Richtung.
  String get _zielEinheit => _richtung == Richtung.cToF ? '°F' : '°C';

  /// Berechnet den Ausgabewert in der Ziel-Einheit oder null bei ungültiger Eingabe.
  /// Vorwärts: °F = °C × 9/5 + 32 · Rückwärts: °C = (°F − 32) × 5/9 (AC2/AC5).
  double? get _ausgabeWert {
    final wert = _eingabeWert;
    if (wert == null) return null;
    return _richtung == Richtung.cToF
        ? wert * 9 / 5 + 32
        : (wert - 32) * 5 / 9;
  }

  /// Formatiert eine Zahl ohne überflüssige Nachkommastellen (212.0 → "212").
  String _formatZahl(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  /// Schaltet die Richtung um (AC5) und überträgt den Ausgabewert als neue
  /// Eingabe (AC6). Ist die Ausgabe ungültig/leer, startet die andere
  /// Richtung mit leerem Feld.
  void _richtungUmschalten() {
    final aktuelleAusgabe = _ausgabeWert;
    setState(() {
      _richtung =
          _richtung == Richtung.cToF ? Richtung.fToC : Richtung.cToF;
      _eingabe.text =
          aktuelleAusgabe == null ? '' : _formatZahl(aktuelleAusgabe);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ausgabe = _ausgabeWert;
    final hatEingabe = _eingabe.text.trim().isNotEmpty;
    // Fehler nur zeigen, wenn etwas eingegeben wurde, das ungültig ist –
    // sonst (leeres Feld beim Start) bleibt die Ausgabe schlicht leer (AC4).
    final zeigeFehler = hatEingabe && ausgabe == null;

    return Scaffold(
      appBar: AppBar(title: const Text('Temperatur-Umrechner')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AC5: Umschalt-Button GANZ OBEN; zeigt die Zielrichtung an.
                FilledButton.tonalIcon(
                  key: const Key('toggle'),
                  onPressed: _richtungUmschalten,
                  icon: const Icon(Icons.swap_horiz),
                  label: Text('Auf $_quellEinheit → $_zielEinheit umschalten'),
                ),
                const SizedBox(height: 24),
                // AC1: numerisches Eingabefeld der aktiven Quell-Einheit.
                TextField(
                  key: const Key('eingabe'),
                  controller: _eingabe,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Temperatur in $_quellEinheit',
                    border: const OutlineInputBorder(),
                    errorText: zeigeFehler ? fehlerText : null,
                  ),
                ),
                const SizedBox(height: 24),
                // AC1/AC2/AC5: sichtbare Ausgabe in der Ziel-Einheit.
                Text(
                  'Ergebnis',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  key: const Key('ausgabe'),
                  ausgabe == null
                      ? '—'
                      : '${_formatZahl(ausgabe)} $_zielEinheit',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
