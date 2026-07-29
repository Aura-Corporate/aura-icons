import 'package:aura_icons/aura_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A curated sample spanning all 6 styles.
const _sampleIconNames = [
  'home',
  'arrowDown',
  'user',
  'closeSquare',
  'star',
  'settings',
];

const _galleryKey = Key('icon-gallery');

/// Icons only — no text labels. Text rasterizes differently across
/// platforms (font fallback/hinting differs between macOS and the Linux CI
/// runner), which made this golden flaky across machines even though the
/// vector icon rendering itself is deterministic. Keeping the captured
/// region to pure vector shapes makes the golden meaningful cross-platform.
Widget _gallery() {
  return RepaintBoundary(
    key: _galleryKey,
    child: ColoredBox(
      color: Colors.white,
      child: Wrap(
        children: [
          for (final name in _sampleIconNames) ...[
            SizedBox(width: 40, height: 40, child: Center(child: AuraIcon(AuraIconsOutline.all[name]!, size: 32))),
            SizedBox(width: 40, height: 40, child: Center(child: AuraIcon(AuraIconsLinear.all[name]!, size: 32))),
            SizedBox(width: 40, height: 40, child: Center(child: AuraIcon(AuraIconsBold.all[name]!, size: 32))),
            SizedBox(width: 40, height: 40, child: Center(child: AuraIcon(AuraIconsBroken.all[name]!, size: 32))),
            SizedBox(
              width: 40,
              height: 40,
              child: Center(child: AuraIcon(AuraIconsBoldDuotone.all[name]!, size: 32)),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: Center(child: AuraIcon(AuraIconsLineDuotone.all[name]!, size: 32)),
            ),
          ],
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('icon gallery golden — sample across all 6 styles', (tester) async {
    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: _gallery()),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(_galleryKey),
      matchesGoldenFile('goldens/icon_gallery.png'),
    );
  });
}
