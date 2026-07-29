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

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 48, height: 48, child: Center(child: child)),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

const _galleryKey = Key('icon-gallery');

Widget _gallery() {
  return RepaintBoundary(
    key: _galleryKey,
    child: Material(
      child: Wrap(
        children: [
          for (final name in _sampleIconNames) ...[
            _GalleryTile(label: '$name/Outline', child: AuraIcon(AuraIconsOutline.all[name]!, size: 32)),
            _GalleryTile(label: '$name/Linear', child: AuraIcon(AuraIconsLinear.all[name]!, size: 32)),
            _GalleryTile(label: '$name/Bold', child: AuraIcon(AuraIconsBold.all[name]!, size: 32)),
            _GalleryTile(label: '$name/Broken', child: AuraIcon(AuraIconsBroken.all[name]!, size: 32)),
            _GalleryTile(
              label: '$name/BoldDuotone',
              child: AuraIcon(AuraIconsBoldDuotone.all[name]!, size: 32),
            ),
            _GalleryTile(
              label: '$name/LineDuotone',
              child: AuraIcon(AuraIconsLineDuotone.all[name]!, size: 32),
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
