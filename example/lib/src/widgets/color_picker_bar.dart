import 'package:flutter/material.dart';

import '../color_preset.dart';
import 'color_preset_swatch.dart';

/// Hex input + preset swatches row used to choose the color the icon grid
/// is previewed with.
class ColorPickerBar extends StatelessWidget {
  const ColorPickerBar({
    super.key,
    required this.hexController,
    required this.hexError,
    required this.selectedColor,
    required this.onHexChanged,
    required this.onPresetSelected,
    this.label = 'Color (hex)',
  });

  final TextEditingController hexController;
  final bool hexError;
  final Color selectedColor;
  final ValueChanged<String> onHexChanged;
  final ValueChanged<ColorPreset> onPresetSelected;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: TextField(
              controller: hexController,
              onChanged: onHexChanged,
              maxLength: 8,
              decoration: InputDecoration(
                prefixText: '#',
                labelText: label,
                isDense: true,
                counterText: '',
                border: const OutlineInputBorder(),
                errorText: hexError ? 'Invalid hex' : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final preset in kColorPresets)
                  ColorPresetSwatch(
                    color: preset.color,
                    selected: preset.color == selectedColor,
                    onTap: () => onPresetSelected(preset),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
