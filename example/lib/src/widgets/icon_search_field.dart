import 'package:aura_solar_icons/aura_solar_icons.dart';
import 'package:flutter/material.dart';

/// Search bar filtering the icon grid by name; shared above the tabs so a
/// query survives switching style.
class IconSearchField extends StatelessWidget {
  const IconSearchField({super.key, required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: AuraIcon(
              AuraIconsOutline.magnifier,
              size: 18,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          hintText: 'Search an icon…',
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
