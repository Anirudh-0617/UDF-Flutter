import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:temperature_converter/main.dart';

void main() {
  testWidgets('converts 25 °C to 77 °F and clears', (WidgetTester tester) async {
    await tester.pumpWidget(const TemperatureConverterApp());

    await tester.enterText(find.byType(TextField), '25');
    await tester.tap(find.widgetWithText(FilledButton, 'Convert'));
    await tester.pumpAndSettle();

    expect(find.text('25.00 °C = 77.00 °F'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Clear'));
    await tester.pumpAndSettle();

    expect(find.text('25.00 °C = 77.00 °F'), findsNothing);
  });

  testWidgets('shows validation error for empty input', (WidgetTester tester) async {
    await tester.pumpWidget(const TemperatureConverterApp());

    await tester.tap(find.widgetWithText(FilledButton, 'Convert'));
    await tester.pumpAndSettle();

    // Inline error + SnackBar
    expect(find.text('Please enter a temperature value.'), findsNWidgets(2));
  });

  testWidgets('shows error for non-numeric input', (WidgetTester tester) async {
    await tester.pumpWidget(const TemperatureConverterApp());

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'Convert'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid numeric value (e.g. 25 or 98.6).'), findsOneWidget);
  });

  testWidgets('rejects temperature below absolute zero', (WidgetTester tester) async {
    await tester.pumpWidget(const TemperatureConverterApp());

    await tester.enterText(find.byType(TextField), '-300');
    await tester.tap(find.widgetWithText(FilledButton, 'Convert'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Absolute Zero'), findsOneWidget);
  });

  testWidgets('swap re-runs the conversion', (WidgetTester tester) async {
    await tester.pumpWidget(const TemperatureConverterApp());

    await tester.enterText(find.byType(TextField), '212');
    await tester.tap(find.widgetWithText(FilledButton, 'Convert'));
    await tester.pumpAndSettle();
    expect(find.text('212.00 °C = 413.60 °F'), findsOneWidget);

    await tester.tap(find.byTooltip('Swap units'));
    await tester.pumpAndSettle();
    expect(find.text('212.00 °F = 100.00 °C'), findsOneWidget);
  });
}
