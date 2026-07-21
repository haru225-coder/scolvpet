import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/public_site/public_site.dart';
import 'support/memory_repositories.dart';

void main() {
  test('MemoryPublicSiteRepository save publish public view', () async {
    final repo = MemoryPublicSiteRepository();
    final saved = await repo.save(
      const PublicSiteDraft(
        slug: 'snow-cattery',
        title: '雪团熊舍',
        tagline: '认真繁育',
        about: '专注金丝熊',
        contactWechat: 'snow_wx',
      ),
    );
    expect(saved.slug, 'snow-cattery');
    expect(saved.published, isFalse);
    final published = await repo.publish();
    expect(published.published, isTrue);
    final view = await repo.getPublicBySlug('snow-cattery');
    expect(view.title, '雪团熊舍');
    expect(view.contactWechat, 'snow_wx');
    expect(view.stats['active_hamsters'], 12);
  });

  testWidgets('PublicSiteEditorPage loads and controller saves', (
    tester,
  ) async {
    final controller = PublicSiteController(
      repository: MemoryPublicSiteRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: PublicSiteEditorPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('公开主页'), findsOneWidget);
    expect(find.byKey(const Key('public-site-title')), findsOneWidget);
    final ok = await controller.save(
      const PublicSiteDraft(slug: 'demo-cattery', title: '演示熊舍'),
    );
    expect(ok, isTrue);
    expect(controller.siteState.data?.title, '演示熊舍');
    expect(controller.siteState.data?.slug, 'demo-cattery');
    await tester.pumpAndSettle();
  });
}
