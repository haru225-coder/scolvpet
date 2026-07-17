import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import '../tasks/task_models.dart';
import '../tasks/task_repository.dart';
import 'health_models.dart';
import 'health_repository.dart';

class HealthController extends ChangeNotifier {
  HealthController({
    required this.repository,
    this.taskRepository,
  });

  final HealthRepository repository;
  final TaskRepository? taskRepository;

  I2AsyncState<List<HealthRecordItem>> listState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? hamsterId;
  String? lastMessage;
  CareTaskItem? lastCreatedTask;

  Future<void> loadForHamster(String id) async {
    hamsterId = id;
    listState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final records = await repository.listRecords(hamsterId: id);
      listState = records.isEmpty
          ? const I2AsyncState.empty(message: '暂无健康记录')
          : I2AsyncState.data(records);
    } catch (error) {
      listState = I2AsyncState.error(healthErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> create(HealthRecordDraft draft) async {
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    lastCreatedTask = null;
    notifyListeners();
    try {
      final created = await repository.createRecord(draft);
      final current = List<HealthRecordItem>.from(
        listState.data ?? const <HealthRecordItem>[],
      )..insert(0, created);
      listState = I2AsyncState.data(current);

      if (draft.createFollowUpTask &&
          draft.followUpAt != null &&
          taskRepository != null) {
        final targetId = draft.hamsterId ?? draft.litterId ?? '';
        final targetType = draft.hamsterId != null ? 'hamster' : 'litter';
        if (targetId.isNotEmpty) {
          lastCreatedTask = await taskRepository!.createTask(
            CreateCareTaskDraft(
              taskType: draft.type == 'medication' ? 'medication' : 'follow_up',
              targetType: targetType,
              targetId: targetId,
              scheduledAt: draft.followUpAt!,
              priority: draft.severity == 'critical' || draft.severity == 'high'
                  ? 'high'
                  : 'normal',
              title: '${healthTypeLabel(draft.type)}复查',
              subjectIds: draft.hamsterId == null
                  ? const <String>[]
                  : [draft.hamsterId!],
              notes: draft.notes,
            ),
          );
        }
      }

      actionState = const I2AsyncState.data(null);
      lastMessage = lastCreatedTask == null
          ? '已保存健康记录'
          : '已保存健康记录，并创建复查任务';
      notifyListeners();
      return true;
    } catch (error) {
      final message = healthErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
