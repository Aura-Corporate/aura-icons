import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'icon_data.dart';

/// Renders an `aura_solar_icons` icon from a precompiled `vector_graphics` asset,
/// with an [Icon]-like API. Used for all 6 styles (Outline, Linear, Bold,
/// Broken, BoldDuotone, LineDuotone) — none of them are font-backed.
///
/// For the duotone styles (BoldDuotone, LineDuotone), the accent region (the
/// lower-opacity sub-shape) is compiled as its own separate asset
/// ([AuraIconData.accentAssetPath]) and rendered as an independent layer, so
/// it can be tinted with [accentColor] instead of always matching [color].
/// When [accentColor] is omitted, it defaults to [color] — identical to the
/// single flat recolor the 4 single-tone styles get, and to this widget's
/// previous single-color-only behavior.
class AuraIcon extends StatelessWidget {
  const AuraIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.accentColor,
    this.semanticLabel,
  });

  final AuraIconData icon;

  /// Defaults to the ambient [IconTheme] size, then 24, mirroring [Icon].
  final double? size;

  /// Defaults to the ambient [IconTheme] color, then black, mirroring [Icon].
  final Color? color;

  /// Color for the duotone accent layer. Ignored when [icon] has no
  /// [AuraIconData.accentAssetPath] (all 4 single-tone styles). Defaults to
  /// [color] (post ambient-theme resolution) when omitted.
  final Color? accentColor;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 24.0;
    final resolvedColor = color ?? iconTheme.color ?? const Color(0xFF000000);

    final mainLayer = VectorGraphic(
      loader: AssetBytesLoader(icon.assetPath, packageName: 'aura_solar_icons'),
      width: resolvedSize,
      height: resolvedSize,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
    );

    final accentAssetPath = icon.accentAssetPath;
    if (accentAssetPath == null) return mainLayer;

    final accentLayer = VectorGraphic(
      loader: AssetBytesLoader(accentAssetPath, packageName: 'aura_solar_icons'),
      width: resolvedSize,
      height: resolvedSize,
      colorFilter: ColorFilter.mode(accentColor ?? resolvedColor, BlendMode.srcIn),
    );

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      // Matches this icon's original upstream paint order (see
      // AuraIconData.accentBehindMain) — painting main on top of accent
      // matters visually as soon as the two colors differ.
      child: Stack(
        children: icon.accentBehindMain ? [accentLayer, mainLayer] : [mainLayer, accentLayer],
      ),
    );
  }
}
