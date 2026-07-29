import 'package:collection/collection.dart';

import 'config.dart';
import 'name_utils.dart';

/// Thrown when two different kebab-case icon names resolve to the same
/// Dart identifier within one style — this should never happen given the
/// current icon set (no two source names collide after camelCasing), but a
/// hard error here is much safer than silently dropping one of them.
class DuplicateIdentifierException implements Exception {
  DuplicateIdentifierException(this.identifier, this.kebabNames);
  final String identifier;
  final List<String> kebabNames;

  @override
  String toString() =>
      'DuplicateIdentifierException: "$identifier" is produced by multiple '
      'icon names: ${kebabNames.join(', ')}. Add disambiguating entries to '
      'tool/config/icon_name_overrides.yaml.';
}

/// Resolves every kebab-case [iconNames] to its Dart identifier, applying
/// [overrides] and detecting collisions. Returns a map preserving the input
/// order (callers should pass [iconNames] pre-sorted alphabetically so the
/// generated class's field order is stable/diffable).
Map<String, String> resolveAllIdentifiers(
  List<String> iconNames,
  Map<String, String> overrides,
) {
  final result = <String, String>{};
  final byIdentifier = <String, List<String>>{};

  for (final kebabName in iconNames) {
    final identifier = resolveDartIdentifier(kebabName, overrides);
    result[kebabName] = identifier;
    byIdentifier.putIfAbsent(identifier, () => []).add(kebabName);
  }

  for (final entry in byIdentifier.entries) {
    if (entry.value.length > 1) {
      throw DuplicateIdentifierException(entry.key, entry.value);
    }
  }

  return result;
}

const _fileHeader = '''
// GENERATED FILE — DO NOT EDIT BY HAND.
//
// Source: saoudi-h/solar-icons @ $upstreamCommitSha
// Regenerate: `cd tool && dart pub get && dart run generate_icons.dart`
//
// ignore_for_file: type=lint
''';

/// Generates the Dart source for one icon style: a class of
/// `static const AuraIconData` fields referencing the style's compiled
/// `.vec` asset, plus an `all` map for enumeration (tests, example app).
/// The single codegen path for all 6 styles — none of them are font-backed
/// anymore, so there's nothing style-specific left to branch on here.
String generateIconStyleFile({
  required IconStyle style,
  required List<String> sortedIconNames,
  required Map<String, String> overrides,
}) {
  final identifiers = resolveAllIdentifiers(sortedIconNames, overrides);
  final sortedByIdentifier = sortedIconNames.sortedBy((n) => identifiers[n]!);

  final buffer = StringBuffer(_fileHeader)
    ..writeln()
    ..writeln("import '../icon/icon_data.dart';")
    ..writeln()
    ..writeln('class ${style.dartClassName} {')
    ..writeln('  ${style.dartClassName}._();')
    ..writeln();

  for (final kebabName in sortedByIdentifier) {
    final identifier = identifiers[kebabName]!;
    // Bare path (no "packages/aura_icons/" prefix) — AuraIcon supplies
    // `packageName: 'aura_icons'` to AssetBytesLoader itself, which adds
    // that prefix internally. Baking the prefix into both places at once
    // double-prefixes the path and the asset silently fails to load.
    final assetPath = 'assets/vectors/${style.assetSubdir}/$kebabName.vec';
    buffer.writeln(
      "  static const AuraIconData $identifier = AuraIconData('$assetPath');",
    );
  }

  buffer
    ..writeln()
    ..writeln('  /// Dart-identifier -> icon data, for enumeration (tests, example app).')
    ..writeln('  static const Map<String, AuraIconData> all = {');
  for (final kebabName in sortedByIdentifier) {
    final identifier = identifiers[kebabName]!;
    buffer.writeln("    '$identifier': $identifier,");
  }
  buffer
    ..writeln('  };')
    ..writeln('}');

  return buffer.toString();
}

/// Generates `known_gaps.g.dart`: a small, explicit record of (style, icon)
/// pairs deliberately excluded from a style due to malformed upstream
/// source data (see `svg_normalizer.dart`'s `hasMalformedNumericData`).
///
/// Exists so `test/icon_completeness_test.dart` can assert "every icon in
/// every style, except these documented, explained exceptions" instead of
/// either a brittle hardcoded count or silently ignoring the gap.
String generateKnownGapsFile(List<(IconStyle style, String iconName)> gaps) {
  final sorted = [...gaps]..sort((a, b) {
      final styleCompare = a.$1.name.compareTo(b.$1.name);
      return styleCompare != 0 ? styleCompare : a.$2.compareTo(b.$2);
    });

  final buffer = StringBuffer(_fileHeader)
    ..writeln()
    ..writeln('/// (style class name, kebab-case icon name) excluded from that')
    ..writeln('/// style due to malformed upstream source data.')
    ..writeln('const List<(String, String)> knownGaps = [');
  for (final gap in sorted) {
    buffer.writeln("  ('${gap.$1.dartClassName}', '${gap.$2}'),");
  }
  buffer.writeln('];');

  return buffer.toString();
}
