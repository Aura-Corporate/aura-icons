/// Single entrypoint for the aura_solar_icons codegen pipeline.
///
/// Usage:
///   dart run generate_icons.dart                  # full run, all categories
///   dart run generate_icons.dart --only-category=arrows   # subset, for
///                                                          # pipeline validation
///
/// See README.md at the package root ("Regenerating") and tool/README.md
/// for prerequisites (just Dart — no Node, no Inkscape; every style is a
/// precompiled `vector_graphics` asset).
library;

import 'dart:io';

import 'package:aura_solar_icons_tool/src/codegen_dart.dart';
import 'package:aura_solar_icons_tool/src/config.dart';
import 'package:aura_solar_icons_tool/src/fetch_upstream.dart';
import 'package:aura_solar_icons_tool/src/svg_normalizer.dart';
import 'package:aura_solar_icons_tool/src/vector_compiler.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final _toolRoot = Directory.current;
final _packageRoot = Directory(p.normalize(p.join(_toolRoot.path, '..')));

Future<void> main(List<String> args) async {
  final onlyCategory = _parseOnlyCategoryArg(args);

  final cacheRoot = Directory(p.join(_toolRoot.path, '.cache'));

  stderr.writeln('== 1/4 Fetching upstream SVGs (${upstreamCommitSha.substring(0, 12)}) ==');
  final svgsDir = await fetchUpstreamSvgs(cacheRoot: cacheRoot);
  var categories = await listCategories(svgsDir);
  if (onlyCategory != null) {
    categories = categories.where((c) => c == onlyCategory).toList();
    if (categories.isEmpty) {
      throw StateError('--only-category=$onlyCategory matched no category in ${svgsDir.path}');
    }
    stderr.writeln('   (restricted to category "$onlyCategory" for validation)');
  }
  stderr.writeln('   ${categories.length} categories');

  stderr.writeln('== 2/4 Normalizing per style ==');
  // iconName -> NormalizedIcon, per style.
  final normalizedByStyle = <IconStyle, Map<String, NormalizedIcon>>{
    for (final style in IconStyle.values) style: {},
  };

  // (style, iconName) pairs excluded due to malformed upstream source data
  // (NaN/Infinity coordinates) — see hasMalformedNumericData. Real-world
  // example found at the pinned commit: Bold/logout.svg contains a literal
  // `-nan` coordinate (a Figma-export artifact), which would corrupt the
  // compiled vector geometry.
  final gaps = <(IconStyle, String)>[];

  for (final category in categories) {
    for (final style in IconStyle.values) {
      final styleDir = Directory(p.join(svgsDir.path, category, style.folder));
      if (!styleDir.existsSync()) continue;
      await for (final entry in styleDir.list()) {
        if (entry is! File || !entry.path.endsWith('.svg')) continue;
        final iconName = p.basenameWithoutExtension(entry.path);
        final raw = await entry.readAsString();
        final normalized = normalizeSvg(raw);
        if (hasMalformedNumericData(normalized)) {
          gaps.add((style, iconName));
          stderr.writeln(
            '   WARNING: excluding "$iconName" from ${style.name} — malformed '
            'NaN/Infinity coordinate in upstream source SVG.',
          );
          continue;
        }
        normalizedByStyle[style]![iconName] = normalized;
      }
    }
  }
  for (final style in IconStyle.values) {
    stderr.writeln('   ${style.name}: ${normalizedByStyle[style]!.length} icons');
  }

  // Integrity check: every icon must exist in all 6 styles, EXCEPT for
  // explicitly-tracked gaps from malformed source data above (mirrors
  // upstream parser.ts's own assertIntegrity, relaxed to tolerate known,
  // logged exceptions rather than silently accepting — or blindly
  // rejecting — any discrepancy).
  final referenceNames = IconStyle.values
      .expand((s) => normalizedByStyle[s]!.keys)
      .toSet();
  for (final style in IconStyle.values) {
    final names = normalizedByStyle[style]!.keys.toSet();
    final missing = referenceNames.difference(names);
    final expectedGaps = gaps.where((g) => g.$1 == style).map((g) => g.$2).toSet();
    final unexplained = missing.difference(expectedGaps);
    final extra = names.difference(referenceNames);
    if (unexplained.isNotEmpty || extra.isNotEmpty) {
      throw StateError(
        'Integrity check failed for ${style.name}: '
        '${unexplained.isNotEmpty ? 'unexplained gaps $unexplained ' : ''}'
        '${extra.isNotEmpty ? 'extra $extra' : ''}',
      );
    }
  }
  if (gaps.isNotEmpty) {
    stderr.writeln(
      '   ${gaps.length} icon(s) excluded from a specific style due to malformed source data '
      '(see warnings above) — these will simply be absent from that style\'s generated class.',
    );
  }

  stderr.writeln('== 3/4 Compiling vector assets (all 6 styles) ==');
  final vectorCompiler = VectorCompiler();
  for (final style in IconStyle.values) {
    final outDir = Directory(p.join(_packageRoot.path, 'assets', 'vectors', style.assetSubdir));
    if (onlyCategory == null && outDir.existsSync()) {
      await outDir.delete(recursive: true);
    }
    final jobs = normalizedByStyle[style]!.entries.map((entry) {
      // includeAccent is a no-op for the 4 single-tone styles — their
      // duotoneAccentInner is always null (see svg_normalizer.dart).
      final svg = assembleSvg(entry.value, includeAccent: true);
      return VectorCompileJob(
        iconName: entry.key,
        svg: svg,
        output: File(p.join(outDir.path, '${entry.key}.vec')),
      );
    }).toList();
    await vectorCompiler.compileAll(jobs);
    stderr.writeln('   ${style.name}: ${jobs.length} assets -> ${outDir.path}');
  }

  stderr.writeln('== 4/4 Generating Dart bindings ==');
  final overrides = await _loadOverrides();
  final generatedDir = Directory(p.join(_packageRoot.path, 'lib', 'src', 'generated'));
  await generatedDir.create(recursive: true);

  for (final style in IconStyle.values) {
    final names = normalizedByStyle[style]!.keys.toList()..sort();
    final content = generateIconStyleFile(
      style: style,
      sortedIconNames: names,
      overrides: overrides,
    );
    await File(p.join(generatedDir.path, '${style.fileBaseName}.g.dart')).writeAsString(content);
  }
  await File(p.join(generatedDir.path, 'known_gaps.g.dart'))
      .writeAsString(generateKnownGapsFile(gaps));

  stderr.writeln('Done.');
}

String? _parseOnlyCategoryArg(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--only-category=')) {
      return arg.substring('--only-category='.length);
    }
  }
  return null;
}

Future<Map<String, String>> _loadOverrides() async {
  final file = File(p.join(_toolRoot.path, 'config', 'icon_name_overrides.yaml'));
  if (!await file.exists()) return {};
  final doc = loadYaml(await file.readAsString());
  if (doc == null) return {};
  final map = doc as YamlMap;
  return map.map((k, v) => MapEntry(k.toString(), v.toString()));
}
