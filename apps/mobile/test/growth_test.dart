import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/growth/growth.dart';
import 'package:scolvpet_mobile/ui/widgets/ios_widgets.dart';
import 'support/memory_repositories.dart';

void main() {
  test(
    'MemoryGrowthRepository happy path: profile → script → link → leads',
    () async {
      final repo = MemoryGrowthRepository();
      final profiles = await repo.listPublicHamsters();
      expect(profiles.single.publicName, '奶茶');
      expect(profiles.single.consultable, isTrue);

      final updated = await repo.upsertPublicHamster(
        'h-naicha',
        const GrowthPublicHamsterDraft(
          publicName: '奶茶',
          summary: '亲人、活动规律',
          traits: ['亲人', '活动规律'],
          filmingStatus: 'ready',
          published: true,
          consultable: true,
          ctaText: '进入主页咨询',
        ),
      );
      expect(updated.filmingStatus, 'ready');

      final opportunities = opportunitiesFromProfiles(profiles);
      expect(opportunities, isNotEmpty);
      expect(opportunities.first.publicName, '奶茶');

      final campaign = await repo.generateCampaign(
        const GrowthGenerateDraft(
          campaignType: 'video',
          platform: 'wechat_channels',
          goal: '成长记录',
          durationSeconds: 35,
          tone: '温柔自然',
          hamsterId: 'h-naicha',
        ),
      );
      expect(campaign.campaignCode, startsWith('c_'));
      expect(campaign.script.sections, isNotEmpty);
      expect(campaign.script.facts.any((f) => f.key == 'public_name'), isTrue);
      expect(campaign.publicUrlPath, contains('campaign='));
      expect(campaign.publicUrl(), contains('/p/'));

      final leads = await repo.listLeads();
      expect(leads.first.name, '阿雪');
      expect(leads.first.interestHamsterName, '奶茶');
      expect(leads.first.wechat, 'snow123');
    },
  );

  test('consultable requires published in memory repository', () async {
    final repo = MemoryGrowthRepository();
    expect(
      () => repo.upsertPublicHamster(
        'h-naicha',
        const GrowthPublicHamsterDraft(
          publicName: '奶茶',
          published: false,
          consultable: true,
        ),
      ),
      throwsA(isA<GrowthRepositoryException>()),
    );
  });

  testWidgets('GrowthHubPage shows metrics and opportunities', (tester) async {
    final controller = GrowthController(repository: MemoryGrowthRepository());
    await tester.pumpWidget(
      MaterialApp(home: GrowthHubPage(controller: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('获客'), findsOneWidget);
    expect(find.byKey(const Key('growth-metric-ready')), findsOneWidget);
    expect(find.byKey(const Key('growth-open-generate-video')), findsOneWidget);
    expect(find.byKey(const Key('growth-open-generate-live')), findsOneWidget);
    expect(find.textContaining('奶茶'), findsWidgets);
    expect(find.byKey(const Key('growth-lead-lead-1')), findsOneWidget);
    expect(find.textContaining('阿雪'), findsOneWidget);
    expect(find.textContaining('来源'), findsOneWidget);
  });

  testWidgets('GrowthCampaignResultPage exposes copy/share controls', (
    tester,
  ) async {
    final repo = MemoryGrowthRepository();
    final campaign = await repo.generateCampaign(
      const GrowthGenerateDraft(
        campaignType: 'video',
        platform: 'wechat_channels',
        goal: '成长记录',
        durationSeconds: 35,
        tone: '温柔自然',
        hamsterId: 'h-naicha',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: GrowthCampaignResultPage(campaign: campaign)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('growth-result-title')), findsOneWidget);
    expect(find.byKey(const Key('growth-result-copy-all')), findsOneWidget);
    expect(find.byKey(const Key('growth-result-share')), findsOneWidget);
    expect(find.byKey(const Key('growth-result-copy-link')), findsOneWidget);
    expect(find.byKey(const Key('growth-result-section-1')), findsOneWidget);
    expect(find.byKey(const Key('growth-result-hook')), findsOneWidget);
    expect(campaign.script.facts.any((f) => f.key == 'public_name'), isTrue);
    expect(campaign.script.fullCopyText, contains('口播'));
  });

  testWidgets('profile switches: consultable disabled when not published', (
    tester,
  ) async {
    final controller = GrowthController(repository: MemoryGrowthRepository());
    await controller.refreshProfiles();
    await tester.pumpWidget(
      MaterialApp(
        home: GrowthProfileEditorPage(
          controller: controller,
          hamsterId: 'h-naicha',
          displayName: '奶茶',
          existing: controller.profilesState.data?.first,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('growth-profile-published')), findsOneWidget);
    expect(find.byKey(const Key('growth-profile-consultable')), findsOneWidget);
    await tester.tap(find.byKey(const Key('growth-profile-published')));
    await tester.pumpAndSettle();
    final consultable = tester.widget<SwitchListTile>(
      find.byKey(const Key('growth-profile-consultable')),
    );
    expect(consultable.onChanged, isNull);
  });

  testWidgets('growth selection fields use the unified wheel picker', (
    tester,
  ) async {
    final controller = GrowthController(repository: MemoryGrowthRepository());
    await controller.refreshProfiles();
    await tester.pumpWidget(
      MaterialApp(
        home: GrowthGeneratePage(controller: controller, hamsters: const []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(IosPickerField<String>), findsNWidgets(3));
    await tester.tap(find.byKey(const Key('growth-generate-hamster')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsOneWidget);
    expect(find.byType(CupertinoActionSheet), findsNothing);

    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'growth generate defers initial profile refresh until after build',
    (tester) async {
      final controller = GrowthController(repository: MemoryGrowthRepository());
      await tester.pumpWidget(
        MaterialApp(
          home: GrowthGeneratePage(controller: controller, hamsters: const []),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(controller.profilesState.data, isNotNull);
    },
  );
}
