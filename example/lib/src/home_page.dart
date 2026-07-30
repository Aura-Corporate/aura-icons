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

class _HomePageState extends State<HomePage> {
  Color _color = kColorPresets.first.color;
  late final TextEditingController _hexController = TextEditingController(
    text: kColorPresets.first.hex,
  );
  late final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _hexError = false;

  @override
  void dispose() {
    _hexController.dispose();
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

  void _onIconTap(String className, String name) {
    final snippet = buildIconSnippet(
      className: className,
      iconName: name,
      rawHex: _hexController.text,
    );
    Clipboard.setData(ClipboardData(text: snippet));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Pasted : $className.$name')));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: kIconStyles.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Aura – Solar Icons'),
          bottom: TabBar(
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
            Expanded(
              child: TabBarView(
                children: [
                  for (final style in kIconStyles)
                    IconGrid(
                      style: style,
                      query: _query,
                      color: _color,
                      onIconTap: _onIconTap,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
