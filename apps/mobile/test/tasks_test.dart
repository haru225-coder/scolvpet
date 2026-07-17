import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';

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

  testWidgets('TaskListPage completes a task from the list', (tester) async {
    final repo = MemoryTaskRepository();
    final task = repo.seedTask(title: '幼崽称重');
    final controller = TaskController(
      repository: repo,
      notifications: MemoryLocalNotificationScheduler(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TaskListPage(controller: controller, canWrite: true),
      ),
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
}
