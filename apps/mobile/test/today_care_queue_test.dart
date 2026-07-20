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
import 'package:scolvpet_mobile/features/shell/today_care_queue.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';
import 'support/memory_repositories.dart';

void main() {
  final now = DateTime.utc(2026, 7, 17, 12);

  test('buildTodayCareQueue prioritizes overdue then today then weight', () {
    final tasks = [
      CareTaskItem(
        id: 't-overdue',
        taskType: 'medication',
        targetType: 'hamster',
        targetId: 'h1',
        title: '逾期用药',
        scheduledAt: now.subtract(const Duration(days: 1)),
        priority: 'high',
        state: 'pending',
        version: 1,
      ),
      CareTaskItem(
        id: 't-today',
        taskType: 'enclosure_cleaning',
        targetType: 'enclosure',
        targetId: 'e1',
        title: '今日清洁',
        scheduledAt: now,
        priority: 'normal',
        state: 'pending',
        version: 1,
      ),
      CareTaskItem(
        id: 't-future',
        taskType: 'weaning',
        targetType: 'litter',
        targetId: 'l1',
        title: '未来断奶',
        scheduledAt: now.add(const Duration(days: 5)),
        priority: 'normal',
        state: 'pending',
        version: 1,
      ),
    ];
    final metrics = HomeOverviewMetrics.fromSnapshot(
      snapshot: I2Snapshot(
        hamsters: const [],
        litters: const [],
        enclosures: [
          const I2Enclosure(
            id: 'e1',
            code: 'A-1',
            rackCode: 'A',
            levelCode: '1',
            state: 'occupied_single',
            cleanlinessState: 'dirty',
            capacity: 1,
            equipment: [],
            lastCleanedAt: null,
            currentHamsterIds: ['h1'],
            version: 1,
          ),
        ],
        lastSyncedAt: now,
        recentWeights: [
          I2WeightRecord(
            id: 'w1',
            hamsterId: 'h1',
            litterId: null,
            measurementKind: 'individual',
            subjectCount: 1,
            weightG: 90,
            recordedAt: now,
            source: 'manual',
            previousWeightG: 100,
            changeFromPreviousG: -10,
            alertFlags: const ['drop_from_previous'],
            notes: null,
          ),
        ],
      ),
      drafts: const [],
      offline: false,
      now: now,
    );

    final queue = buildTodayCareQueue(
      tasks: tasks,
      metrics: metrics,
      now: now,
    );

    expect(queue.first.kind, TodayCareKind.overdueTask);
    expect(queue.any((i) => i.kind == TodayCareKind.dueTodayTask), isTrue);
    expect(queue.any((i) => i.kind == TodayCareKind.weightAlert), isTrue);
    expect(queue.any((i) => i.kind == TodayCareKind.dirtyEnclosure), isTrue);
    expect(queue.any((i) => i.title == '未来断奶'), isFalse);
  });

  testWidgets('HomeOverviewPage shows today care queue and completes task', (
    tester,
  ) async {
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
        litters: const [],
        enclosures: const [],
        lastSyncedAt: DateTime.utc(2026, 7, 1),
      ),
    );
    final i2 = I2Controller(
      repository: MemoryI2Repository(failReads: true),
      localStore: local,
    );
    await i2.restore();

    final taskRepo = MemoryTaskRepository();
    await taskRepo.createTask(
      CreateCareTaskDraft(
        taskType: 'medication',
        targetType: 'hamster',
        targetId: 'h1',
        title: '今日复查',
        scheduledAt: DateTime.now(),
        subjectIds: const ['h1'],
      ),
    );
    final tasks = TaskController(
      repository: taskRepo,
      notifications: MemoryLocalNotificationScheduler(),
    );
    await tasks.refresh();

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
            controller: i2,
            taskController: tasks,
            onOpenHamsters: () {},
            onOpenEnclosures: () {},
            onOpenBreeding: () {},
            onOpenLitters: () {},
            onOpenDataCenter: () {},
            onCreateHamster: () {},
            onOpenTasks: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-today-care-title')), findsOneWidget);
    expect(find.textContaining('今日复查'), findsWidgets);

    await tester.tap(find.text('完成').first);
    await tester.pumpAndSettle();
    expect(
      tasks.openTasks.where((t) => t.displayTitle.contains('今日复查')),
      isEmpty,
    );
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
  Future<List<SpeciesRuleVersion>> listOwnerRules() async =>
      throw networkError;

  @override
  Future<List<SpeciesRuleVersion>> listSystemRules() async =>
      throw networkError;

  @override
  Future<Organization> updateOrganization({
    required String name,
    required int version,
  }) async => throw networkError;
}
