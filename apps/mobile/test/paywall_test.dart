import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/paywall/paywall.dart';

void main() {
  test('MemoryPaywallRepository sandbox upgrade', () async {
    final repo = MemoryPaywallRepository(
      usage: {'active_hamsters': 50, 'enclosures': 5},
    );
    final free = await repo.current();
    expect(free.planCode, 'free');
    expect(free.overLimit, isTrue);
    final pro = await repo.sandboxActivate('pro');
    expect(pro.planCode, 'pro');
    expect(pro.isPro, isTrue);
    final check = await repo.check(feature: 'feature.advanced_export');
    expect(check.allowed, isTrue);
  });

  testWidgets('PaywallPage activates pro in sandbox', (tester) async {
    final controller = PaywallController(
      repository: MemoryPaywallRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: PaywallPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('套餐与权益'), findsOneWidget);
    expect(find.byKey(const Key('paywall-plan-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('paywall-activate-pro')));
    await tester.pumpAndSettle();
    expect(controller.snapshotState.data?.isPro, isTrue);
    expect(find.textContaining('专业版'), findsWidgets);
  });
}
