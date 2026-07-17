import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'task_models.dart';

/// Portable local-notification scheduler (T-P0-05).
abstract interface class LocalNotificationScheduler {
  Future<void> initialize();

  Future<void> syncOpenTasks(Iterable<CareTaskItem> tasks);

  Future<void> cancelTask(String taskId);

  Future<void> cancelAll();
}

/// In-memory scheduler for tests and offline demos.
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

class ScheduledLocalNotification {
  const ScheduledLocalNotification({
    required this.taskId,
    required this.title,
    required this.body,
    required this.when,
  });

  final String taskId;
  final String title;
  final String body;
  final DateTime when;
}

/// Plugin-backed scheduler for device/simulator runs.
class PluginLocalNotificationScheduler implements LocalNotificationScheduler {
  PluginLocalNotificationScheduler({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  static bool _tzReady = false;

  static void ensureTimeZones() {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    // Asia/Shanghai is the product default timezone.
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));
    _tzReady = true;
  }

  @override
  Future<void> initialize() async {
    ensureTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: ios,
        macOS: ios,
      ),
    );
    // Best-effort permission; failures should not block task list.
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (error, stack) {
      debugPrint('local notification permission: $error\n$stack');
    }
    _ready = true;
  }

  @override
  Future<void> syncOpenTasks(Iterable<CareTaskItem> tasks) async {
    if (!_ready) await initialize();
    final open = tasks.where((t) => t.isOpen).toList();
    final openIds = open.map((t) => t.id).toSet();

    // Cancel stale notifications not in the open set.
    final pending = await _plugin.pendingNotificationRequests();
    for (final item in pending) {
      final payload = item.payload;
      if (payload != null &&
          payload.startsWith('task:') &&
          !openIds.contains(payload.substring(5))) {
        await _plugin.cancel(id: item.id);
      }
    }

    for (final task in open) {
      final id = _notificationId(task.id);
      final when = task.scheduledAt.toUtc();
      // Schedule slightly in the future if already overdue so user still sees it.
      final fireAt = when.isBefore(DateTime.now().toUtc())
          ? DateTime.now().toUtc().add(const Duration(seconds: 3))
          : when;
      final tzWhen = tz.TZDateTime.from(fireAt, tz.local);
      await _plugin.zonedSchedule(
        id: id,
        title: task.displayTitle,
        body: '熊舍管家 · ${taskTypeLabel(task.taskType)}',
        scheduledDate: tzWhen,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'care_tasks',
            '饲养任务',
            channelDescription: '断奶、清洁、称重等任务到期提醒',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'task:${task.id}',
      );
    }
  }

  @override
  Future<void> cancelTask(String taskId) async {
    if (!_ready) return;
    await _plugin.cancel(id: _notificationId(taskId));
  }

  @override
  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }

  int _notificationId(String taskId) {
    // Stable positive 31-bit id from task uuid/string.
    return taskId.hashCode & 0x7fffffff;
  }
}
