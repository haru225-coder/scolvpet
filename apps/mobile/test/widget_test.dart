import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

import 'package:scolvpet_mobile/core/app_services.dart';
import 'package:scolvpet_mobile/core/app_state.dart';
import 'package:scolvpet_mobile/core/session_store.dart';
import 'package:scolvpet_mobile/data/i1_repository.dart';
import 'package:scolvpet_mobile/features/breeding/breeding.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/litter/litter.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';
import 'package:scolvpet_mobile/ui/screens.dart';
import 'package:scolvpet_mobile/ui/theme/ios_theme.dart';
import 'package:scolvpet_mobile/main.dart';
import 'support/memory_repositories.dart';

void main() {
  test(
    'AppState restores generated models into offline read-only state',
    () async {
      final state = AppState(
        repository: FakeRepository(offline: true),
        sessionStore: MemorySessionStore(snapshot: demoSnapshot),
      );

      await state.restore();

      expect(state.phase, AppPhase.home);
      expect(state.offline, isTrue);
      expect(state.account?.phoneMasked, '138****8000');
      expect(state.organization?.name, '雪团熊舍');
      expect(state.ownerRules.single.speciesCode, 'mesocricetus_auratus');
      expect(state.systemRules.single.sourceNote, 'I1 系统模板');
    },
  );

  testWidgets(
    'ScolvPetApp renders initialization, three navigation tabs and cached shell',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final state = AppState(
        repository: FakeRepository(offline: true),
        sessionStore: MemorySessionStore(snapshot: demoSnapshot, delayed: true),
      );
      final i2Controller = I2Controller(repository: MemoryI2Repository());
      final breedingController = BreedingController(
        repository: MemoryBreedingRepository(),
      );
      final litterBoardController = LitterBoardController(
        repository: MemoryLitterBoardRepository(),
      );
      final taskRepo = MemoryTaskRepository();
      final todayWidgetPublisher = MemoryTodayWidgetPublisher();
      final taskController = TaskController(
        repository: taskRepo,
        notifications: MemoryLocalNotificationScheduler(),
        widgetPublisher: todayWidgetPublisher,
      );

      await tester.pumpWidget(
        ScolvPetApp(
          services: AppServices(
            state: state,
            i2Controller: i2Controller,
            breedingController: breedingController,
            litterBoardController: litterBoardController,
            taskController: taskController,
            pedigreeRepository: MemoryPedigreeRepository(),
            healthRepository: MemoryHealthRepository(),
            memberRepository: MemoryMemberRepository(),
            crmRepository: MemoryCrmRepository(),
            contractsRepository: MemoryContractsRepository(),
            accountingRepository: MemoryAccountingRepository(),
            geneticRepository: MemoryGeneticRepository(),
            paywallRepository: MemoryPaywallRepository(),
            publicSiteRepository: MemoryPublicSiteRepository(),
            miniprogramRepository: MemoryMiniprogramRepository(),
            assistantRepository: MemoryAssistantRepository(),
            studRepository: MemoryStudRepository(),
            growthRepository: MemoryGrowthRepository(),
            todayWidgetPublisher: todayWidgetPublisher,
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 40));
      await tester.pumpAndSettle();

      expect(find.byType(HomeShell), findsOneWidget);
      final shellContext = tester.element(find.byType(HomeShell));
      expect(Theme.of(shellContext).brightness, Brightness.light);
      expect(ScolvPalette.of(shellContext).accent, ScolvPalette.light.accent);
      for (final label in ['工作台', '仓鼠', '繁育']) {
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
      // P0-1: 管家 / 我的 已移出底栏
      for (final gone in ['今日', '管家', '我的']) {
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(gone),
          ),
          findsNothing,
        );
      }
      expect(find.text('今日待办'), findsOneWidget);
      expect(find.text('经营概览'), findsOneWidget);
      expect(find.text('繁育动态'), findsOneWidget);
      expect(find.text('在养'), findsOneWidget);
      expect(
        find.byKey(const Key('home-quick-create-hamster')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('home-quick-enclosures')), findsNothing);
      expect(find.byKey(const Key('home-quick-more-toggle')), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('繁育'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('繁育向导'), findsOneWidget);
      expect(find.text('窝次看板'), findsOneWidget);
      // 回到工作台，经右上角账号入口进入原「我的」能力
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('工作台'),
        ),
      );
      await tester.pumpAndSettle();
      // 工作台是可滚动页，先滚回顶部再点 header 入口
      final homeScroll = find.byType(Scrollable).first;
      await tester.drag(homeScroll, const Offset(0, 2400));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('home-open-account')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home-open-account')), findsOneWidget);
      expect(find.byKey(const Key('home-open-assistant')), findsOneWidget);
      await tester.tap(find.byKey(const Key('home-open-account')));
      await tester.pumpAndSettle();
      expect(find.textContaining('雪团熊舍'), findsOneWidget);
      // Account ListView is lazy — scroll each entry into view.
      for (final key in [
        const Key('mine-open-crm'),
        const Key('mine-open-contracts'),
        const Key('mine-open-accounting'),
        const Key('mine-open-today-widget'),
        const Key('mine-open-genetic'),
        const Key('mine-open-paywall'),
        const Key('mine-open-public-site'),
        const Key('mine-open-assistant'),
        const Key('mine-open-stud'),
      ]) {
        await tester.scrollUntilVisible(find.byKey(key), 100);
        expect(find.byKey(key), findsOneWidget);
      }
      await tester.scrollUntilVisible(
        find.byKey(const Key('mine-open-genetic')),
        -100,
      );
      expect(find.byKey(const Key('mine-open-push')), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('mine-open-public-site')),
        100,
      );
      expect(find.byKey(const Key('mine-open-miniprogram')), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('mine-open-assistant')),
        100,
      );
      await tester.tap(find.byKey(const Key('mine-open-assistant')));
      await tester.pumpAndSettle();
      // 管家改为 push；遮罩路由下底栏 offstage，用 skipOffstage 校验仍停在工作台
      expect(
        tester
            .widget<NavigationBar>(
              find.byType(NavigationBar, skipOffstage: false),
            )
            .selectedIndex,
        0,
      );
      expect(find.byKey(const Key('assistant-read-only-note')), findsOneWidget);
      expect(find.text('问问管家'), findsWidgets);
    },
  );
}

final demoSnapshot = SessionSnapshot(
  account: {
    'id': '00000000-0000-0000-0000-000000000001',
    'phone_masked': '138****8000',
    'display_name': '演示舍主一',
  },
  organization: {
    'id': '00000000-0000-0000-0000-000000000101',
    'owner_id': '00000000-0000-0000-0000-000000000001',
    'name': '雪团熊舍',
    'mode': 'personal',
    'timezone': 'Asia/Shanghai',
    'weight_unit': 'g',
    'version': 1,
    'created_at': '2026-07-16T00:00:00Z',
    'updated_at': '2026-07-16T00:00:00Z',
  },
  rules: [demoRule(owner: true)],
  systemRules: [demoRule(owner: false)],
);

Map<String, dynamic> demoRule({required bool owner}) => {
  'id': owner
      ? '00000000-0000-0000-0000-000000000301'
      : '00000000-0000-0000-0000-000000000201',
  'owner_id': owner ? '00000000-0000-0000-0000-000000000001' : null,
  'scope': owner ? 'owner' : 'system',
  'source_template_id': owner ? '00000000-0000-0000-0000-000000000201' : null,
  'species_code': 'mesocricetus_auratus',
  'variety_scope': ['golden'],
  'gestation_min_days': 16,
  'gestation_max_days': 18,
  'pairing_max_minutes': 15,
  'weaning_target_days': 21,
  'sexing_target_days': 28,
  'separation_target_days': 35,
  'post_breeding_rest_days': 7,
  'profile_creation_deadline_days': 42,
  'weight_reference': {'unit': 'g'},
  'source_note': owner ? 'I1 owner copy' : 'I1 系统模板',
  'version': 1,
  'effective_at': '2026-07-16T00:00:00Z',
  'frozen': true,
};

class MemorySessionStore implements SessionStorePort {
  MemorySessionStore({this.snapshot, this.delayed = false});

  final SessionSnapshot? snapshot;
  final bool delayed;

  @override
  Future<void> clear() async {}

  @override
  Future<SessionSnapshot?> readSnapshot() async {
    if (delayed) await Future<void>.delayed(const Duration(milliseconds: 20));
    return snapshot;
  }

  @override
  Future<String?> readAccessToken() async {
    if (delayed) await Future<void>.delayed(const Duration(milliseconds: 20));
    return 'cached-access-token';
  }

  @override
  Future<String?> readRefreshToken() async => 'cached-refresh-token';

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {}

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

class FakeRepository implements I1Repository {
  FakeRepository({required this.offline});

  final bool offline;

  DioException get networkError => DioException(
    requestOptions: RequestOptions(path: '/v1/me'),
    type: DioExceptionType.connectionError,
  );

  @override
  Future<SpeciesRuleVersion> copyRule(SpeciesRuleVersion template) async {
    if (offline) throw networkError;
    return template;
  }

  @override
  Future<CurrentAccountResponseData> getCurrentAccount() async {
    throw networkError;
  }

  @override
  Future<SessionResponseData> login({
    required String phone,
    required String verificationId,
    required String code,
  }) async => throw networkError;

  @override
  Future<void> logout() async {}

  @override
  Future<SessionResponseData> refresh(String refreshToken) async {
    throw networkError;
  }

  @override
  Future<String> requestCode(String phone) async => throw networkError;

  @override
  Future<List<SpeciesRuleVersion>> listOwnerRules() async {
    throw networkError;
  }

  @override
  Future<List<SpeciesRuleVersion>> listSystemRules() async {
    throw networkError;
  }

  @override
  Future<Organization> updateOrganization({
    required String name,
    required int version,
  }) async => throw networkError;
}
