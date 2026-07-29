/// Ports `toCamelCase`/`toPascalCase` from upstream's
/// `packages/core/src/utils.ts` (saoudi-h/solar-icons), plus Dart-specific
/// identifier safety that upstream's TypeScript doesn't need to worry about
/// (Dart identifiers can't start with a digit and can't shadow a reserved
/// word; TS component names have different constraints).
///
/// Note: upstream's `fixIconName`/`ICON_RENAMES` (typo corrections) are
/// deliberately NOT ported — `parser.ts` itself no longer applies them as of
/// the pinned commit (typo fixes already landed in the on-disk filenames,
/// see upstream issue #493), so the `svgs/` filenames are already canonical.
library;

final _leadingTrailingSeparators = RegExp(r'^[\s\-_]+|[\s\-_]+$');
final _camelizeBoundary = RegExp(r'^([A-Z])|[\s\-_]+(\w)');

/// Port of upstream `toCamelCase`. For our kebab-case source filenames this
/// reduces to: trim stray separators, lowercase the first segment, and
/// capitalize the first letter of every subsequent dash-separated segment.
String kebabToLowerCamel(String input) {
  final trimmed = input.replaceAll(_leadingTrailingSeparators, '');
  return trimmed.replaceAllMapped(_camelizeBoundary, (m) {
    final boundaryChar = m.group(2);
    if (boundaryChar != null) return boundaryChar.toUpperCase();
    return m.group(1)!.toLowerCase();
  });
}

/// Port of upstream `toPascalCase`.
String kebabToPascalCase(String input) {
  final camel = kebabToLowerCamel(input);
  if (camel.isEmpty) return camel;
  return camel[0].toUpperCase() + camel.substring(1);
}

/// Dart keywords that would either fail to parse or silently shadow a
/// language construct if used as a `static const` field name. Sourced from
/// the Dart language spec's reserved-word list (built-in identifiers like
/// `abstract` are technically usable as field names, but are excluded here
/// too since they're a footgun as icon names — none of the 1246 icon names
/// currently collide with those anyway).
const _dartReservedWords = {
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
  'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
  'in', 'is', 'new', 'null', 'rethrow', 'return', 'super', 'switch', 'this',
  'throw', 'true', 'try', 'var', 'void', 'while', 'with',
  // Not reserved words technically, but reserved *identifiers* per the Dart
  // spec (can't be used as a class/field identifier where a type is
  // expected) — excluded defensively.
  'dynamic',
  // Built-in identifiers: technically legal as a plain field name in Dart,
  // but confusing enough (shadowing a directive/declaration keyword) that
  // we treat them as unsafe too — matches upstream's own awareness of this
  // exact class of naming collision (icon names `export`, `import`, and
  // `case` all exist in the set; see upstream issue #494).
  'export', 'import', 'library', 'part', 'show', 'hide', 'deferred', 'as',
  'get', 'set', 'external', 'factory', 'operator', 'typedef', 'static',
};

final _validDartIdentifier = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');

/// Thrown when an icon name can't be turned into a safe Dart identifier
/// automatically and has no entry in `tool/config/icon_name_overrides.yaml`.
class UnsafeIconNameException implements Exception {
  UnsafeIconNameException(this.kebabName, this.candidate);
  final String kebabName;
  final String candidate;

  @override
  String toString() =>
      'UnsafeIconNameException: icon "$kebabName" produced Dart identifier '
      '"$candidate" which is invalid or reserved. Add an explicit mapping in '
      'tool/config/icon_name_overrides.yaml.';
}

/// Resolves the final Dart identifier for an icon, given its kebab-case
/// source name and any manual [overrides] (kebab-name -> desired
/// lowerCamelCase identifier) loaded from
/// `tool/config/icon_name_overrides.yaml`.
///
/// Resolution order:
/// 1. An explicit override always wins.
/// 2. Otherwise, camelCase the name; if that collides with a Dart reserved
///    word or starts with a digit, fall back to appending `Icon` (mirrors
///    the same fix upstream is independently discussing for its own naming
///    collisions — see upstream issue #494).
/// 3. If the result is still not a valid Dart identifier, throw
///    [UnsafeIconNameException] rather than silently mangling the name —
///    a human must add an override.
String resolveDartIdentifier(String kebabName, Map<String, String> overrides) {
  final override = overrides[kebabName];
  if (override != null) return override;

  var candidate = kebabToLowerCamel(kebabName);

  final startsWithDigit = candidate.isNotEmpty && RegExp(r'^[0-9]').hasMatch(candidate);
  if (_dartReservedWords.contains(candidate) || startsWithDigit) {
    candidate = startsWithDigit ? 'n$candidate' : '${candidate}Icon';
  }

  if (!_validDartIdentifier.hasMatch(candidate) || _dartReservedWords.contains(candidate)) {
    throw UnsafeIconNameException(kebabName, candidate);
  }

  return candidate;
}
