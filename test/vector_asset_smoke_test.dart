import 'package:aura_solar_icons/aura_solar_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Decodes every compiled `.vec` asset at least once, by pumping an
/// [AuraIcon] for each and letting it settle. This is the guard against a
/// `vector_graphics_compiler` (used at codegen time, in `tool/`) /
/// `vector_graphics` (the runtime dependency here) version skew — they share
/// a binary format, and a mismatch would surface as a decode exception here
/// rather than silently at some later point in a consuming app.
void main() {
  Future<void> checkAll(Map<String, AuraIconData> icons, WidgetTester tester) async {
    for (final entry in icons.entries) {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AuraIcon(entry.value, size: 24),
        ),
      );
      await tester.pump();
      // pumpWidget/pump succeeding without throwing is the assertion —
      // vector_graphics surfaces decode failures as exceptions during frame
      // scheduling, which flutter_test would propagate as a test failure.
    }
  }

  testWidgets('every Outline .vec asset decodes without error', (tester) async {
    await checkAll(AuraIconsOutline.all, tester);
  });

  testWidgets('every Linear .vec asset decodes without error', (tester) async {
    await checkAll(AuraIconsLinear.all, tester);
  });

  testWidgets('every Bold .vec asset decodes without error', (tester) async {
    await checkAll(AuraIconsBold.all, tester);
  });

  testWidgets('every Broken .vec asset decodes without error', (tester) async {
    await checkAll(AuraIconsBroken.all, tester);
  });

  testWidgets('every BoldDuotone .vec asset decodes without error', (tester) async {
    await checkAll(AuraIconsBoldDuotone.all, tester);
  });

  testWidgets('every LineDuotone .vec asset decodes without error', (tester) async {
    await checkAll(AuraIconsLineDuotone.all, tester);
  });
}
