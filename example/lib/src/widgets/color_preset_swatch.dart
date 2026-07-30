import 'package:flutter/material.dart';

/// A single circular preset swatch in the [ColorPickerBar]. Named to avoid
/// colliding with Flutter's own [ColorSwatch].
class ColorPresetSwatch extends StatelessWidget {
  const ColorPresetSwatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.black26,
            width: selected ? 2 : 1,
          ),
        ),
      ),
    );
  }
}
