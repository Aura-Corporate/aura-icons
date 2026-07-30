import 'package:aura_solar_icons/aura_solar_icons.dart';
import 'package:flutter/material.dart';

/// A single icon in the grid; tapping it copies its Flutter usage snippet.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.name,
    required this.color,
    this.accentColor,
    required this.icon,
    required this.onTap,
  });

  final String name;
  final Color color;

  /// Ignored by [AuraIcon] for single-tone icons (no accent layer exists).
  final Color? accentColor;
  final AuraIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuraIcon(icon, size: 32, color: color, accentColor: accentColor),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
