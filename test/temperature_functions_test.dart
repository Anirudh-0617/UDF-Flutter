import 'package:flutter_test/flutter_test.dart';
import 'package:temperature_converter/utils/temperature_functions.dart';

void main() {
  group('Conversion UDFs', () {
    test('1. celsiusToFahrenheit converts correctly', () {
      expect(celsiusToFahrenheit(0.0), closeTo(32.0, 0.001));
      expect(celsiusToFahrenheit(100.0), closeTo(212.0, 0.001));
      expect(celsiusToFahrenheit(25.0), closeTo(77.0, 0.001));
      expect(celsiusToFahrenheit(-40.0), closeTo(-40.0, 0.001));
    });

    test('2. fahrenheitToCelsius converts correctly', () {
      expect(fahrenheitToCelsius(32.0), closeTo(0.0, 0.001));
      expect(fahrenheitToCelsius(212.0), closeTo(100.0, 0.001));
      expect(fahrenheitToCelsius(98.6), closeTo(37.0, 0.001));
      expect(fahrenheitToCelsius(-40.0), closeTo(-40.0, 0.001));
    });

    test('3. celsiusToKelvin converts correctly', () {
      expect(celsiusToKelvin(0.0), closeTo(273.15, 0.001));
      expect(celsiusToKelvin(-273.15), closeTo(0.0, 0.001));
      expect(celsiusToKelvin(100.0), closeTo(373.15, 0.001));
    });

    test('4. kelvinToCelsius converts correctly', () {
      expect(kelvinToCelsius(273.15), closeTo(0.0, 0.001));
      expect(kelvinToCelsius(0.0), closeTo(-273.15, 0.001));
      expect(kelvinToCelsius(310.15), closeTo(37.0, 0.001));
    });

    test('5. fahrenheitToKelvin converts correctly', () {
      expect(fahrenheitToKelvin(32.0), closeTo(273.15, 0.001));
      expect(fahrenheitToKelvin(-459.67), closeTo(0.0, 0.001));
      expect(fahrenheitToKelvin(77.0), closeTo(298.15, 0.001));
    });

    test('6. kelvinToFahrenheit converts correctly', () {
      expect(kelvinToFahrenheit(273.15), closeTo(32.0, 0.001));
      expect(kelvinToFahrenheit(0.0), closeTo(-459.67, 0.001));
      expect(kelvinToFahrenheit(373.15), closeTo(212.0, 0.001));
    });
  });

  group('convertTemperature dispatcher', () {
    test('7. routes all six directions', () {
      expect(convertTemperature(100, unitCelsius, unitFahrenheit), closeTo(212, 0.001));
      expect(convertTemperature(100, unitCelsius, unitKelvin), closeTo(373.15, 0.001));
      expect(convertTemperature(212, unitFahrenheit, unitCelsius), closeTo(100, 0.001));
      expect(convertTemperature(212, unitFahrenheit, unitKelvin), closeTo(373.15, 0.001));
      expect(convertTemperature(373.15, unitKelvin, unitCelsius), closeTo(100, 0.001));
      expect(convertTemperature(373.15, unitKelvin, unitFahrenheit), closeTo(212, 0.001));
    });

    test('identity rule returns input unchanged', () {
      for (final unit in supportedUnits) {
        expect(convertTemperature(42.5, unit, unit), 42.5);
      }
    });
  });

  group('validatePhysicalTemperature', () {
    test('8. rejects values below absolute zero', () {
      expect(validatePhysicalTemperature(-1, unitKelvin), isNotNull);
      expect(validatePhysicalTemperature(-273.16, unitCelsius), isNotNull);
      expect(validatePhysicalTemperature(-459.68, unitFahrenheit), isNotNull);
    });

    test('accepts values at or above absolute zero', () {
      expect(validatePhysicalTemperature(0, unitKelvin), isNull);
      expect(validatePhysicalTemperature(-273.15, unitCelsius), isNull);
      expect(validatePhysicalTemperature(-459.67, unitFahrenheit), isNull);
      expect(validatePhysicalTemperature(25, unitCelsius), isNull);
    });
  });

  group('Presentation helpers', () {
    test('9. getConversionFormula returns the right formula', () {
      expect(getConversionFormula(unitCelsius, unitFahrenheit), '°F = (°C × 9/5) + 32');
      expect(getConversionFormula(unitKelvin, unitCelsius), '°C = K - 273.15');
      expect(getConversionFormula(unitCelsius, unitCelsius), contains('No conversion needed'));
    });

    test('10. getUnitSymbol returns the right symbol', () {
      expect(getUnitSymbol(unitCelsius), '°C');
      expect(getUnitSymbol(unitFahrenheit), '°F');
      expect(getUnitSymbol(unitKelvin), 'K');
      expect(getUnitSymbol('unknown'), '');
    });
  });
}
