import 'package:aura_icons/aura_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuraIcon builds and paints with an explicit color/size (duotone style)', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AuraIcon(AuraIconsBoldDuotone.all['home']!, size: 40, color: Colors.deepPurple),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AuraIcon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AuraIcon builds and paints with an explicit color/size (single-tone style)', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AuraIcon(AuraIconsOutline.all['home']!, size: 40, color: Colors.deepPurple),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AuraIcon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AuraIcon falls back to the ambient IconTheme when size/color are omitted', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: IconTheme(
          data: const IconThemeData(size: 30, color: Colors.teal),
          child: AuraIcon(AuraIconsLineDuotone.all['home']!),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AuraIcon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('AuraIconData equality is based on asset path', () {
    const a = AuraIconData('assets/vectors/bold_duotone/home.vec');
    const b = AuraIconData('assets/vectors/bold_duotone/home.vec');
    const c = AuraIconData('assets/vectors/bold_duotone/user.vec');

    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });
}
