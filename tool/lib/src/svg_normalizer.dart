/// Ports the SVG normalization performed by upstream's
/// `packages/core/src/parser.ts` (saoudi-h/solar-icons) so this tool doesn't
/// need a Node/TS toolchain — the regex pipeline is small and self-contained
/// enough to mirror directly. Keep this file's regexes in lockstep with
/// upstream if `upstreamCommitSha` (config.dart) is ever bumped past a
/// parser.ts change; a fixture test (test/svg_normalizer_test.dart) pins
/// expected output for known inputs to catch drift.
library;

final _xmlDeclRegex = RegExp(r'^[\s\S]*?<\?xml[\s\S]*?>\s*');
final _svgOpenRegex = RegExp(r'<svg[^>]*>');
final _svgCloseRegex = RegExp(r'</svg>');
final _emptyRectRegex = RegExp(r'<rect\s+width="24[\d,.]+"\s+height="24[\d,.]+"\s+fill="none"[^>]*/>\s*');
final _titleRegex = RegExp(r'<title[\s\S]*?</title>\s*');
final _defaultStrokeWidthRegex = RegExp(r'\s+stroke-width=["' "'" r']1\.5["' "'" r']');
// Matches any fractional opacity, not just 0.5 — a lone upstream icon
// (BoldDuotone/users/user-block.svg) uses 0.4 for its accent instead.
final _duotoneAccentRegex = RegExp(
  r'(?:<g[^>]*\sopacity="0\.\d+"[^>]*>[\s\S]*?</g>|<\w[^>]*\sopacity="0\.\d+"[^>]*/>)\s*',
);
final _hexColorRegex = RegExp(r'"#[0-9a-f]{6}"', caseSensitive: false);

/// Result of normalizing one raw upstream SVG. Mirrors upstream's
/// `ParsedIcon.inner` / `ParsedIcon.duotoneAccentInner`.
class NormalizedIcon {
  const NormalizedIcon({
    required this.inner,
    required this.duotoneAccentInner,
    this.accentRenderedFirst = false,
  });

  /// The SVG body (no `<svg>` wrapper), main shape(s) only, hex colors
  /// replaced with `currentColor`. For duotone sources, the accent
  /// sub-path(s) have already been extracted out of this into
  /// [duotoneAccentInner].
  final String inner;

  /// The extracted accent sub-path(s) (lower opacity than the main shape),
  /// joined with `\n`, or `null` if the source had none (non-duotone
  /// styles).
  final String? duotoneAccentInner;

  /// Whether the accent sub-path(s) appeared BEFORE the main shape(s) in the
  /// original upstream document — i.e. should be painted first/behind, with
  /// the main shape drawn on top of it. Roughly a 50/50 split upstream (no
  /// universal convention), so this is tracked per icon rather than assumed.
  /// Meaningless when [duotoneAccentInner] is `null`.
  final bool accentRenderedFirst;
}

/// Normalizes a raw upstream SVG file's contents, mirroring
/// `parser.ts`'s `normalizeBody` exactly (order of operations matters).
NormalizedIcon normalizeSvg(String raw) {
  var body = raw
      .replaceFirst(_xmlDeclRegex, '')
      .replaceFirst(_svgOpenRegex, '')
      .replaceAll(_svgCloseRegex, '')
      .replaceAll(_emptyRectRegex, '')
      .replaceAll(_titleRegex, '')
      .replaceAll(_defaultStrokeWidthRegex, '')
      .trim();

  String? duotoneAccentInner;
  var accentRenderedFirst = false;
  final duotoneMatches = _duotoneAccentRegex.allMatches(body).toList();
  if (duotoneMatches.isNotEmpty) {
    // body is already trimmed above, so a match starting at 0 means the
    // accent was the very first element in the document — i.e. painted
    // first/behind, with the main shape(s) drawn on top of it.
    accentRenderedFirst = duotoneMatches.first.start == 0;
    duotoneAccentInner = duotoneMatches.map((m) => m.group(0)!).join('\n').trim();
    body = body.replaceAll(_duotoneAccentRegex, '').trim();
  }

  body = body.replaceAll(_hexColorRegex, '"currentColor"');
  if (duotoneAccentInner != null) {
    duotoneAccentInner = duotoneAccentInner.replaceAll(_hexColorRegex, '"currentColor"');
  }

  return NormalizedIcon(
    inner: body,
    duotoneAccentInner: duotoneAccentInner,
    accentRenderedFirst: accentRenderedFirst,
  );
}

final _malformedNumericRegex = RegExp(r'-?nan|-?infinity|-?inf\b', caseSensitive: false);

/// Detects malformed numeric tokens (`NaN`/`Infinity`) in path/attribute
/// data — a real upstream data-quality issue found in the wild (a specific
/// commit's `Bold/logout.svg` contains a literal `-nan` coordinate, almost
/// certainly from a division-by-zero during Figma's export, unrelated to
/// this pipeline's own normalization). A malformed path would silently
/// compile into corrupted/garbled vector geometry. Icons matching this are
/// excluded from that specific style rather than trusted — see
/// `generate_icons.dart`'s gap-tracking around `normalizedByStyle`.
bool hasMalformedNumericData(NormalizedIcon icon) {
  return _malformedNumericRegex.hasMatch(icon.inner) ||
      (icon.duotoneAccentInner?.contains(_malformedNumericRegex) ?? false);
}

/// Reassembles a normalized icon back into a standalone, self-contained
/// SVG document (`viewBox 0 0 24 24`), ready for the vector_graphics
/// compiler.
///
/// [includeAccent] controls whether the duotone accent sub-path (if any) is
/// re-inlined into the body. `generate_icons.dart` always passes `true` —
/// for the 4 single-tone styles this is a safe no-op, since their
/// `duotoneAccentInner` is always `null` (their source SVGs never carry an
/// `opacity="0.5"` sub-path).
String assembleSvg(NormalizedIcon icon, {bool includeAccent = false}) {
  // fill="none" on the root matches every upstream source SVG (their root
  // <svg> tag always carries it) and is inherited by any descendant <path>
  // that doesn't set its own fill. Outline/Bold/BoldDuotone's paths always
  // declare their own explicit fill, so this is a no-op for them — but
  // Linear/Broken/LineDuotone's paths are stroke-only with no fill
  // attribute, so without this they fall back to the SVG spec default
  // (fill: black), which paints their closed sub-paths (e.g. an arrow
  // head) as solid black shapes on top of the stroke.
  final buffer = StringBuffer()
    ..writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">')
    ..writeln(icon.inner);
  if (includeAccent && icon.duotoneAccentInner != null) {
    buffer.writeln(icon.duotoneAccentInner);
  }
  buffer.writeln('</svg>');
  return buffer.toString();
}

/// Reassembles ONLY the duotone accent sub-path(s) into a standalone SVG
/// document, so it can be compiled as its own independently-colorable
/// `vector_graphics` asset (see `AuraIconData.accentAssetPath`). Returns
/// `null` when the icon has no accent sub-path (always the case for the 4
/// single-tone styles, and possibly true for a duotone icon whose source
/// has no reduced-opacity region).
String? assembleAccentSvg(NormalizedIcon icon) {
  final accent = icon.duotoneAccentInner;
  if (accent == null) return null;

  final buffer = StringBuffer()
    ..writeln('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none">')
    ..writeln(accent)
    ..writeln('</svg>');
  return buffer.toString();
}
