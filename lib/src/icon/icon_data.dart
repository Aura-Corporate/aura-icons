/// A reference to a precompiled vector icon asset — analogous to Flutter's
/// [IconData], but backed by a `vector_graphics` `.vec` asset instead of a
/// font glyph. Every `aura_solar_icons` style (Outline, Linear, Bold, Broken,
/// BoldDuotone, LineDuotone) uses this same type; there is no font-backed
/// alternative.
///
/// Hand-written, never regenerated. The generated `AuraIconsXxx` classes
/// reference this type; only the `static const` instances themselves are
/// generated.
class AuraIconData {
  const AuraIconData(this.assetPath, {this.accentAssetPath, this.accentBehindMain = false});

  /// Bare (no `packages/aura_solar_icons/` prefix) asset path, e.g.
  /// `assets/vectors/outline/home.vec`. [AuraIcon] supplies
  /// `packageName: 'aura_solar_icons'` to `AssetBytesLoader`, which adds that
  /// prefix itself — baking it into both places double-prefixes the path.
  final String assetPath;

  /// Bare asset path to this icon's separately-compiled duotone accent
  /// layer (the lower-opacity sub-shape), e.g.
  /// `assets/vectors/bold_duotone/home-accent.vec`. `null` for the 4
  /// single-tone styles, and for any duotone icon whose source has no
  /// accent sub-path. [AuraIcon] renders it as an independently-colorable
  /// second layer via its `accentColor` parameter.
  final String? accentAssetPath;

  /// Whether the accent layer should be painted BEHIND the main layer
  /// (`true`) or in FRONT of it (`false`, the default). Mirrors the
  /// original upstream SVG's paint order for this icon, which isn't
  /// consistent across icons — some have the accent shape drawn first
  /// (behind), others last (in front) — so this is tracked per icon rather
  /// than assumed. Meaningless when [accentAssetPath] is `null`.
  final bool accentBehindMain;

  // Equality/hashCode are keyed on assetPath only: accentAssetPath and
  // accentBehindMain are both derived 1-to-1 from it, not independent
  // pieces of identity.
  @override
  bool operator ==(Object other) => other is AuraIconData && other.assetPath == assetPath;

  @override
  int get hashCode => assetPath.hashCode;

  @override
  String toString() => 'AuraIconData($assetPath)';
}
