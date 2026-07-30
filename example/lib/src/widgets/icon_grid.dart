import 'package:flutter/material.dart';

import '../icon_style.dart';
import 'icon_tile.dart';

/// Grid of icons for a single style, filtered by [query].
class IconGrid extends StatelessWidget {
  const IconGrid({
    super.key,
    required this.style,
    required this.query,
    required this.color,
    this.accentColor,
    required this.onIconTap,
  });

  final IconStyle style;
  final String query;
  final Color color;
  final Color? accentColor;
  final void Function(String className, String name) onIconTap;

  @override
  Widget build(BuildContext context) {
    final entries = style.icons.entries
        .where((entry) => query.isEmpty || entry.key.toLowerCase().contains(query))
        .toList();

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No icon corresponds to « $query »',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 88,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return IconTile(
          name: entry.key,
          color: color,
          accentColor: accentColor,
          icon: entry.value,
          onTap: () => onIconTap(style.className, entry.key),
        );
      },
    );
  }
}
