import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import '../tasks/task_models.dart';
import '../tasks/task_repository.dart';
import 'health_models.dart';
import 'health_repository.dart';

class HealthController extends ChangeNotifier {
  HealthController({required this.repository, this.taskRepository});

  final HealthRepository repository;
  final TaskRepository? taskRepository;

  I2AsyncState<List<HealthRecordItem>> listState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? hamsterId;
  String? lastMessage;
  CareTaskItem? lastCreatedTask;
  HealthRecordItem? lastCreatedRecord;
  String? lastFollowUpTaskError;
  bool _refreshing = false;
  bool _disposed = false;

  bool get isBusy => actionState.status == I2AsyncStatus.loading;
  bool get isRefreshing => _refreshing;

  bool get hadPartialSuccess =>
      lastCreatedRecord != null && lastFollowUpTaskError != null;

  Future<void> loadForHamster(String id) async {
    hamsterId = id;
    _refreshing = true;
    // Keep previous list visible while refreshing to avoid flicker.
    if (listState.data == null) {
      listState = const I2AsyncState.loading();
    }
    _notifyIfActive();
    try {
      final records = await repository.listRecords(hamsterId: id);
      listState = records.isEmpty
          ? const I2AsyncState.empty(message: '暂无健康记录')
          : I2AsyncState.data(records);
    } catch (error) {
      listState = I2AsyncState.error(healthErrorMessage(error));
    } finally {
      _refreshing = false;
    }
    _notifyIfActive();
  }

  Future<bool> create(HealthRecordDraft draft) async {
    if (isBusy) {
      lastMessage = '正在保存上一条健康记录，请稍候';
      _notifyIfActive();
      return false;
    }
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    lastCreatedTask = null;
    lastCreatedRecord = null;
    lastFollowUpTaskError = null;
    _notifyIfActive();
    try {
      final created = await repository.createRecord(draft);
      lastCreatedRecord = created;
      final current = List<HealthRecordItem>.from(
        listState.data ?? const <HealthRecordItem>[],
      )..insert(0, created);
      listState = I2AsyncState.data(current);

      if (draft.createFollowUpTask && draft.followUpAt != null) {
        if (taskRepository == null) {
          lastFollowUpTaskError = '护理任务服务暂未接入';
        }
        final targetId = draft.hamsterId ?? draft.litterId ?? '';
        final targetType = draft.hamsterId != null ? 'hamster' : 'litter';
        if (targetId.isNotEmpty && taskRepository != null) {
          try {
            lastCreatedTask = await taskRepository!.createTask(
              CreateCareTaskDraft(
                taskType: draft.type == 'medication'
                    ? 'medication'
                    : 'follow_up',
                targetType: targetType,
                targetId: targetId,
                scheduledAt: draft.followUpAt!,
                priority:
                    draft.severity == 'critical' || draft.severity == 'high'
                    ? 'high'
                    : 'normal',
                title: '${healthTypeLabel(draft.type)}复查',
                subjectIds: draft.hamsterId == null
                    ? const <String>[]
                    : [draft.hamsterId!],
                notes: draft.notes,
              ),
            );
          } catch (error) {
            lastFollowUpTaskError = taskRepositoryErrorMessage(error);
          }
        }
      }

      actionState = const I2AsyncState.data(null);
      lastMessage = hadPartialSuccess
          ? '健康记录已保存，复查任务未创建，请到护理任务中补建'
          : lastCreatedTask == null
          ? '已保存健康记录'
          : '已保存健康记录，并创建复查任务';
      _notifyIfActive();
      return true;
    } catch (error) {
      final message = healthErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      _notifyIfActive();
      return false;
    }
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
