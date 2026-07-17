import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/breeding/breeding.dart';
import 'package:scolvpet_mobile/features/calendar/calendar.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/i2/i2_models.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';

void main() {
  test('calendarKindForTaskType maps weaning/cleaning/weight', () {
    expect(calendarKindForTaskType('weaning_due'), CalendarEventKind.weaning);
    expect(
      calendarKindForTaskType('enclosure_cleaning'),
      CalendarEventKind.cleaning,
    );
    expect(
      calendarKindForTaskType('pup_weight_check'),
      CalendarEventKind.weight,
    );
    expect(
      calendarKindForTaskType('gestation_window'),
      CalendarEventKind.breeding,
    );
  });

  test('buildCalendarEvents aggregates birth/wean/cleaning dots', () {
    final events = buildCalendarEvents(
      tasks: [
        CareTaskItem(
          id: 't1',
          taskType: 'enclosure_cleaning',
          targetType: 'enclosure',
          targetId: 'e1',
          title: 'A1 清洁',
          scheduledAt: DateTime.utc(2026, 7, 10, 2),
          priority: 'normal',
          state: 'pending',
          version: 1,
        ),
        CareTaskItem(
          id: 't2',
          taskType: 'weaning',
          targetType: 'litter',
          targetId: 'l1',
          title: '断奶检查',
          scheduledAt: DateTime.utc(2026, 7, 20, 2),
          priority: 'high',
          state: 'pending',
          version: 1,
        ),
      ],
      plans: [
        BreedingPlan(
          id: 'p1',
          sireId: 's1',
          damId: 'd1',
          ruleVersionId: 'r1',
          state: 'gestating',
          version: 1,
          name: '雪团计划',
          expectedBirthStart: DateTime.utc(2026, 7, 15),
          expectedBirthEnd: DateTime.utc(2026, 7, 18),
        ),
      ],
      litters: [
        I2Litter(
          id: 'l1',
          code: 'L-01',
          origin: 'breeding',
          bornAt: DateTime.utc(2026, 7, 1),
          initialAliveCount: 4,
          currentManagedCount: 4,
          state: 'nursing',
          enclosureId: 'e1',
          sireId: 's1',
          damId: 'd1',
          version: 1,
        ),
      ],
      weaningDayOffset: 21,
    );

    expect(
      events.any((e) => e.kind == CalendarEventKind.cleaning),
      isTrue,
    );
    expect(
      events.any((e) => e.kind == CalendarEventKind.expectedBirth),
      isTrue,
    );
    expect(events.any((e) => e.kind == CalendarEventKind.weaning), isTrue);

    final month = const CalendarMonth(year: 2026, month: 7);
    final byDay = eventsByDay(events, month);
    // cleaning local day depends on timezone; assert kinds exist in July.
    final allKinds = byDay.values.expand(kindsForDay).toSet();
    expect(allKinds, contains(CalendarEventKind.cleaning));
    expect(allKinds, contains(CalendarEventKind.expectedBirth));
    expect(allKinds, contains(CalendarEventKind.weaning));
  });

  test('CalendarMonth Monday-first grid for July 2026', () {
    // 2026-07-01 is Wednesday → two leading blanks (Mon,Tue)
    final month = const CalendarMonth(year: 2026, month: 7);
    final cells = month.dayCells;
    expect(cells.take(2).every((c) => c == null), isTrue);
    expect(cells[2], DateTime(2026, 7, 1));
    expect(cells.whereType<DateTime>().length, 31);
    expect(cells.length % 7, 0);
  });

  testWidgets('CalendarMonthPage shows month and event list on day tap', (
    tester,
  ) async {
    final taskRepo = MemoryTaskRepository();
    taskRepo.seedTask(
      title: '笼盒清洁',
      taskType: 'enclosure_cleaning',
      // Noon UTC → still 7/12 in Asia/Shanghai (+8), safe across TZ.
      scheduledAt: DateTime.utc(2026, 7, 12, 12),
    );
    final breedingRepo = MemoryBreedingRepository();
    // Use controller list via seed if available; otherwise empty plans ok.
    final i2 = I2Controller(
      repository: MemoryI2Repository(
        snapshot: I2Snapshot(
          hamsters: const [],
          litters: [
            I2Litter(
              id: 'l1',
              code: 'L-01',
              origin: 'breeding',
              bornAt: DateTime(2026, 7, 1),
              initialAliveCount: 3,
              currentManagedCount: 3,
              state: 'nursing',
              enclosureId: 'e1',
              sireId: 's1',
              damId: 'd1',
              version: 1,
            ),
          ],
          enclosures: const [],
          lastSyncedAt: DateTime(2026, 7, 1),
        ),
      ),
    );
    await i2.restore();

    final taskController = TaskController(
      repository: taskRepo,
      notifications: MemoryLocalNotificationScheduler(),
    );
    final breedingController = BreedingController(repository: breedingRepo);

    await tester.pumpWidget(
      MaterialApp(
        home: CalendarMonthPage(
          taskController: taskController,
          breedingController: breedingController,
          i2Controller: i2,
          initialMonth: DateTime(2026, 7, 12),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026年07月'), findsOneWidget);
    expect(find.text('预产'), findsWidgets);

    // Day 12 should have cleaning task; day 22 wean (born Jul1 +21).
    await tester.tap(find.byKey(const Key('calendar-day-12')));
    await tester.pumpAndSettle();
    expect(find.textContaining('笼盒清洁'), findsWidgets);

    await tester.tap(find.byKey(const Key('calendar-day-22')));
    await tester.pumpAndSettle();
    expect(find.textContaining('断奶'), findsWidgets);
  });
}
