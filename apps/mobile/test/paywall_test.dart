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

  testWidgets('PaywallPage only presents public entitlement information', (
    tester,
  ) async {
    final controller = PaywallController(repository: MemoryPaywallRepository());
    await tester.pumpWidget(
      MaterialApp(home: PaywallPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('套餐与权益'), findsOneWidget);
    expect(find.byKey(const Key('paywall-plan-title')), findsOneWidget);
    expect(find.byKey(const Key('paywall-read-only')), findsOneWidget);
    expect(find.byKey(const Key('paywall-activate-pro')), findsNothing);
    expect(find.byKey(const Key('paywall-activate-free')), findsNothing);
    expect(
      find.byKey(const Key('paywall-feature-feature.server_push')),
      findsNothing,
    );
    expect(find.textContaining('沙箱'), findsNothing);
    expect(find.textContaining('门禁'), findsNothing);
    expect(controller.snapshotState.data?.planCode, 'free');
  });

  testWidgets('PaywallPage exposes loading failure with retry', (tester) async {
    final controller = PaywallController(
      repository: _FailingPaywallRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: PaywallPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('权益加载失败'), findsWidgets);
    expect(find.text('重试'), findsWidgets);
  });
}

class _FailingPaywallRepository implements PaywallRepository {
  @override
  Future<List<PlanCatalogEntry>> listCatalog() async {
    throw const PaywallRepositoryException('权益加载失败');
  }

  @override
  Future<EntitlementSnapshot> current() async {
    throw const PaywallRepositoryException('权益加载失败');
  }

  @override
  Future<EntitlementCheckResult> check({
    String? feature,
    String? metric,
  }) async {
    throw const PaywallRepositoryException('权益加载失败');
  }

  @override
  Future<EntitlementSnapshot> sandboxActivate(String planCode) async {
    throw const PaywallRepositoryException('权益加载失败');
  }
}
