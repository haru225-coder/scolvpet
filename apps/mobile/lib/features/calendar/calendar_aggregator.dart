import '../breeding/breeding_models.dart';
import '../i2/i2_models.dart';
import '../tasks/task_models.dart';
import 'calendar_models.dart';

/// Pure aggregation of tasks + breeding + litters into calendar events.
List<CalendarEvent> buildCalendarEvents({
  Iterable<CareTaskItem> tasks = const [],
  Iterable<BreedingPlan> plans = const [],
  Iterable<I2Litter> litters = const [],
  int weaningDayOffset = 21,
}) {
  final events = <CalendarEvent>[];

  for (final task in tasks) {
    final local = task.scheduledAt.toLocal();
    events.add(
      CalendarEvent(
        id: 'task:${task.id}',
        kind: calendarKindForTaskType(task.taskType),
        title: task.displayTitle,
        date: local,
        subtitle: taskTypeLabel(task.taskType),
        sourceType: 'task',
        sourceId: task.id,
      ),
    );
  }

  for (final plan in plans) {
    final start = plan.expectedBirthStart?.toLocal();
    final end = plan.expectedBirthEnd?.toLocal();
    if (start != null) {
      events.add(
        CalendarEvent(
          id: 'plan-birth-start:${plan.id}',
          kind: CalendarEventKind.expectedBirth,
          title: '${plan.displayName} 预产起',
          date: start,
          subtitle: '预产窗口开始',
          sourceType: 'breeding_plan',
          sourceId: plan.id,
        ),
      );
    }
    if (end != null &&
        (start == null ||
            DateTime(end.year, end.month, end.day) !=
                DateTime(start.year, start.month, start.day))) {
      events.add(
        CalendarEvent(
          id: 'plan-birth-end:${plan.id}',
          kind: CalendarEventKind.expectedBirth,
          title: '${plan.displayName} 预产止',
          date: end,
          subtitle: '预产窗口结束',
          sourceType: 'breeding_plan',
          sourceId: plan.id,
        ),
      );
    }
    final actual = plan.actualBirthAt?.toLocal();
    if (actual != null) {
      events.add(
        CalendarEvent(
          id: 'plan-birth-actual:${plan.id}',
          kind: CalendarEventKind.expectedBirth,
          title: '${plan.displayName} 已产仔',
          date: actual,
          subtitle: '实际产仔日',
          sourceType: 'breeding_plan',
          sourceId: plan.id,
        ),
      );
    }
  }

  for (final litter in litters) {
    final born = litter.bornAt.toLocal();
    final state = litter.state.toLowerCase();
    final closed =
        state == 'closed' ||
        state == 'archived' ||
        state.contains('individualized');
    if (closed) continue;

    final weanDay = DateTime(
      born.year,
      born.month,
      born.day,
    ).add(Duration(days: weaningDayOffset));
    events.add(
      CalendarEvent(
        id: 'litter-wean:${litter.id}',
        kind: CalendarEventKind.weaning,
        title:
            '${(litter.code == null || litter.code!.isEmpty) ? litter.id : litter.code} 断奶窗口',
        date: weanDay,
        subtitle: '出生 +$weaningDayOffset 天',
        sourceType: 'litter',
        sourceId: litter.id,
      ),
    );
  }

  events.sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    return a.title.compareTo(b.title);
  });
  return events;
}

/// Bucket events by local calendar day for a given month.
Map<DateTime, List<CalendarEvent>> eventsByDay(
  Iterable<CalendarEvent> events,
  CalendarMonth month,
) {
  final map = <DateTime, List<CalendarEvent>>{};
  for (final event in events) {
    final day = event.dayKey;
    if (!month.contains(day)) continue;
    map.putIfAbsent(day, () => <CalendarEvent>[]).add(event);
  }
  return map;
}

/// Distinct kinds present on a day (for colored dots, max useful set).
List<CalendarEventKind> kindsForDay(Iterable<CalendarEvent> dayEvents) {
  final seen = <CalendarEventKind>{};
  final order = <CalendarEventKind>[];
  for (final e in dayEvents) {
    if (seen.add(e.kind)) order.add(e.kind);
  }
  return order;
}
