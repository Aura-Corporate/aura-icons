import 'package:flutter/widgets.dart';
import 'package:vector_graphics/vector_graphics.dart';

import 'icon_data.dart';

/// Renders an `aura_solar_icons` icon from a precompiled `vector_graphics` asset,
/// with an [Icon]-like API. Used for all 6 styles (Outline, Linear, Bold,
/// Broken, BoldDuotone, LineDuotone) — none of them are font-backed.
///
/// For the duotone styles (BoldDuotone, LineDuotone), the accent region is
/// the same hue as the rest of the icon at a lower baked-in opacity (not a
/// second distinct color), so a single [color] parameter is enough: it's
/// applied as a `ColorFilter.mode(color, BlendMode.srcIn)` over the whole
/// rendered picture, which replaces every pixel's RGB while preserving each
/// pixel's alpha, so the pre-baked lighter accent region stays visually
/// lighter than the main shape in whatever color is chosen. For the 4
/// single-tone styles this is just an ordinary flat recolor, identical to
/// how [Icon] tints a font glyph.
class AuraIcon extends StatelessWidget {
  const AuraIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
  });

  final AuraIconData icon;

  /// Defaults to the ambient [IconTheme] size, then 24, mirroring [Icon].
  final double? size;

  /// Defaults to the ambient [IconTheme] color, then black, mirroring [Icon].
  final Color? color;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 24.0;
    final resolvedColor = color ?? iconTheme.color ?? const Color(0xFF000000);

    return VectorGraphic(
      loader: AssetBytesLoader(icon.assetPath, packageName: 'aura_solar_icons'),
      width: resolvedSize,
      height: resolvedSize,
      colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
    );
  }
}
