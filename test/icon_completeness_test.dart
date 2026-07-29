import 'dart:io';

import 'package:aura_solar_icons/aura_solar_icons.dart';
import 'package:flutter_test/flutter_test.dart';

/// Total distinct icons in the upstream set, at the pinned commit
/// (`tool/src/config.dart`'s `upstreamCommitSha`). A handful may be missing
/// from an individual style — see [knownGaps] — but never from all of them.
const _totalIconCount = 1246;

void main() {
  final styles = <String, Map<String, AuraIconData>>{
    'AuraIconsOutline': AuraIconsOutline.all,
    'AuraIconsLinear': AuraIconsLinear.all,
    'AuraIconsBold': AuraIconsBold.all,
    'AuraIconsBroken': AuraIconsBroken.all,
    'AuraIconsBoldDuotone': AuraIconsBoldDuotone.all,
    'AuraIconsLineDuotone': AuraIconsLineDuotone.all,
  };

  int expectedCountFor(String styleClassName) {
    final gapCount = knownGaps.where((g) => g.$1 == styleClassName).length;
    return _totalIconCount - gapCount;
  }

  group('all 6 styles', () {
    for (final entry in styles.entries) {
      test('${entry.key} has the expected icon count, each with an existing .vec asset', () {
        final icons = entry.value;
        expect(icons.length, expectedCountFor(entry.key));
        for (final iconData in icons.values) {
          final assetFile = File(iconData.assetPath);
          expect(assetFile.existsSync(), isTrue, reason: '${iconData.assetPath} missing on disk');
        }
      });
    }
  });

  test('every gap is accounted for: the icon exists in every OTHER style', () {
    for (final gap in knownGaps) {
      final (missingFromStyle, iconName) = gap;
      for (final entry in styles.entries) {
        if (entry.key == missingFromStyle) {
          expect(entry.value.containsKey(iconName), isFalse,
              reason: '$iconName is listed as a known gap in $missingFromStyle but is actually present');
        } else {
          expect(entry.value.containsKey(iconName), isTrue,
              reason: '$iconName (gap in $missingFromStyle) should still exist in ${entry.key}');
        }
      }
    }
  });
}
