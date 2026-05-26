import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temperatur_umrechner/main.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(const TemperaturApp());
    await tester.pump();
  }

  String ausgabeText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('ausgabe'))).data!;

  // AC1 + AC2: numerisches Feld + sichtbare °F-Ausgabe, korrekte Vorwärtsformel.
  testWidgets('AC2 °C→°F Referenzwerte 100→212, 0→32, -40→-40',
      (tester) async {
    await pump(tester);

    for (final fall in {'100': '212 °F', '0': '32 °F', '-40': '-40 °F'}.entries) {
      await tester.enterText(find.byKey(const Key('eingabe')), fall.key);
      await tester.pump();
      expect(ausgabeText(tester), fall.value,
          reason: '${fall.key} °C sollte ${fall.value} ergeben');
    }
  });

  // AC4: leer/nicht-numerisch → Fehlermeldung; danach wieder gültig → Wert.
  testWidgets('AC4 ungültige Eingabe zeigt Fehlermeldung, dann wieder Wert',
      (tester) async {
    await pump(tester);

    await tester.enterText(find.byKey(const Key('eingabe')), 'abc');
    await tester.pump();
    expect(find.text(fehlerText), findsOneWidget);

    await tester.enterText(find.byKey(const Key('eingabe')), '100');
    await tester.pump();
    expect(find.text(fehlerText), findsNothing);
    expect(ausgabeText(tester), '212 °F');
  });

  // AC5: Toggle kippt Richtung; Rückformel korrekt 212→100, 32→0, -40→-40.
  testWidgets('AC5 °F→°C Referenzwerte nach Umschalten', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('toggle')));
    await tester.pump();

    for (final fall in {'212': '100 °C', '32': '0 °C', '-40': '-40 °C'}.entries) {
      await tester.enterText(find.byKey(const Key('eingabe')), fall.key);
      await tester.pump();
      expect(ausgabeText(tester), fall.value,
          reason: '${fall.key} °F sollte ${fall.value} ergeben');
    }
  });

  // AC6: beim Umschalten wird der Ausgabewert zur neuen Eingabe.
  testWidgets('AC6 Wert-Kontinuität: 100°C→212°F, umschalten → Eingabe 212, '
      'Ausgabe 100 °C', (tester) async {
    await pump(tester);

    await tester.enterText(find.byKey(const Key('eingabe')), '100');
    await tester.pump();
    expect(ausgabeText(tester), '212 °F');

    await tester.tap(find.byKey(const Key('toggle')));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byKey(const Key('eingabe'))).controller!.text,
      '212',
    );
    expect(ausgabeText(tester), '100 °C');
  });

  // AC6: ungültige/leere Ausgabe → andere Richtung startet leer.
  testWidgets('AC6 leere Ausgabe → nach Umschalten leeres Feld',
      (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('toggle')));
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byKey(const Key('eingabe'))).controller!.text,
      '',
    );
    expect(ausgabeText(tester), '—');
  });
}
