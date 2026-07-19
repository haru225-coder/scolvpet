import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/ui/widgets/bear_brand.dart';
import 'package:scolvpet_mobile/ui/widgets/bear_motion.dart';

void main() {
  testWidgets('BearFadeIn renders immediately when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: BearFadeIn(delay: Duration(seconds: 2), child: Text('立即显示')),
        ),
      ),
    );

    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    expect(opacity.opacity, 1);
    expect(find.text('立即显示'), findsOneWidget);
  });

  testWidgets('BearPopIn renders immediately when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: BearPopIn(delay: Duration(seconds: 2), child: Text('立即弹出')),
        ),
      ),
    );

    final fade = tester
        .widgetList<FadeTransition>(find.byType(FadeTransition))
        .firstWhere((widget) => widget.opacity.value == 1.0);
    expect(fade.opacity.value, 1);
    expect(find.text('立即弹出'), findsOneWidget);
  });
}
