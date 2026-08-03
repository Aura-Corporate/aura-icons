import 'package:aura_solar_icons_tool/src/codegen_dart.dart';
import 'package:aura_solar_icons_tool/src/config.dart';
import 'package:test/test.dart';

void main() {
  group('resolveAllIdentifiers', () {
    test('resolves plain names and reserved-word collisions', () {
      final result = resolveAllIdentifiers(['arrow-down', 'export', 'home'], {});
      expect(result, {
        'arrow-down': 'arrowDown',
        'export': 'exportIcon',
        'home': 'home',
      });
    });

    test('throws DuplicateIdentifierException on a genuine collision', () {
      // Contrived: two different kebab names that happen to camelCase to
      // the same identifier once one is manually overridden to collide.
      expect(
        () => resolveAllIdentifiers(
          ['arrow-down', 'arrow-down-alt'],
          {'arrow-down-alt': 'arrowDown'},
        ),
        throwsA(isA<DuplicateIdentifierException>()),
      );
    });
  });

  group('generateIconStyleFile', () {
    test('emits a class with sorted AuraIconData fields and an all map', () {
      final content = generateIconStyleFile(
        style: IconStyle.outline,
        sortedIconNames: ['arrow-down', 'home'],
        overrides: const {},
      );

      expect(content, contains('class AuraIconsOutline {'));
      expect(content, contains("import '../icon/icon_data.dart';"));
      expect(
        content,
        contains(
          "static const AuraIconData arrowDown = AuraIconData("
          "'assets/vectors/outline/arrow-down.vec');",
        ),
      );
      expect(
        content,
        contains(
          "static const AuraIconData home = AuraIconData("
          "'assets/vectors/outline/home.vec');",
        ),
      );
      // Fields sorted by Dart identifier, not by source kebab order.
      expect(content.indexOf('arrowDown'), lessThan(content.indexOf('static const AuraIconData home')));
    });

    test('emits a class for a duotone style pointing at its own asset subdir', () {
      final content = generateIconStyleFile(
        style: IconStyle.boldDuotone,
        sortedIconNames: ['arrow-down', 'home'],
        overrides: const {},
      );

      expect(content, contains('class AuraIconsBoldDuotone {'));
      expect(
        content,
        contains(
          "static const AuraIconData arrowDown = AuraIconData("
          "'assets/vectors/bold_duotone/arrow-down.vec');",
        ),
      );
    });

    test('emits accentAssetPath only for icons in accentIconNames', () {
      final content = generateIconStyleFile(
        style: IconStyle.boldDuotone,
        sortedIconNames: ['arrow-down', 'home'],
        overrides: const {},
        accentIconNames: {'home': false},
      );

      expect(
        content,
        contains(
          "static const AuraIconData home = AuraIconData("
          "'assets/vectors/bold_duotone/home.vec', "
          "accentAssetPath: 'assets/vectors/bold_duotone/home-accent.vec');",
        ),
      );
      // Not in accentIconNames -> single-argument form, no accentAssetPath.
      expect(
        content,
        contains(
          "static const AuraIconData arrowDown = AuraIconData("
          "'assets/vectors/bold_duotone/arrow-down.vec');",
        ),
      );
    });

    test('emits accentBehindMain: true only when the accent was rendered first', () {
      final content = generateIconStyleFile(
        style: IconStyle.boldDuotone,
        sortedIconNames: ['arrow-down', 'home'],
        overrides: const {},
        accentIconNames: {'arrow-down': true, 'home': false},
      );

      expect(
        content,
        contains(
          "static const AuraIconData arrowDown = AuraIconData("
          "'assets/vectors/bold_duotone/arrow-down.vec', "
          "accentAssetPath: 'assets/vectors/bold_duotone/arrow-down-accent.vec', "
          "accentBehindMain: true);",
        ),
      );
      // accentRenderedFirst: false -> no accentBehindMain arg (defaults to
      // false on AuraIconData).
      expect(
        content,
        contains(
          "static const AuraIconData home = AuraIconData("
          "'assets/vectors/bold_duotone/home.vec', "
          "accentAssetPath: 'assets/vectors/bold_duotone/home-accent.vec');",
        ),
      );
    });

    test('emits no accentAssetPath for single-tone styles (empty accentIconNames)', () {
      final content = generateIconStyleFile(
        style: IconStyle.outline,
        sortedIconNames: ['home'],
        overrides: const {},
      );

      expect(content, isNot(contains('accentAssetPath')));
    });
  });
}
