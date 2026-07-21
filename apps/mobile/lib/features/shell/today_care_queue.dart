import '../i2/i2_models.dart';
import '../tasks/task_models.dart';
import '../weight/weight_alerts.dart';
import 'home_overview.dart';

/// Actionable item on the home "今日护理" queue.
enum TodayCareKind {
  overdueTask,
  dueTodayTask,
  weightAlert,
  dirtyEnclosure,
  pendingWean,
}

class TodayCareItem {
  const TodayCareItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.task,
    this.priority = 0,
  });

  final String id;
  final TodayCareKind kind;
  final String title;
  final String subtitle;

  /// When non-null, the queue row can complete this task inline.
  final CareTaskItem? task;

  /// Higher first (overdue > today > weight > dirty > wean).
  final int priority;

  bool get canComplete => task != null && task!.isOpen;
}

bool _isSameLocalDay(DateTime a, DateTime b) {
  final la = a.toLocal();
  final lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}

/// Build prioritized care queue for the home dashboard (pure).
List<TodayCareItem> buildTodayCareQueue({
  Iterable<CareTaskItem> tasks = const [],
  HomeOverviewMetrics? metrics,
  I2Snapshot? snapshot,
  DateTime? now,
  int maxItems = 8,
}) {
  final clock = now ?? DateTime.now();
  final items = <TodayCareItem>[];

  for (final task in tasks.where((t) => t.isOpen)) {
    // Use [clock] so tests and queue build share the same reference time.
    final overdue = task.scheduledAt.toUtc().isBefore(clock.toUtc());
    if (overdue) {
      items.add(
        TodayCareItem(
          id: 'task-overdue-${task.id}',
          kind: TodayCareKind.overdueTask,
          title: task.displayTitle,
          subtitle: '逾期 · ${taskTypeLabel(task.taskType)}',
          task: task,
          priority: 100,
        ),
      );
    } else if (_isSameLocalDay(task.scheduledAt, clock)) {
      items.add(
        TodayCareItem(
          id: 'task-today-${task.id}',
          kind: TodayCareKind.dueTodayTask,
          title: task.displayTitle,
          subtitle: '今日 · ${taskTypeLabel(task.taskType)}',
          task: task,
          priority: 80,
        ),
      );
    }
  }

  final alerts =
      metrics?.weightAlerts ??
      buildWeightAlerts(snapshot?.recentWeights ?? const <I2WeightRecord>[]);
  for (final alert in alerts.take(3)) {
    items.add(
      TodayCareItem(
        id: 'weight-${alert.hamsterId}',
        kind: TodayCareKind.weightAlert,
        title: '体重异常',
        subtitle: alert.summary,
        priority: 60,
      ),
    );
  }

  final dirtyCount =
      metrics?.dirtyEnclosureCount ??
      (snapshot?.enclosures.where((e) {
            final c = e.cleanlinessState.toLowerCase();
            return c.contains('dirty') ||
                c.contains('soil') ||
                c.contains('needs_clean');
          }).length ??
          0);
  if (dirtyCount > 0) {
    items.add(
      TodayCareItem(
        id: 'dirty-enclosures',
        kind: TodayCareKind.dirtyEnclosure,
        title: '待清洁笼盒',
        subtitle: '$dirtyCount 个笼盒需清洁',
        priority: 40,
      ),
    );
  }

  final weanCount = metrics?.pendingWeanOrSexCount ?? 0;
  if (weanCount > 0) {
    items.add(
      TodayCareItem(
        id: 'wean-litters',
        kind: TodayCareKind.pendingWean,
        title: '待断奶/分性',
        subtitle: '$weanCount 窝需跟进',
        priority: 30,
      ),
    );
  }

  items.sort((a, b) {
    final byPriority = b.priority.compareTo(a.priority);
    if (byPriority != 0) return byPriority;
    return a.title.compareTo(b.title);
  });

  if (items.length <= maxItems) return items;
  return items.sublist(0, maxItems);
}
