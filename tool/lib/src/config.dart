/// Central configuration for the aura_solar_icons codegen pipeline.
///
/// Bumping [upstreamCommitSha] and re-running `dart run generate_icons.dart`
/// is the only thing needed to pull in new/fixed upstream icons.
library;

/// GitHub owner/repo of the upstream icon source.
const upstreamOwner = 'saoudi-h';
const upstreamRepo = 'solar-icons';

/// Pinned commit SHA. Bump this to refresh from upstream. Update the same
/// value in THIRD_PARTY_NOTICES.md when changing it.
const upstreamCommitSha = '750ab81d2c31164463d168bdfd52e8a7632deeaf';

/// Path inside the upstream repo tarball that holds the raw SVG source.
const upstreamSvgsPath = 'packages/core/svgs';

/// One entry per icon style. `folder` is the on-disk PascalCase directory
/// name under `<category>/<folder>/<icon-name>.svg` in the upstream repo.
/// Every style follows the identical pipeline path (normalize -> assemble
/// with the duotone accent re-inlined, which is a no-op for the 4
/// single-tone styles -> compile to a `vector_graphics` `.vec` asset ->
/// codegen) — there is no longer a font/vector distinction to track.
enum IconStyle {
  outline(
    folder: 'Outline',
    dartClassName: 'AuraIconsOutline',
    fileBaseName: 'aura_solar_icons_outline',
    assetSubdir: 'outline',
  ),
  linear(
    folder: 'Linear',
    dartClassName: 'AuraIconsLinear',
    fileBaseName: 'aura_solar_icons_linear',
    assetSubdir: 'linear',
  ),
  bold(
    folder: 'Bold',
    dartClassName: 'AuraIconsBold',
    fileBaseName: 'aura_solar_icons_bold',
    assetSubdir: 'bold',
  ),
  broken(
    folder: 'Broken',
    dartClassName: 'AuraIconsBroken',
    fileBaseName: 'aura_solar_icons_broken',
    assetSubdir: 'broken',
  ),
  boldDuotone(
    folder: 'BoldDuotone',
    dartClassName: 'AuraIconsBoldDuotone',
    fileBaseName: 'aura_solar_icons_bold_duotone',
    assetSubdir: 'bold_duotone',
  ),
  lineDuotone(
    folder: 'LineDuotone',
    dartClassName: 'AuraIconsLineDuotone',
    fileBaseName: 'aura_solar_icons_line_duotone',
    assetSubdir: 'line_duotone',
  );

  const IconStyle({
    required this.folder,
    required this.dartClassName,
    required this.fileBaseName,
    required this.assetSubdir,
  });

  /// On-disk PascalCase folder name in the upstream `svgs/` tree.
  final String folder;

  /// Generated Dart class name, e.g. `AuraIconsOutline`.
  final String dartClassName;

  /// Generated file basename under `lib/src/generated/`, e.g.
  /// `aura_solar_icons_outline` (becomes `aura_solar_icons_outline.g.dart`).
  final String fileBaseName;

  /// Subdirectory under `assets/vectors/` holding this style's `.vec` files.
  final String assetSubdir;
}
