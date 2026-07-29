import 'package:aura_icons_tool/src/svg_normalizer.dart';
import 'package:test/test.dart';

void main() {
  group('hasMalformedNumericData', () {
    test('detects a literal -nan coordinate (real upstream Bold/logout.svg case)', () {
      final icon = normalizeSvg('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M4 12L10 14.25L-nan -nanL10 14.25Z" fill="#1C274C"/>
</svg>
''');
      expect(hasMalformedNumericData(icon), isTrue);
    });

    test('detects Infinity too', () {
      final icon = normalizeSvg('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M4 12L10 Infinity" fill="#1C274C"/>
</svg>
''');
      expect(hasMalformedNumericData(icon), isTrue);
    });

    test('a clean icon is not flagged', () {
      final icon = normalizeSvg('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M12 3.25C12.4142 3.25 12.75 3.58579 12.75 4Z" fill="#1C274C"/>
</svg>
''');
      expect(hasMalformedNumericData(icon), isFalse);
    });

    test('checks the duotone accent too, not just the main body', () {
      final icon = normalizeSvg('''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path opacity="0.5" d="M4 12L-nan 14" fill="#1C274C"/>
<path d="M12 3.25C12.4142 3.25 12.75 3.58579 12.75 4Z" fill="#1C274C"/>
</svg>
''');
      expect(icon.duotoneAccentInner, isNotNull);
      expect(hasMalformedNumericData(icon), isTrue);
    });
  });
}
