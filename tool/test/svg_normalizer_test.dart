import 'dart:io';

import 'package:aura_solar_icons_tool/src/svg_normalizer.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

String _fixture(String name) {
  final path = p.join(Directory.current.path, 'test', 'fixtures', name);
  return File(path).readAsStringSync();
}

void main() {
  group('normalizeSvg', () {
    test('fill-based Outline icon: strips wrapper, hex -> currentColor, no accent', () {
      final result = normalizeSvg(_fixture('outline_arrow_down.svg'));

      expect(result.duotoneAccentInner, isNull);
      expect(result.inner, contains('fill-rule="evenodd"'));
      expect(result.inner, contains('fill="currentColor"'));
      expect(result.inner, isNot(contains('#1C274C')));
      expect(result.inner, isNot(contains('<svg')));
      expect(result.inner, isNot(contains('</svg>')));
    });

    test('stroke-based Linear icon: strips default stroke-width, hex -> currentColor', () {
      final result = normalizeSvg(_fixture('linear_arrow_down.svg'));

      expect(result.duotoneAccentInner, isNull);
      expect(result.inner, contains('stroke="currentColor"'));
      expect(result.inner, isNot(contains('stroke-width')));
      expect(result.inner, contains('stroke-linecap="round"'));
    });

    test('BoldDuotone icon: extracts the opacity=0.5 accent out of the main body', () {
      final result = normalizeSvg(_fixture('bold_duotone_arrow_down.svg'));

      expect(result.duotoneAccentInner, isNotNull);
      expect(result.duotoneAccentInner, contains('opacity="0.5"'));
      expect(result.duotoneAccentInner, contains('fill="currentColor"'));

      // The accent path must be removed from the main body — only the
      // solid (non-accent) path remains there.
      expect(result.inner, isNot(contains('opacity="0.5"')));
      expect(result.inner, contains('M6.00002 13.25'));
      expect(result.duotoneAccentInner, contains('M12 3.25'));
    });
  });

  group('assembleSvg', () {
    test('wraps inner back into a standalone viewBox 0 0 24 24 svg', () {
      final normalized = normalizeSvg(_fixture('outline_arrow_down.svg'));
      final assembled = assembleSvg(normalized);

      expect(assembled, contains('viewBox="0 0 24 24"'));
      expect(assembled, contains('<path'));
      expect(assembled.trim(), startsWith('<svg'));
      expect(assembled.trim(), endsWith('</svg>'));
    });

    test('root carries fill="none" so stroke-only paths without their own '
        'fill don\'t fall back to the SVG-spec default (black)', () {
      final normalized = normalizeSvg(_fixture('linear_arrow_down.svg'));
      final assembled = assembleSvg(normalized);

      expect(assembled, contains('fill="none"'));
      // The root's fill="none" must appear before the path so it's actually
      // inherited by it, not just present somewhere in the string.
      expect(assembled.indexOf('fill="none"'), lessThan(assembled.indexOf('<path')));
    });

    test('includeAccent=true re-inlines the duotone accent', () {
      final normalized = normalizeSvg(_fixture('bold_duotone_arrow_down.svg'));

      final withoutAccent = assembleSvg(normalized);
      expect(withoutAccent, isNot(contains('opacity="0.5"')));

      final withAccent = assembleSvg(normalized, includeAccent: true);
      expect(withAccent, contains('opacity="0.5"'));
    });
  });
}
