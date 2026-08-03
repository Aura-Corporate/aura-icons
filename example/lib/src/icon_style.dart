import 'package:aura_solar_icons/aura_solar_icons.dart';

/// Pairs a style's display label and generated class name (needed to build
/// the copy-to-clipboard snippet) with its icon map.
class IconStyle {
  const IconStyle(this.label, this.className, this.icons, {this.hasAccent = false});

  final String label;
  final String className;
  final Map<String, AuraIconData> icons;

  /// Whether this style's icons have a separately-colorable accent layer
  /// (see `AuraIcon.accentColor`) — only true for the 2 duotone styles.
  final bool hasAccent;
}

const kIconStyles = [
  IconStyle('Outline', 'AuraIconsOutline', AuraIconsOutline.all),
  IconStyle('Linear', 'AuraIconsLinear', AuraIconsLinear.all),
  IconStyle('Bold', 'AuraIconsBold', AuraIconsBold.all),
  IconStyle('Broken', 'AuraIconsBroken', AuraIconsBroken.all),
  IconStyle('BoldDuotone', 'AuraIconsBoldDuotone', AuraIconsBoldDuotone.all, hasAccent: true),
  IconStyle('LineDuotone', 'AuraIconsLineDuotone', AuraIconsLineDuotone.all, hasAccent: true),
];
