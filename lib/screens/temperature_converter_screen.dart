import 'package:flutter/material.dart';

import '../utils/temperature_functions.dart';
import '../widgets/temperature_dropdown.dart';

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() => _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();

  String _fromUnit = unitCelsius;
  String _toUnit = unitFahrenheit;

  double? _inputTemperature;
  double? _convertedResult;
  String? _errorMessage;
  bool _hasConverted = false;

  late AnimationController _resultAnimController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(parent: _resultAnimController, curve: Curves.easeOutBack);
    _fadeAnimation = CurvedAnimation(parent: _resultAnimController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  void _showError(String message, {bool snackBar = false}) {
    setState(() {
      _errorMessage = message;
      _convertedResult = null;
      _hasConverted = false;
    });
    if (snackBar) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
    }
  }

  void _performConversion() {
    FocusScope.of(context).unfocus();

    final rawInput = _inputController.text.trim();
    if (rawInput.isEmpty) {
      _showError('Please enter a temperature value.', snackBar: true);
      return;
    }

    final value = double.tryParse(rawInput);
    if (value == null) {
      _showError('Please enter a valid numeric value (e.g. 25 or 98.6).');
      return;
    }

    final physicalError = validatePhysicalTemperature(value, _fromUnit);
    if (physicalError != null) {
      _showError(physicalError);
      return;
    }

    setState(() {
      _inputTemperature = value;
      _convertedResult = convertTemperature(value, _fromUnit, _toUnit);
      _errorMessage = null;
      _hasConverted = true;
    });
    _resultAnimController.forward(from: 0.0);
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
    if (_hasConverted) _performConversion();
  }

  void _clearAll() {
    _inputController.clear();
    _resultAnimController.reset();
    setState(() {
      _fromUnit = unitCelsius;
      _toUnit = unitFahrenheit;
      _inputTemperature = null;
      _convertedResult = null;
      _errorMessage = null;
      _hasConverted = false;
    });
  }

  void _showUdfInfoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.functions_rounded),
        title: const Text('About the UDFs'),
        content: const SingleChildScrollView(
          child: Text(
            'All conversion logic lives in lib/utils/temperature_functions.dart as '
            'pure User Defined Functions:\n\n'
            '• celsiusToFahrenheit()\n'
            '• fahrenheitToCelsius()\n'
            '• celsiusToKelvin()\n'
            '• kelvinToCelsius()\n'
            '• fahrenheitToKelvin()\n'
            '• kelvinToFahrenheit()\n'
            '• convertTemperature() — dispatcher\n'
            '• validatePhysicalTemperature() — absolute zero check\n'
            '• getConversionFormula() / getUnitSymbol() — display helpers\n\n'
            'The UI only collects input and calls these functions.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        actions: [
          IconButton(
            tooltip: 'About UDFs',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showUdfInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeaderSection(context),
                const SizedBox(height: 24),
                _buildInputSection(context),
                const SizedBox(height: 16),
                _buildUnitSelectors(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 24),
                if (_hasConverted && _convertedResult != null) _buildResultCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.thermostat_rounded, size: 36, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 12),
        Text(
          'Convert between Celsius, Fahrenheit & Kelvin',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return TextField(
      controller: _inputController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _performConversion(),
      onChanged: (_) {
        if (_errorMessage != null) setState(() => _errorMessage = null);
      },
      decoration: InputDecoration(
        labelText: 'Enter temperature',
        hintText: 'e.g. 25 or 98.6',
        prefixIcon: const Icon(Icons.edit_rounded),
        suffixText: getUnitSymbol(_fromUnit),
        errorText: _errorMessage,
        errorMaxLines: 3,
      ),
    );
  }

  Widget _buildUnitSelectors() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TemperatureDropdown(
            label: 'From',
            value: _fromUnit,
            onChanged: (unit) {
              if (unit == null) return;
              setState(() => _fromUnit = unit);
              if (_hasConverted) _performConversion();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton.filledTonal(
            tooltip: 'Swap units',
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: _swapUnits,
          ),
        ),
        Expanded(
          child: TemperatureDropdown(
            label: 'To',
            value: _toUnit,
            onChanged: (unit) {
              if (unit == null) return;
              setState(() => _toUnit = unit);
              if (_hasConverted) _performConversion();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_rounded),
            label: const Text('Clear'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: _performConversion,
            icon: const Icon(Icons.calculate_rounded),
            label: const Text('Convert'),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final fromSymbol = getUnitSymbol(_fromUnit);
    final toSymbol = getUnitSymbol(_toUnit);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          color: colorScheme.primaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Result',
                  style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_convertedResult!.toStringAsFixed(2)} $toSymbol',
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_inputTemperature!.toStringAsFixed(2)} $fromSymbol = '
                    '${_convertedResult!.toStringAsFixed(2)} $toSymbol',
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimaryContainer),
                  ),
                ),
                const Divider(height: 24),
                Text(
                  'Formula: ${getConversionFormula(_fromUnit, _toUnit)}',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
