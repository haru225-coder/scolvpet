import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';

class _DelayedTaskRepository extends MemoryTaskRepository {
  final completeGate = Completer<void>();
  int completeCount = 0;

  @override
  Future<CareTaskItem> completeTask(CareTaskItem task, {String? notes}) async {
    completeCount++;
    await completeGate.future;
    return super.completeTask(task, notes: notes);
  }
}

class _FailingTaskRepository extends MemoryTaskRepository {
  @override
  Future<List<CareTaskItem>> listTasks({String? state}) {
    throw const TaskRepositoryException('任务服务暂时不可用');
  }
}

void main() {
  test('taskTypeLabel covers core hamster care types', () {
    expect(taskTypeLabel('enclosure_cleaning'), '笼盒清洁');
    expect(taskTypeLabel('pup_weight_drop'), '幼崽掉重');
    expect(taskTypeLabel('weaning_due'), '断奶');
  });

  test('MemoryTaskRepository completes task and drops reminder', () async {
    final repo = MemoryTaskRepository();
    final seeded = repo.seedTask(
      title: 'A 区清洁',
      scheduledAt: DateTime.utc(2026, 7, 17, 8),
    );
    expect(seeded.isOpen, isTrue);

    final completed = await repo.completeTask(seeded);
    expect(completed.state, 'completed');
    expect(completed.isOpen, isFalse);
    expect(completed.version, seeded.version + 1);

    final reminders = await repo.listReminders();
    expect(reminders.where((r) => r.taskId == seeded.id), isEmpty);
  });

  test('TaskController syncs local notifications for open tasks', () async {
    final repo = MemoryTaskRepository();
    final open = repo.seedTask(
      title: '断奶检查',
      taskType: 'weaning',
      scheduledAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
    );
    repo.seedTask(
      title: '已完成旧任务',
      state: 'completed',
      scheduledAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
    );
    final notifications = MemoryLocalNotificationScheduler();
    final controller = TaskController(
      repository: repo,
      notifications: notifications,
    );

    await controller.initializeNotifications();
    await controller.refresh();

    expect(controller.openCount, 1);
    expect(notifications.scheduled.keys, [open.id]);
    expect(notifications.scheduled[open.id]!.title, '断奶检查');

    final ok = await controller.complete(open);
    expect(ok, isTrue);
    expect(controller.openCount, 0);
    expect(notifications.scheduled, isEmpty);
    expect(controller.lastMessage, contains('已完成'));
  });

  test('TaskController creates a task from an empty list', () async {
    final repo = MemoryTaskRepository();
    final controller = TaskController(
      repository: repo,
      notifications: MemoryLocalNotificationScheduler(),
    );

    await controller.refresh();
    final ok = await controller.create(
      CreateCareTaskDraft(
        taskType: 'custom',
        targetType: 'organization',
        targetId: 'org-demo',
        scheduledAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
        title: '检查饮水器',
      ),
    );

    expect(ok, isTrue);
    expect(controller.openCount, 1);
    expect(controller.listState.data!.single.displayTitle, '检查饮水器');
  });

  testWidgets('TaskListPage completes a task from the list', (tester) async {
    final repo = MemoryTaskRepository();
    final task = repo.seedTask(title: '幼崽称重');
    final controller = TaskController(
      repository: repo,
      notifications: MemoryLocalNotificationScheduler(),
    );

    await tester.pumpWidget(
      MaterialApp(home: TaskListPage(controller: controller, canWrite: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('幼崽称重'), findsOneWidget);
    expect(find.byKey(Key('task-complete-${task.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('task-complete-${task.id}')));
    await tester.pumpAndSettle();

    expect(find.textContaining('已完成'), findsWidgets);
    final refreshed = await repo.getTask(task.id);
    expect(refreshed.state, 'completed');
  });

  testWidgets('TaskListPage keeps offline mode read-only', (tester) async {
    final repo = MemoryTaskRepository()..seedTask(title: '检查饮水器');
    final controller = TaskController(
      repository: repo,
      notifications: MemoryLocalNotificationScheduler(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskListPage(
          controller: controller,
          canWrite: true,
          offline: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('离线只读'), findsOneWidget);
    expect(find.byKey(const Key('task-complete-task-0')), findsNothing);
    expect(
      tester.widget<IconButton>(find.byKey(const Key('task-add'))).onPressed,
      isNull,
    );
  });

  testWidgets('TaskListPage read-only empty state does not prompt creation', (
    tester,
  ) async {
    final controller = TaskController(
      repository: MemoryTaskRepository(),
      notifications: MemoryLocalNotificationScheduler(),
    );
    await tester.pumpWidget(
      MaterialApp(home: TaskListPage(controller: controller, canWrite: false)),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有任务记录'), findsOneWidget);
    expect(find.textContaining('有权限的成员添加后'), findsOneWidget);
    expect(find.textContaining('右上角的加号'), findsNothing);
  });

  testWidgets('TaskListPage exposes load failure with retry', (tester) async {
    final controller = TaskController(
      repository: _FailingTaskRepository(),
      notifications: MemoryLocalNotificationScheduler(),
    );
    await tester.pumpWidget(
      MaterialApp(home: TaskListPage(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('任务服务暂时不可用'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.text('还没有任务记录'), findsNothing);
  });

  testWidgets('TaskListPage prevents duplicate completion while busy', (
    tester,
  ) async {
    final repo = _DelayedTaskRepository();
    final task = repo.seedTask(title: '幼崽复查');
    final controller = TaskController(
      repository: repo,
      notifications: MemoryLocalNotificationScheduler(),
    );
    await tester.pumpWidget(
      MaterialApp(home: TaskListPage(controller: controller, canWrite: true)),
    );
    await tester.pumpAndSettle();

    final complete = find.byKey(Key('task-complete-${task.id}'));
    await tester.tap(complete);
    await tester.pump();
    await tester.tap(complete, warnIfMissed: false);
    await tester.pump();

    expect(repo.completeCount, 1);
    repo.completeGate.complete();
    await tester.pumpAndSettle();
    expect((await repo.getTask(task.id)).state, 'completed');
  });

  testWidgets('TaskListPage summary is safe at 320pt and 1.3x text', (
    tester,
  ) async {
    final repo = MemoryTaskRepository()
      ..seedTask(title: '清洁')
      ..seedTask(
        title: '逾期称重',
        scheduledAt: DateTime.now().toUtc().subtract(const Duration(days: 1)),
      );
    final controller = TaskController(
      repository: repo,
      notifications: MemoryLocalNotificationScheduler(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.3),
          ),
          child: TaskListPage(controller: controller, canWrite: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('task-readonly-banner')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
