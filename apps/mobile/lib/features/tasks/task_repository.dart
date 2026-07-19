import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'task_models.dart';

abstract interface class TaskRepository {
  Future<List<CareTaskItem>> listTasks({String? state});

  Future<CareTaskItem> getTask(String taskId);

  Future<CareTaskItem> createTask(CreateCareTaskDraft draft);

  Future<CareTaskItem> completeTask(CareTaskItem task, {String? notes});

  Future<List<TaskReminderItem>> listReminders();
}

class TaskRepositoryException implements Exception {
  const TaskRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String taskRepositoryErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '网络请求失败，请稍后重试',
  mapLocal: (e) => e is TaskRepositoryException ? e.message : null,
);

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
    final when = scheduledAt ?? DateTime.now().toUtc().add(const Duration(hours: 2));
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

class DefaultApiTaskRepository implements TaskRepository {
  DefaultApiTaskRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  api.DefaultApi get _api => client.api;
  String _key() => 'task-${_uuid.v4()}';
  String _etag(int version) => '"$version"';

  CareTaskItem _map(api.CareTask task) {
    return CareTaskItem(
      id: task.id,
      taskType: task.taskType.value,
      targetType: task.targetType.value,
      targetId: task.targetId,
      title: task.title,
      scheduledAt: task.scheduledAt.toUtc(),
      priority: task.priority.value,
      state: task.state.value,
      subjectIds: task.subjectIds ?? const <String>[],
      completedSubjectIds: task.completedSubjectIds ?? const <String>[],
      stageTotal: task.stageTotal,
      stageDone: task.stageDone,
      notes: task.notes,
      version: task.version,
    );
  }

  @override
  Future<List<CareTaskItem>> listTasks({String? state}) async {
    api.TaskState? filter;
    if (state != null && state.isNotEmpty) {
      final match = api.TaskState.values.where((v) => v.value == state);
      filter = match.isEmpty ? null : match.first;
    }
    final response = await _api.listTasks(limit: 100, state: filter);
    final data = response.data?.data ?? const <api.CareTask>[];
    return data.map(_map).toList();
  }

  @override
  Future<CareTaskItem> getTask(String taskId) async {
    final response = await _api.getTask(taskId: taskId);
    final task = response.data?.data;
    if (task == null) {
      throw const TaskRepositoryException('任务不存在');
    }
    return _map(task);
  }

  @override
  Future<CareTaskItem> createTask(CreateCareTaskDraft draft) async {
    final response = await _api.createTask(
      idempotencyKey: _key(),
      careTaskCreateRequest: api.CareTaskCreateRequest(
        taskType: draft.taskType,
        targetType: draft.targetType,
        targetId: draft.targetId,
        title: draft.title,
        scheduledAt: draft.scheduledAt.toUtc(),
        priority: api.TaskPriority.values.firstWhere(
          (p) => p.value == draft.priority,
          orElse: () => api.TaskPriority.normal,
        ),
        subjectIds: draft.subjectIds.isEmpty ? null : draft.subjectIds,
        notes: draft.notes,
      ),
    );
    final task = response.data?.data;
    if (task == null) {
      throw const TaskRepositoryException('创建任务失败');
    }
    return _map(task);
  }

  @override
  Future<CareTaskItem> completeTask(CareTaskItem task, {String? notes}) async {
    final pending = task.pendingSubjectIds;
    final subjects = pending.isNotEmpty
        ? pending
        : (task.subjectIds.isNotEmpty
              ? task.subjectIds
              : <String>[task.targetId]);
    final response = await _api.completeTask(
      idempotencyKey: _key(),
      ifMatch: _etag(task.version),
      taskId: task.id,
      completeTaskRequest: api.CompleteTaskRequest(
        completedAt: DateTime.now().toUtc(),
        subjectResults: subjects
            .map(
              (id) => api.CompleteTaskRequestSubjectResultsInner(
                subjectId: id,
                status:
                    api.CompleteTaskRequestSubjectResultsInnerStatusEnum.completed,
              ),
            )
            .toList(),
        notes: notes,
      ),
    );
    final data = response.data?.data;
    final completed = data?.task;
    if (completed == null) {
      throw const TaskRepositoryException('完成任务失败');
    }
    return _map(completed);
  }

  @override
  Future<List<TaskReminderItem>> listReminders() async {
    // Backend reminder_delivery JSON (task_id/channel/status) differs from the
    // generated OpenAPI Reminder schema; parse raw payload for resilience.
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        '/reminders',
        queryParameters: const {'limit': 100},
      );
      final data = response.data?['data'];
      if (data is! List) return const <TaskReminderItem>[];
      return data
          .whereType<Map>()
          .map(
            (item) => TaskReminderItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return const <TaskReminderItem>[];
    }
  }
}
