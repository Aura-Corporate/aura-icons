import 'package:aura_icons/aura_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders an icon (Outline) without error', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AuraIcon(AuraIconsOutline.arrowDown, size: 48),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuraIcon), findsOneWidget);
  });

  testWidgets('renders an icon (Bold) without error', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AuraIcon(AuraIconsBold.arrowDown, size: 48),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuraIcon), findsOneWidget);
  });

  testWidgets('renders a duotone icon (BoldDuotone) without error', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AuraIcon(AuraIconsBoldDuotone.arrowDown, size: 48, color: Colors.blue),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuraIcon), findsOneWidget);
  });

  testWidgets('renders a duotone icon (LineDuotone) without error', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AuraIcon(AuraIconsLineDuotone.arrowDown, size: 48, color: Colors.blue),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AuraIcon), findsOneWidget);
  });
}
