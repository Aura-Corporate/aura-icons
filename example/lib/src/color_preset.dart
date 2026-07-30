import 'package:flutter/material.dart';

/// A preset swatch: its hex string alongside the matching [Color], so
/// selecting one can fill the hex field without ever deriving a hex string
/// back out of a [Color].
typedef ColorPreset = ({String hex, Color color});

/// Mirrors the palette from aura-mobile's `AppColors`
/// (lib/core/theme/app_colors.dart) so the example previews icons in the
/// colors they'll actually be used with.
const List<ColorPreset> kColorPresets = [
  (hex: '111827', color: Color(0xFF111827)), // textPrimary
  (hex: '374151', color: Color(0xFF374151)), // iconDefault
  (hex: 'DB6B48', color: Color(0xFFDB6B48)), // primary
  (hex: '719897', color: Color(0xFF719897)), // secondary
  (hex: '10B981', color: Color(0xFF10B981)), // success
  (hex: 'F59E0B', color: Color(0xFFF59E0B)), // warning
  (hex: 'EF4444', color: Color(0xFFEF4444)), // error
];
