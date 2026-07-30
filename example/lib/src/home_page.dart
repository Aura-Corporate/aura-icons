import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'color_preset.dart';
import 'hex_color.dart';
import 'icon_snippet.dart';
import 'icon_style.dart';
import 'widgets/color_picker_bar.dart';
import 'widgets/icon_grid.dart';
import 'widgets/icon_search_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Listened to so the accent color bar can show/hide as the active tab
  // changes (only the 2 duotone styles have one).
  late final TabController _tabController = TabController(length: kIconStyles.length, vsync: this)
    ..addListener(() => setState(() {}));

  Color _color = kColorPresets.first.color;
  late final TextEditingController _hexController = TextEditingController(
    text: kColorPresets.first.hex,
  );

  // Defaults to a different preset than _color so switching to a duotone
  // tab immediately shows two distinct colors rather than one flat color.
  Color _accentColor = kColorPresets[2].color;
  late final TextEditingController _accentHexController = TextEditingController(
    text: kColorPresets[2].hex,
  );
  bool _accentHexError = false;

  late final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _hexError = false;

  bool get _activeStyleHasAccent => kIconStyles[_tabController.index].hasAccent;

  @override
  void dispose() {
    _tabController.dispose();
    _hexController.dispose();
    _accentHexController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectPreset(ColorPreset preset) {
    setState(() {
      _color = preset.color;
      _hexError = false;
      _hexController.text = preset.hex;
    });
  }

  void _onHexChanged(String value) {
    final parsed = tryParseHexColor(value);
    setState(() {
      if (parsed == null) {
        _hexError = true;
      } else {
        _color = parsed;
        _hexError = false;
      }
    });
  }

  void _selectAccentPreset(ColorPreset preset) {
    setState(() {
      _accentColor = preset.color;
      _accentHexError = false;
      _accentHexController.text = preset.hex;
    });
  }

  void _onAccentHexChanged(String value) {
    final parsed = tryParseHexColor(value);
    setState(() {
      if (parsed == null) {
        _accentHexError = true;
      } else {
        _accentColor = parsed;
        _accentHexError = false;
      }
    });
  }

  void _onIconTap(String className, String name) {
    final snippet = buildIconSnippet(
      className: className,
      iconName: name,
      rawHex: _hexController.text,
      rawAccentHex: _activeStyleHasAccent ? _accentHexController.text : null,
    );
    Clipboard.setData(ClipboardData(text: snippet));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Pasted : $className.$name')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aura – Solar Icons'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [for (final style in kIconStyles) Tab(text: style.label)],
        ),
      ),
      body: Column(
        children: [
          IconSearchField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
          ),
          ColorPickerBar(
            hexController: _hexController,
            hexError: _hexError,
            selectedColor: _color,
            onHexChanged: _onHexChanged,
            onPresetSelected: _selectPreset,
          ),
          if (_activeStyleHasAccent)
            ColorPickerBar(
              label: 'Accent (hex)',
              hexController: _accentHexController,
              hexError: _accentHexError,
              selectedColor: _accentColor,
              onHexChanged: _onAccentHexChanged,
              onPresetSelected: _selectAccentPreset,
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final style in kIconStyles)
                  IconGrid(
                    style: style,
                    query: _query,
                    color: _color,
                    accentColor: style.hasAccent ? _accentColor : null,
                    onIconTap: _onIconTap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
