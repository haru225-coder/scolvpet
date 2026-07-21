// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/tasks/task_models.dart';
import 'package:scolvpet_mobile/features/tasks/task_repository.dart';

class MemoryTaskRepository implements TaskRepository {
  MemoryTaskRepository({List<CareTaskItem>? seed}) : _tasks = [...?seed];

  final List<CareTaskItem> _tasks;
  final List<TaskReminderItem> _reminders = <TaskReminderItem>[];
  int _seq = 0;

  CareTaskItem seedTask({
    String? title,
    String taskType = 'enclosure_cleaning',
    String priority = 'normal',
    DateTime? scheduledAt,
    List<String> subjectIds = const <String>[],
    String state = 'pending',
  }) {
    final id = 'task-${_seq++}';
    final when =
        scheduledAt ?? DateTime.now().toUtc().add(const Duration(hours: 2));
    final task = CareTaskItem(
      id: id,
      taskType: taskType,
      targetType: 'enclosure',
      targetId: 'enc-demo',
      title: title ?? taskTypeLabel(taskType),
      scheduledAt: when,
      priority: priority,
      state: state == 'open' ? 'pending' : state,
      subjectIds: subjectIds.isEmpty ? const ['sub-demo'] : subjectIds,
      completedSubjectIds: const [],
      stageTotal: subjectIds.isEmpty ? 1 : subjectIds.length,
      stageDone: 0,
      version: 1,
    );
    _tasks.insert(0, task);
    _reminders.add(
      TaskReminderItem(
        id: 'rem-$id',
        taskId: id,
        channel: 'local',
        status: 'pending',
        scheduledAt: when,
        dedupeKey: 'task:$id',
      ),
    );
    return task;
  }

  CareTaskItem _require(String id) => _tasks.firstWhere(
    (t) => t.id == id,
    orElse: () => throw const TaskRepositoryException('任务不存在'),
  );

  void _replace(CareTaskItem task) {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i < 0) throw const TaskRepositoryException('任务不存在');
    _tasks[i] = task;
  }

  @override
  Future<List<CareTaskItem>> listTasks({String? state}) async {
    final values = List<CareTaskItem>.from(_tasks);
    if (state == null || state.isEmpty) return values;
    return values.where((t) => t.state == state).toList();
  }

  @override
  Future<CareTaskItem> getTask(String taskId) async => _require(taskId);

  @override
  Future<CareTaskItem> createTask(CreateCareTaskDraft draft) async {
    final id = 'task-${_seq++}';
    final subjects = draft.subjectIds.isEmpty
        ? <String>[draft.targetId]
        : draft.subjectIds;
    final task = CareTaskItem(
      id: id,
      taskType: draft.taskType,
      targetType: draft.targetType,
      targetId: draft.targetId,
      title: draft.title,
      scheduledAt: draft.scheduledAt.toUtc(),
      priority: draft.priority,
      state: 'pending',
      subjectIds: subjects,
      completedSubjectIds: const [],
      stageTotal: subjects.length,
      stageDone: 0,
      notes: draft.notes,
      version: 1,
    );
    _tasks.insert(0, task);
    _reminders.add(
      TaskReminderItem(
        id: 'rem-$id',
        taskId: id,
        channel: 'local',
        status: 'pending',
        scheduledAt: task.scheduledAt,
        dedupeKey: 'task:$id',
      ),
    );
    return task;
  }

  @override
  Future<CareTaskItem> completeTask(CareTaskItem task, {String? notes}) async {
    final current = _require(task.id);
    if (current.version != task.version) {
      throw const TaskRepositoryException('版本冲突，请刷新后重试');
    }
    if (!current.isOpen) {
      throw const TaskRepositoryException('任务已结束，无需再次完成');
    }
    final next = current.copyWith(
      state: 'completed',
      version: current.version + 1,
      stageDone: current.stageTotal == 0 ? 1 : current.stageTotal,
      completedSubjectIds: List<String>.from(current.subjectIds),
      notes: notes ?? current.notes,
    );
    _replace(next);
    _reminders.removeWhere((r) => r.taskId == next.id);
    return next;
  }

  @override
  Future<List<TaskReminderItem>> listReminders() async =>
      List<TaskReminderItem>.from(_reminders);
}
