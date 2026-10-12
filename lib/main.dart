import 'package:flutter/material.dart';

import 'screens/temperature_converter_screen.dart';

void main() {
  runApp(const TemperatureConverterApp());
}

class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  ThemeData _buildTheme(Color seed, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(const Color(0xFF1E40AF), Brightness.light), // Royal Indigo
      darkTheme: _buildTheme(const Color(0xFF3B82F6), Brightness.dark),
      themeMode: ThemeMode.system,
      home: const TemperatureConverterScreen(),
    );
  }
}
