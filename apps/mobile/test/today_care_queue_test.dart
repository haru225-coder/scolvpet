import 'package:flutter_test/flutter_test.dart';
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

    final queue = buildTodayCareQueue(tasks: tasks, metrics: metrics, now: now);

    expect(queue.first.kind, TodayCareKind.overdueTask);
    expect(queue.any((i) => i.kind == TodayCareKind.dueTodayTask), isTrue);
    expect(queue.any((i) => i.kind == TodayCareKind.weightAlert), isTrue);
    expect(queue.any((i) => i.kind == TodayCareKind.dirtyEnclosure), isTrue);
    expect(queue.any((i) => i.title == '未来断奶'), isFalse);
  });

  testWidgets('care queue aggregation still works when tasks exist', (
    tester,
  ) async {
    // v2 首页不再主推今日待办；队列纯函数与 TaskController 仍需可用。
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

    final metrics = HomeOverviewMetrics.fromSnapshot(
      snapshot: const I2Snapshot(
        hamsters: [
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
        litters: [],
        enclosures: [],
        lastSyncedAt: null,
      ),
      drafts: const [],
      offline: false,
    );
    final queue = buildTodayCareQueue(
      tasks: tasks.listState.data ?? const [],
      metrics: metrics,
      snapshot: null,
    );
    expect(queue.any((i) => i.title.contains('今日复查')), isTrue);

    final task = tasks.openTasks.firstWhere(
      (t) => t.displayTitle.contains('今日复查'),
    );
    final ok = await tasks.complete(task);
    expect(ok, isTrue);
    expect(
      tasks.openTasks.where((t) => t.displayTitle.contains('今日复查')),
      isEmpty,
    );
  });
}
