import 'dart:io';
import 'dart:typed_data';

import 'package:aura_solar_icons_tool/src/svg_normalizer.dart';
import 'package:aura_solar_icons_tool/src/vector_compiler.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// vector_graphics_codec's binary format always starts with this magic
// number (see VectorGraphicsCodec._magicNumber), written little-endian.
const _expectedMagic = <int>[0x62, 0x2d, 0x88, 0x00];

void main() {
  group('VectorCompiler', () {
    late Directory tmpDir;

    setUp(() async {
      tmpDir = await Directory.systemTemp.createTemp('aura_solar_icons_vector_compiler_test_');
    });

    tearDown(() async {
      if (tmpDir.existsSync()) await tmpDir.delete(recursive: true);
    });

    test('compiles a fill-based duotone SVG (BoldDuotone) to a valid .vec', () async {
      final raw = File(p.join(Directory.current.path, 'test', 'fixtures', 'bold_duotone_arrow_down.svg'))
          .readAsStringSync();
      final normalized = normalizeSvg(raw);
      final svg = assembleSvg(normalized, includeAccent: true);

      final output = File(p.join(tmpDir.path, 'arrow-down.vec'));
      await VectorCompiler().compileAll([
        VectorCompileJob(iconName: 'arrow-down', svg: svg, output: output),
      ]);

      expect(output.existsSync(), isTrue);
      final bytes = await output.readAsBytes();
      expect(bytes.length, greaterThan(20));
      expect(bytes.sublist(0, 4), equals(Uint8List.fromList(_expectedMagic)));
    });

    test('compiles a stroke-based duotone SVG (LineDuotone) to a valid .vec without conversion', () async {
      // LineDuotone is stroke-based but, unlike Linear/Broken, is shipped
      // straight to vector_graphics (which renders strokes natively) with
      // no stroke-to-fill step — this test locks in that it compiles fine
      // as-is.
      const strokeDuotoneSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<path d="M18 14L12 20L6 14" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
<path opacity="0.5" d="M12 4L12 20" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
      final output = File(p.join(tmpDir.path, 'arrow-down-line-duotone.vec'));
      await VectorCompiler().compileAll([
        VectorCompileJob(iconName: 'arrow-down', svg: strokeDuotoneSvg, output: output),
      ]);

      expect(output.existsSync(), isTrue);
      final bytes = await output.readAsBytes();
      expect(bytes.sublist(0, 4), equals(Uint8List.fromList(_expectedMagic)));
    });
  });
}
