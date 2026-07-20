import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/health/health.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_hamsters.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/shell/home_overview.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';
import 'support/memory_repositories.dart';

void main() {
  test('CareTaskItem.relatesToHamster matches target and subjects', () {
    final byTarget = CareTaskItem(
      id: 't1',
      taskType: 'medication',
      targetType: 'hamster',
      targetId: 'h1',
      scheduledAt: DateTime.utc(2026, 7, 17),
      priority: 'normal',
      state: 'pending',
      version: 1,
    );
    final bySubject = CareTaskItem(
      id: 't2',
      taskType: 'follow_up',
      targetType: 'custom',
      targetId: 'x',
      subjectIds: const ['h1'],
      scheduledAt: DateTime.utc(2026, 7, 17),
      priority: 'normal',
      state: 'pending',
      version: 1,
    );
    final other = CareTaskItem(
      id: 't3',
      taskType: 'cleaning',
      targetType: 'enclosure',
      targetId: 'e1',
      scheduledAt: DateTime.utc(2026, 7, 17),
      priority: 'normal',
      state: 'pending',
      version: 1,
    );
    expect(byTarget.relatesToHamster('h1'), isTrue);
    expect(bySubject.relatesToHamster('h1'), isTrue);
    expect(other.relatesToHamster('h1'), isFalse);
    expect(
      CareTaskItem.openForHamster([byTarget, bySubject, other], 'h1'),
      hasLength(2),
    );
  });

  test('attentionWithTasks adds open care tasks', () {
    final metrics = HomeOverviewMetrics.fromSnapshot(
      snapshot: const I2Snapshot(
        hamsters: [],
        litters: [],
        enclosures: [],
        lastSyncedAt: null,
      ),
      drafts: const [],
      offline: false,
    );
    expect(metrics.attentionCount, 0);
    expect(metrics.attentionWithTasks(3), 3);
  });

  testWidgets('HamsterDetailPage shows related tasks and health preview', (
    tester,
  ) async {
    final i2 = I2Controller(
      repository: MemoryI2Repository(
        snapshot: I2Snapshot(
          hamsters: const [
            I2Hamster(
              id: 'h1',
              internalCode: 'H-1',
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
      ),
    );
    await i2.restore();

    final taskRepo = MemoryTaskRepository();
    await taskRepo.createTask(
      CreateCareTaskDraft(
        taskType: 'medication',
        targetType: 'hamster',
        targetId: 'h1',
        title: '雪团复查',
        scheduledAt: DateTime.utc(2026, 7, 18),
        subjectIds: const ['h1'],
      ),
    );

    final taskController = TaskController(
      repository: taskRepo,
      notifications: MemoryLocalNotificationScheduler(),
    );
    await taskController.refresh();

    final healthRepo = MemoryHealthRepository();
    await healthRepo.createRecord(
      HealthRecordDraft(
        hamsterId: 'h1',
        type: 'daily_check',
        observedAt: DateTime.utc(2026, 7, 16),
        notes: '精神可',
      ),
    );
    final healthController = HealthController(repository: healthRepo);
    await healthController.loadForHamster('h1');
    expect(healthController.listState.data, isNotEmpty);

    await tester.pumpWidget(
      MaterialApp(
        home: HamsterDetailPage(
          controller: i2,
          hamsterId: 'h1',
          taskController: taskController,
          healthController: healthController,
          onOpenHealth: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Ensure health section refreshed after first paint.
    await healthController.loadForHamster('h1');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('hamster-detail-profile')), findsOneWidget);
    expect(find.byKey(const Key('hamster-detail-archive')), findsOneWidget);
    // 健康分段：顶栏 chip 切换后可见护理待办
    await tester.tap(find.byKey(const Key('hamster-detail-section-health')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('hamster-detail-health-overview')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('hamster-care-tasks-title')), findsOneWidget);
    expect(find.textContaining('雪团复查'), findsOneWidget);
    expect(find.byKey(const Key('hamster-health-title')), findsOneWidget);

    await tester.tap(find.byKey(const Key('hamster-detail-section-records')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hamster-detail-recent')), findsOneWidget);
    expect(find.text('日常检查'), findsWidgets);
    expect(find.textContaining('精神可'), findsOneWidget);

    await tester.tap(find.byKey(const Key('hamster-detail-section-health')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('完成').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成').first);
    await tester.pumpAndSettle();
    final remaining = CareTaskItem.openForHamster(
      taskController.listState.data ?? const [],
      'h1',
    );
    expect(remaining.where((t) => t.displayTitle.contains('雪团复查')), isEmpty);
  });

  testWidgets('HamsterDetailPage follows light theme on small scaled layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = I2Controller(
      repository: MemoryI2Repository(
        snapshot: const I2Snapshot(
          hamsters: [
            I2Hamster(
              id: 'h-small',
              internalCode: 'H-SMALL-001',
              name: '长名字雪团宝宝',
              sex: 'female',
              varietyCode: 'poly|蜜波利',
              lifecycleStatus: 'active',
              breedingStatus: 'candidate',
              birthDate: null,
              currentEnclosureId: null,
              litterId: null,
              notes: null,
              version: 1,
            ),
          ],
          litters: [],
          enclosures: [],
          lastSyncedAt: null,
        ),
      ),
    );
    await controller.restore();

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 900),
            textScaler: TextScaler.linear(1.3),
          ),
          child: HamsterDetailPage(
            controller: controller,
            hamsterId: 'h-small',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final titleContext = tester.element(find.text('个体档案'));
    expect(Theme.of(titleContext).brightness, Brightness.light);
    expect(find.byKey(const Key('hamster-detail-profile')), findsOneWidget);
    expect(find.byKey(const Key('hamster-detail-archive')), findsOneWidget);
    expect(
      find.byKey(const Key('hamster-detail-section-overview')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
