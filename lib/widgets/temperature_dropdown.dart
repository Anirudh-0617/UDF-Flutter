import 'package:flutter/material.dart';

import '../utils/temperature_functions.dart';

/// Reusable unit selector used for both the "From" and "To" pickers.
class TemperatureDropdown extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String?> onChanged;

  const TemperatureDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  IconData _iconFor(String unit) {
    if (unit == unitCelsius) return Icons.ac_unit_rounded;
    if (unit == unitFahrenheit) return Icons.local_fire_department_rounded;
    return Icons.science_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              borderRadius: BorderRadius.circular(16),
              onChanged: onChanged,
              items: supportedUnits
                  .map(
                    (unit) => DropdownMenuItem<String>(
                      value: unit,
                      child: Row(
                        children: [
                          Icon(_iconFor(unit), size: 20, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(unit, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
