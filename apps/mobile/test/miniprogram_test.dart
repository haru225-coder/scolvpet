import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/miniprogram/miniprogram.dart';

void main() {
  test('MemoryMiniprogramRepository full audit publish path', () async {
    final repo = MemoryMiniprogramRepository();
    await repo.saveConfig(
      const MiniprogramConfigDraft(
        displayName: '雪团小程序',
        boundPublicSlug: 'snow-cattery',
      ),
    );
    final draft = await repo.createRelease(
      const MiniprogramReleaseDraft(
        versionLabel: 'v1',
        title: '首发',
      ),
    );
    expect(draft.status, 'draft');
    final submitted = await repo.submit(draft.id);
    expect(submitted.status, 'submitted');
    final approved = await repo.audit(draft.id, approve: true);
    expect(approved.status, 'approved');
    final published = await repo.publish(draft.id);
    expect(published.status, 'published');
    final rolled = await repo.rollback(draft.id);
    expect(rolled.status, 'rolled_back');
  });

  testWidgets('MiniprogramHubPage creates release draft', (tester) async {
    final controller = MiniprogramController(
      repository: MemoryMiniprogramRepository(),
    );
    await tester.pumpWidget(
      MaterialApp(home: MiniprogramHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('小程序轻发布'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mp-fab-create')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('mp-release-label')), 'v9');
    await tester.enterText(find.byKey(const Key('mp-release-title')), '测试版');
    await tester.tap(find.byKey(const Key('mp-release-submit')));
    await tester.pumpAndSettle();
    expect(controller.releasesState.hasValue, isTrue);
    expect(controller.releasesState.data!.single.versionLabel, 'v9');
  });
}
