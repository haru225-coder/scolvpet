import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'local_notifications.dart';
import 'task_models.dart';
import 'task_repository.dart';

class TaskController extends ChangeNotifier {
  TaskController({
    required this.repository,
    LocalNotificationScheduler? notifications,
  }) : notifications = notifications ?? MemoryLocalNotificationScheduler();

  final TaskRepository repository;
  final LocalNotificationScheduler notifications;

  I2AsyncState<List<CareTaskItem>> listState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  List<TaskReminderItem> reminders = const <TaskReminderItem>[];
  String? lastMessage;
  bool notificationsReady = false;

  List<CareTaskItem> get openTasks =>
      (listState.data ?? const <CareTaskItem>[]).where((t) => t.isOpen).toList();

  int get openCount => openTasks.length;

  int get overdueCount => openTasks.where((t) => t.isOverdue).length;

  Future<void> initializeNotifications() async {
    try {
      await notifications.initialize();
      notificationsReady = true;
    } catch (error) {
      notificationsReady = false;
      debugPrint('notifications init failed: $error');
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    listState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final tasks = await repository.listTasks();
      tasks.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      listState = tasks.isEmpty
          ? const I2AsyncState.empty(message: '暂无任务')
          : I2AsyncState.data(tasks);
      try {
        reminders = await repository.listReminders();
      } catch (_) {
        reminders = const <TaskReminderItem>[];
      }
      await _syncNotifications(tasks);
      lastMessage = null;
    } catch (error) {
      listState = I2AsyncState.error(taskRepositoryErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> complete(CareTaskItem task, {String? notes}) async {
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      final next = await repository.completeTask(task, notes: notes);
      final current = List<CareTaskItem>.from(
        listState.data ?? const <CareTaskItem>[],
      );
      final index = current.indexWhere((t) => t.id == next.id);
      if (index >= 0) {
        current[index] = next;
      }
      listState = current.isEmpty
          ? const I2AsyncState.empty(message: '暂无任务')
          : I2AsyncState.data(current);
      await notifications.cancelTask(next.id);
      await _syncNotifications(current);
      actionState = const I2AsyncState.data(null);
      lastMessage = '已完成「${next.displayTitle}」';
      notifyListeners();
      return true;
    } catch (error) {
      final message = taskRepositoryErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> create(CreateCareTaskDraft draft) async {
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      final created = await repository.createTask(draft);
      final current = List<CareTaskItem>.from(
        listState.data ?? const <CareTaskItem>[],
      )..insert(0, created);
      current.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      listState = I2AsyncState.data(current);
      await _syncNotifications(current);
      actionState = const I2AsyncState.data(null);
      lastMessage = '已创建任务';
      notifyListeners();
      return true;
    } catch (error) {
      final message = taskRepositoryErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }

  Future<void> _syncNotifications(List<CareTaskItem> tasks) async {
    try {
      if (!notificationsReady) {
        await notifications.initialize();
        notificationsReady = true;
      }
      await notifications.syncOpenTasks(tasks.where((t) => t.isOpen));
    } catch (error) {
      debugPrint('sync notifications failed: $error');
    }
  }
}
