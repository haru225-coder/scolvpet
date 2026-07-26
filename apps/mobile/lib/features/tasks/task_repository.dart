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

  /// Cancels a task that will never be carried out. [reason] is mandatory.
  Future<CareTaskItem> cancelTask(CareTaskItem task, {required String reason});

  /// Undoes a completion or cancellation, returning the task to pending so it
  /// can be redone. [reason] is mandatory.
  Future<CareTaskItem> reopenTask(CareTaskItem task, {required String reason});

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
                status: api
                    .CompleteTaskRequestSubjectResultsInnerStatusEnum
                    .completed,
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
  Future<CareTaskItem> cancelTask(
    CareTaskItem task, {
    required String reason,
  }) async {
    final response = await _api.cancelTask(
      idempotencyKey: _key(),
      ifMatch: _etag(task.version),
      taskId: task.id,
      taskCorrectionRequest: api.TaskCorrectionRequest(reason: reason),
    );
    final cancelled = response.data?.data;
    if (cancelled == null) {
      throw const TaskRepositoryException('取消任务失败');
    }
    return _map(cancelled);
  }

  @override
  Future<CareTaskItem> reopenTask(
    CareTaskItem task, {
    required String reason,
  }) async {
    final response = await _api.reopenTask(
      idempotencyKey: _key(),
      ifMatch: _etag(task.version),
      taskId: task.id,
      taskCorrectionRequest: api.TaskCorrectionRequest(reason: reason),
    );
    final reopened = response.data?.data;
    if (reopened == null) {
      throw const TaskRepositoryException('撤销任务状态失败');
    }
    return _map(reopened);
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
            (item) =>
                TaskReminderItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return const <TaskReminderItem>[];
    }
  }
}
