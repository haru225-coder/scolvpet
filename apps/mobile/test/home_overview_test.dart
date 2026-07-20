import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_api/scolvpet_api.dart';
import 'package:scolvpet_mobile/core/app_state.dart';
import 'package:scolvpet_mobile/core/session_store.dart';
import 'package:scolvpet_mobile/data/i1_repository.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/shell/home_overview.dart';
import 'support/memory_repositories.dart';

void main() {
  final now = DateTime.utc(2026, 7, 17);

  test('HomeOverviewMetrics aggregates snapshot attention items', () {
    final metrics = HomeOverviewMetrics.fromSnapshot(
      snapshot: I2Snapshot(
        hamsters: [
          const I2Hamster(
            id: 'h1',
            internalCode: 'H-1',
            name: '母鼠A',
            sex: 'female',
            varietyCode: 'golden',
            lifecycleStatus: 'active',
            breedingStatus: 'gestating',
            birthDate: null,
            currentEnclosureId: 'e1',
            litterId: null,
            notes: null,
            version: 1,
          ),
          const I2Hamster(
            id: 'h2',
            internalCode: 'H-2',
            name: '归档',
            sex: 'male',
            varietyCode: 'golden',
            lifecycleStatus: 'archived',
            breedingStatus: 'retired',
            birthDate: null,
            currentEnclosureId: null,
            litterId: null,
            notes: null,
            version: 1,
          ),
        ],
        litters: [
          I2Litter(
            id: 'l1',
            code: 'L-1',
            origin: 'breeding',
            bornAt: now.subtract(const Duration(days: 22)),
            initialAliveCount: 6,
            currentManagedCount: 5,
            state: 'litter_nursing',
            enclosureId: 'e1',
            sireId: 'h3',
            damId: 'h1',
            version: 1,
          ),
        ],
        enclosures: [
          const I2Enclosure(
            id: 'e1',
            code: 'A-1',
            rackCode: 'A',
            levelCode: '1',
            state: 'occupied',
            cleanlinessState: 'dirty',
            capacity: 2,
            equipment: <String>[],
            lastCleanedAt: null,
            currentHamsterIds: <String>['h1'],
            version: 1,
          ),
        ],
        lastSyncedAt: now,
      ),
      drafts: const [
        I2Draft(id: 'd1', kind: 'hamster', payload: <String, dynamic>{}),
      ],
      offline: true,
      lastSyncLabel: 'cached',
      organizationName: '雪团熊舍',
      now: now,
    );

    expect(metrics.hamsterCount, 1);
    expect(metrics.enclosureCount, 1);
    expect(metrics.activeLitterCount, 1);
    expect(metrics.pendingWeanOrSexCount, 1);
    expect(metrics.gestatingDamCount, 1);
    expect(metrics.dirtyEnclosureCount, 1);
    expect(metrics.draftCount, 1);
    expect(metrics.attentionCount, 4);
    expect(metrics.offline, isTrue);
    expect(metrics.organizationName, '雪团熊舍');
  });

  testWidgets('HomeOverviewPage shows stats and quick actions', (tester) async {
    final local = MemoryI2LocalStore();
    await local.saveSnapshot(
      I2Snapshot(
        hamsters: const [
          I2Hamster(
            id: 'h1',
            internalCode: 'H-001',
            name: '雪团',
            sex: 'female',
            varietyCode: 'golden',
            lifecycleStatus: 'active',
            breedingStatus: 'candidate',
            birthDate: null,
            currentEnclosureId: null,
            litterId: null,
            notes: null,
            version: 1,
          ),
        ],
        litters: const <I2Litter>[],
        enclosures: const <I2Enclosure>[],
        lastSyncedAt: DateTime.utc(2026, 7, 1),
      ),
    );
    final controller = I2Controller(
      repository: MemoryI2Repository(failReads: true),
      localStore: local,
    );
    await controller.restore();

    final appState = AppState(
      repository: _OfflineI1(),
      sessionStore: _TokenSessionStore(snapshot: _homeSnapshot),
    );
    await appState.restore();

    var openedLitters = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeOverviewPage(
            state: appState,
            controller: controller,
            onOpenHamsters: () {},
            onOpenEnclosures: () {},
            onOpenBreeding: () {},
            onOpenLitters: () => openedLitters = true,
            onOpenDataCenter: () {},
            onCreateHamster: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('工作台'), findsOneWidget);
    // 副标题为问候 + 账号/机构名，机构名仍可能出现在问候行
    expect(find.textContaining('好'), findsWidgets);
    expect(find.text('经营概览'), findsOneWidget);
    expect(find.text('在养'), findsOneWidget);
    expect(find.text('今日待办'), findsOneWidget);
    expect(find.text('繁育动态'), findsOneWidget);
    expect(find.byKey(const Key('home-quick-create-hamster')), findsOneWidget);
    expect(find.byKey(const Key('home-quick-enclosures')), findsNothing);
    expect(find.byKey(const Key('home-quick-more-toggle')), findsNothing);
    expect(find.textContaining('离线只读'), findsOneWidget);
    // 活跃窝次 0 时可点进窝次；有数据时点「查看繁育」
    await tester.ensureVisible(find.byKey(const Key('home-breeding-feed-open')));
    await tester.tap(find.byKey(const Key('home-breeding-feed-open')));
    await tester.pumpAndSettle();
    // 本用例未注入 onOpenBreeding 断言；仅确认入口存在
    expect(openedLitters, isFalse);
  });

  testWidgets('HomeOverviewPage hides zero dashboard on uncached error', (
    tester,
  ) async {
    final controller = I2Controller(repository: MemoryI2Repository());
    controller.snapshotState = const I2AsyncState.error('服务器暂时繁忙');
    final appState = AppState(
      repository: _OfflineI1(),
      sessionStore: _TokenSessionStore(snapshot: _homeSnapshot),
    );
    await appState.restore();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeOverviewPage(
            state: appState,
            controller: controller,
            onOpenHamsters: () {},
            onOpenEnclosures: () {},
            onOpenBreeding: () {},
            onOpenLitters: () {},
            onOpenDataCenter: () {},
            onCreateHamster: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今日数据暂时不可用'), findsOneWidget);
    expect(find.text('服务器暂时繁忙'), findsOneWidget);
    expect(find.text('在养'), findsNothing);
    expect(find.text('今日待办'), findsNothing);
    expect(find.text('经营概览'), findsNothing);
    expect(find.text('需要关注'), findsNothing);
    expect(find.byKey(const Key('home-quick-create-hamster')), findsOneWidget);
  });

  test('buildBreedingFeed ranks gestation and active litters', () {
    final now = DateTime.utc(2026, 7, 20);
    final feed = buildBreedingFeed(
      snapshot: I2Snapshot(
        hamsters: const [
          I2Hamster(
            id: 'h1',
            internalCode: 'A02',
            name: '芝麻',
            sex: 'female',
            varietyCode: 'golden',
            lifecycleStatus: 'active',
            breedingStatus: 'gestating',
            birthDate: null,
            currentEnclosureId: null,
            litterId: null,
            notes: null,
            version: 1,
          ),
          I2Hamster(
            id: 'h2',
            internalCode: 'B01',
            name: '奶昔',
            sex: 'female',
            varietyCode: 'golden',
            lifecycleStatus: 'active',
            breedingStatus: 'active',
            birthDate: null,
            currentEnclosureId: null,
            litterId: null,
            notes: null,
            version: 1,
          ),
        ],
        litters: [
          I2Litter(
            id: 'l1',
            code: 'L20260708-01',
            origin: 'breeding',
            bornAt: now.subtract(const Duration(days: 12)),
            initialAliveCount: 7,
            currentManagedCount: 7,
            state: 'litter_nursing',
            enclosureId: 'e1',
            sireId: 'h0',
            damId: 'h2',
            version: 1,
          ),
        ],
        enclosures: const [],
        lastSyncedAt: now,
      ),
      now: now,
      maxItems: 3,
    );
    expect(feed, isNotEmpty);
    expect(feed.first.kind, 'gestation');
    expect(feed.any((e) => e.kind == 'litter' || e.kind == 'wean'), isTrue);
  });
}

final _homeSnapshot = SessionSnapshot(
  account: {
    'id': '00000000-0000-0000-0000-000000000001',
    'phone_masked': '138****8000',
    'display_name': '演示',
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
  rules: const [],
  systemRules: const [],
);

class _TokenSessionStore implements SessionStorePort {
  _TokenSessionStore({required this.snapshot});
  final SessionSnapshot snapshot;

  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => 'cached-access';

  @override
  Future<String?> readRefreshToken() async => 'cached-refresh';

  @override
  Future<SessionSnapshot?> readSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {}

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

class _OfflineI1 implements I1Repository {
  DioException get networkError => DioException(
    requestOptions: RequestOptions(path: '/v1/me'),
    type: DioExceptionType.connectionError,
  );

  @override
  Future<SpeciesRuleVersion> copyRule(SpeciesRuleVersion template) async =>
      throw networkError;

  @override
  Future<CurrentAccountResponseData> getCurrentAccount() async =>
      throw networkError;

  @override
  Future<SessionResponseData> login({
    required String phone,
    required String verificationId,
    required String code,
  }) async => throw networkError;

  @override
  Future<void> logout() async {}

  @override
  Future<SessionResponseData> refresh(String refreshToken) async =>
      throw networkError;

  @override
  Future<String> requestCode(String phone) async => throw networkError;

  @override
  Future<List<SpeciesRuleVersion>> listOwnerRules() async => throw networkError;

  @override
  Future<List<SpeciesRuleVersion>> listSystemRules() async =>
      throw networkError;

  @override
  Future<Organization> updateOrganization({
    required String name,
    required int version,
  }) async => throw networkError;
}
