/// Builds the Flutter usage snippet copied to the clipboard when an icon
/// tile is tapped.
String buildIconSnippet({
  required String className,
  required String iconName,
  required String rawHex,
}) {
  final hex = rawHex.trim().replaceFirst('#', '').toUpperCase().padLeft(6, '0');
  return 'AuraIcon(\n  $className.$iconName,\n  size: 24,\n  color: Color(0xFF$hex)\n)';
}
