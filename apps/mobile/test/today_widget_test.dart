import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/features/home_widget/home_widget.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';

CareTaskItem _task({
  required String id,
  required DateTime scheduledAt,
  String state = 'pending',
  String title = '任务',
}) {
  return CareTaskItem(
    id: id,
    taskType: 'custom',
    targetType: 'custom',
    targetId: 'x',
    title: title,
    scheduledAt: scheduledAt.toUtc(),
    priority: 'normal',
    state: state,
    version: 1,
  );
}

void main() {
  test('TodayWidgetSnapshot.fromTasks ranks overdue and formats body', () {
    final now = DateTime(2026, 7, 17, 12);
    final snapshot = TodayWidgetSnapshot.fromTasks([
      _task(
        id: '1',
        title: '逾期清洁',
        scheduledAt: now.subtract(const Duration(days: 1)),
      ),
      _task(id: '2', title: '今日称重', scheduledAt: now),
      _task(id: '3', title: '已完成', scheduledAt: now, state: 'completed'),
    ], now: now);
    expect(snapshot.overdueCount, 1);
    expect(snapshot.openCount, 2);
    expect(snapshot.bodyText, contains('逾期清洁'));
    expect(snapshot.bodyText, contains('今日称重'));
    expect(snapshot.bodyText, isNot(contains('已完成')));
    expect(snapshot.countLabel, contains('逾期'));
  });

  test('MemoryTodayWidgetPublisher stores last snapshot', () async {
    final pub = MemoryTodayWidgetPublisher();
    final snap = TodayWidgetSnapshot.fromTasks(const []);
    await pub.publish(snap);
    final loaded = await pub.loadLast();
    expect(loaded, isNotNull);
    expect(loaded!.headline, '今日待办');
  });

  test('TaskController publishes widget on refresh', () async {
    final pub = MemoryTodayWidgetPublisher();
    final repo = MemoryTaskRepository();
    final controller = TaskController(
      repository: repo,
      notifications: MemoryLocalNotificationScheduler(),
      widgetPublisher: pub,
    );
    // Seed via create if MemoryTaskRepository supports it
    await controller.refresh();
    expect(pub.last, isNotNull);
  });

  testWidgets('TodayWidgetPreviewPage syncs snapshot', (tester) async {
    final pub = MemoryTodayWidgetPublisher();
    final controller = TaskController(
      repository: MemoryTaskRepository(),
      notifications: MemoryLocalNotificationScheduler(),
      widgetPublisher: pub,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: TodayWidgetPreviewPage(
          taskController: controller,
          publisher: pub,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('今日待办组件'), findsOneWidget);
    await tester.tap(find.byKey(const Key('today-widget-sync')));
    await tester.pumpAndSettle();
    expect(find.text('桌面待办已更新'), findsOneWidget);
    expect(find.byKey(const Key('today-widget-body')), findsOneWidget);
  });
}
