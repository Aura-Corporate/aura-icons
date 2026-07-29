import 'package:aura_icons/aura_icons.dart';
import 'package:flutter/material.dart';

void main() => runApp(const AuraIconsExampleApp());

class AuraIconsExampleApp extends StatelessWidget {
  const AuraIconsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'aura_icons example',
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('aura_icons'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Outline'),
              Tab(text: 'Linear'),
              Tab(text: 'Bold'),
              Tab(text: 'Broken'),
              Tab(text: 'BoldDuotone'),
              Tab(text: 'LineDuotone'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _IconGrid(icons: AuraIconsOutline.all),
            _IconGrid(icons: AuraIconsLinear.all),
            _IconGrid(icons: AuraIconsBold.all),
            _IconGrid(icons: AuraIconsBroken.all),
            _IconGrid(icons: AuraIconsBoldDuotone.all),
            _IconGrid(icons: AuraIconsLineDuotone.all),
          ],
        ),
      ),
    );
  }
}

class _IconGrid extends StatelessWidget {
  const _IconGrid({required this.icons});

  final Map<String, AuraIconData> icons;

  @override
  Widget build(BuildContext context) {
    final entries = icons.entries.toList();
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: 88,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _IconTile(name: entry.key, child: AuraIcon(entry.value, size: 32));
      },
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.name, required this.child});

  final String name;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 4),
        Text(
          name,
          style: Theme.of(context).textTheme.labelSmall,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
