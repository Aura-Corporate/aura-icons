import 'package:flutter/material.dart';

/// Parses a 6- or 8-digit hex string (optionally prefixed with `#`) into an
/// opaque (6-digit) or explicit-alpha (8-digit) [Color]. Returns null when
/// the input isn't a valid hex color.
Color? tryParseHexColor(String input) {
  final cleaned = input.trim().replaceFirst('#', '');
  if (cleaned.length != 6 && cleaned.length != 8) return null;

  final parsed = int.tryParse(cleaned, radix: 16);
  if (parsed == null) return null;

  return Color(cleaned.length == 6 ? 0xFF000000 | parsed : parsed);
}
