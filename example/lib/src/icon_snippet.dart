/// Builds the Flutter usage snippet copied to the clipboard when an icon
/// tile is tapped. [rawAccentHex] is only meaningful (non-null) when the
/// current style has a separately-colorable accent layer.
String buildIconSnippet({
  required String className,
  required String iconName,
  required String rawHex,
  String? rawAccentHex,
}) {
  final hex = _normalizeHex(rawHex);
  final accentArg = rawAccentHex == null ? '' : ',\n  accentColor: Color(0xFF${_normalizeHex(rawAccentHex)})';
  return 'AuraIcon(\n  $className.$iconName,\n  size: 24,\n  color: Color(0xFF$hex)$accentArg,\n)';
}

String _normalizeHex(String rawHex) =>
    rawHex.trim().replaceFirst('#', '').toUpperCase().padLeft(6, '0');
