// Pure Dart User Defined Functions (UDFs) for temperature conversion.
// Contains no Flutter UI code.

const double absoluteZeroKelvin = 0.0;
const double absoluteZeroCelsius = -273.15;
const double absoluteZeroFahrenheit = -459.67;

const String unitCelsius = 'Celsius (°C)';
const String unitFahrenheit = 'Fahrenheit (°F)';
const String unitKelvin = 'Kelvin (K)';

const List<String> supportedUnits = [
  unitCelsius,
  unitFahrenheit,
  unitKelvin,
];

// 1. Celsius to Fahrenheit
double celsiusToFahrenheit(double celsius) {
  return (celsius * 9 / 5) + 32;
}

// 2. Fahrenheit to Celsius
double fahrenheitToCelsius(double fahrenheit) {
  return (fahrenheit - 32) * 5 / 9;
}

// 3. Celsius to Kelvin
double celsiusToKelvin(double celsius) {
  return celsius + 273.15;
}

// 4. Kelvin to Celsius
double kelvinToCelsius(double kelvin) {
  return kelvin - 273.15;
}

// 5. Fahrenheit to Kelvin
double fahrenheitToKelvin(double fahrenheit) {
  return (fahrenheit - 32) * 5 / 9 + 273.15;
}

// 6. Kelvin to Fahrenheit
double kelvinToFahrenheit(double kelvin) {
  return (kelvin - 273.15) * 9 / 5 + 32;
}

/// Dispatcher UDF: routes a conversion request to the matching UDF.
double convertTemperature(double value, String fromUnit, String toUnit) {
  if (fromUnit == toUnit) return value;

  if (fromUnit == unitCelsius && toUnit == unitFahrenheit) return celsiusToFahrenheit(value);
  if (fromUnit == unitCelsius && toUnit == unitKelvin) return celsiusToKelvin(value);

  if (fromUnit == unitFahrenheit && toUnit == unitCelsius) return fahrenheitToCelsius(value);
  if (fromUnit == unitFahrenheit && toUnit == unitKelvin) return fahrenheitToKelvin(value);

  if (fromUnit == unitKelvin && toUnit == unitCelsius) return kelvinToCelsius(value);
  if (fromUnit == unitKelvin && toUnit == unitFahrenheit) return kelvinToFahrenheit(value);

  return value; // Fallback safety
}

/// Returns an error message if [value] is below absolute zero, else null.
String? validatePhysicalTemperature(double value, String unit) {
  if (unit == unitKelvin && value < absoluteZeroKelvin) {
    return 'Invalid temperature: Kelvin cannot be below 0 K (Absolute Zero).';
  }
  if (unit == unitCelsius && value < absoluteZeroCelsius) {
    return 'Invalid temperature: Celsius cannot be below -273.15 °C (Absolute Zero).';
  }
  if (unit == unitFahrenheit && value < absoluteZeroFahrenheit) {
    return 'Invalid temperature: Fahrenheit cannot be below -459.67 °F (Absolute Zero).';
  }
  return null; // Valid
}

String getConversionFormula(String fromUnit, String toUnit) {
  if (fromUnit == toUnit) return 'Identical units selected: No conversion needed (Result = Input).';
  if (fromUnit == unitCelsius && toUnit == unitFahrenheit) return '°F = (°C × 9/5) + 32';
  if (fromUnit == unitFahrenheit && toUnit == unitCelsius) return '°C = (°F - 32) × 5/9';
  if (fromUnit == unitCelsius && toUnit == unitKelvin) return 'K = °C + 273.15';
  if (fromUnit == unitKelvin && toUnit == unitCelsius) return '°C = K - 273.15';
  if (fromUnit == unitFahrenheit && toUnit == unitKelvin) return 'K = (°F - 32) × 5/9 + 273.15';
  if (fromUnit == unitKelvin && toUnit == unitFahrenheit) return '°F = (K - 273.15) × 9/5 + 32';
  return 'Formula not available';
}

String getUnitSymbol(String unit) {
  if (unit == unitCelsius) return '°C';
  if (unit == unitFahrenheit) return '°F';
  if (unit == unitKelvin) return 'K';
  return '';
}
