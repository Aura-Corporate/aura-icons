/// A reference to a precompiled vector icon asset — analogous to Flutter's
/// [IconData], but backed by a `vector_graphics` `.vec` asset instead of a
/// font glyph. Every `aura_icons` style (Outline, Linear, Bold, Broken,
/// BoldDuotone, LineDuotone) uses this same type; there is no font-backed
/// alternative.
///
/// Hand-written, never regenerated. The generated `AuraIconsXxx` classes
/// reference this type; only the `static const` instances themselves are
/// generated.
class AuraIconData {
  const AuraIconData(this.assetPath);

  /// Bare (no `packages/aura_icons/` prefix) asset path, e.g.
  /// `assets/vectors/outline/home.vec`. [AuraIcon] supplies
  /// `packageName: 'aura_icons'` to `AssetBytesLoader`, which adds that
  /// prefix itself — baking it into both places double-prefixes the path.
  final String assetPath;

  @override
  bool operator ==(Object other) => other is AuraIconData && other.assetPath == assetPath;

  @override
  int get hashCode => assetPath.hashCode;

  @override
  String toString() => 'AuraIconData($assetPath)';
}
