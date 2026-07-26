import 'package:scolvpet_mobile/features/tasks/local_notifications.dart';
import 'package:scolvpet_mobile/features/tasks/task_models.dart';

/// Test-only in-memory notification scheduler.
class MemoryLocalNotificationScheduler implements LocalNotificationScheduler {
  final Map<String, ScheduledLocalNotification> scheduled =
      <String, ScheduledLocalNotification>{};
  bool initialized = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> syncOpenTasks(Iterable<CareTaskItem> tasks) async {
    final openIds = <String>{};
    for (final task in tasks.where((t) => t.isOpen)) {
      openIds.add(task.id);
      scheduled[task.id] = ScheduledLocalNotification(
        taskId: task.id,
        title: task.displayTitle,
        body: '到期：${_formatWhen(task.scheduledAt)}',
        when: task.scheduledAt.toUtc(),
      );
    }
    scheduled.removeWhere((id, _) => !openIds.contains(id));
  }

  @override
  Future<void> cancelTask(String taskId) async {
    scheduled.remove(taskId);
  }

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
  }

  static String _formatWhen(DateTime value) {
    final local = value.toLocal();
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$mm-$dd $hh:$mi';
  }
}
