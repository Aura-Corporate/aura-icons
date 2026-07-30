import 'package:flutter/material.dart';

import 'src/home_page.dart';

void main() => runApp(const AuraIconsExampleApp());

const _creamBackground = Color(0xFFFDFFFF);

class AuraIconsExampleApp extends StatelessWidget {
  const AuraIconsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura | Solar Icons',
      theme: ThemeData(
        scaffoldBackgroundColor: _creamBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: _creamBackground,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const HomePage(),
    );
  }
}
