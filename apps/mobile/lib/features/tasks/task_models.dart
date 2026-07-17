/// Care-task view models for T-P0-05 (client side).
class CareTaskItem {
  const CareTaskItem({
    required this.id,
    required this.taskType,
    required this.targetType,
    required this.targetId,
    this.title,
    required this.scheduledAt,
    required this.priority,
    required this.state,
    this.subjectIds = const <String>[],
    this.completedSubjectIds = const <String>[],
    this.stageTotal = 0,
    this.stageDone = 0,
    this.notes,
    required this.version,
  });

  final String id;
  final String taskType;
  final String targetType;
  final String targetId;
  final String? title;
  final DateTime scheduledAt;
  final String priority;
  final String state;
  final List<String> subjectIds;
  final List<String> completedSubjectIds;
  final int stageTotal;
  final int stageDone;
  final String? notes;
  final int version;

  bool get isOpen {
    switch (state) {
      case 'completed':
      case 'cancelled':
      case 'dismissed':
      case 'closed':
      case 'superseded':
        return false;
      default:
        // pending / in_progress / snoozed / open / scheduled
        return true;
    }
  }

  bool get isOverdue =>
      isOpen && scheduledAt.toUtc().isBefore(DateTime.now().toUtc());

  String get displayTitle {
    final t = title?.trim();
    if (t != null && t.isNotEmpty) return t;
    return taskTypeLabel(taskType);
  }

  List<String> get pendingSubjectIds {
    final done = completedSubjectIds.toSet();
    return subjectIds.where((id) => !done.contains(id)).toList();
  }

  /// Whether this task is about a given hamster (target or subject).
  bool relatesToHamster(String hamsterId) {
    if (hamsterId.isEmpty) return false;
    if (targetType == 'hamster' && targetId == hamsterId) return true;
    return subjectIds.contains(hamsterId);
  }

  static List<CareTaskItem> openForHamster(
    Iterable<CareTaskItem> tasks,
    String hamsterId,
  ) {
    return tasks
        .where((t) => t.isOpen && t.relatesToHamster(hamsterId))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  CareTaskItem copyWith({
    String? state,
    int? version,
    int? stageDone,
    List<String>? completedSubjectIds,
    DateTime? scheduledAt,
    String? title,
    String? notes,
  }) {
    return CareTaskItem(
      id: id,
      taskType: taskType,
      targetType: targetType,
      targetId: targetId,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      priority: priority,
      state: state ?? this.state,
      subjectIds: subjectIds,
      completedSubjectIds: completedSubjectIds ?? this.completedSubjectIds,
      stageTotal: stageTotal,
      stageDone: stageDone ?? this.stageDone,
      notes: notes ?? this.notes,
      version: version ?? this.version,
    );
  }

  factory CareTaskItem.fromJson(Map<String, dynamic> json) {
    return CareTaskItem(
      id: json['id'] as String? ?? '',
      taskType: json['task_type'] as String? ?? 'custom',
      targetType: json['target_type'] as String? ?? 'custom',
      targetId: json['target_id'] as String? ?? '',
      title: json['title'] as String?,
      scheduledAt:
          DateTime.tryParse(json['scheduled_at'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      priority: json['priority'] as String? ?? 'normal',
      state: json['state'] as String? ?? 'pending',
      subjectIds: ((json['subject_ids'] as List?) ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(),
      completedSubjectIds:
          ((json['completed_subject_ids'] as List?) ?? const <dynamic>[])
              .map((e) => e.toString())
              .toList(),
      stageTotal: (json['stage_total'] as num?)?.toInt() ?? 0,
      stageDone: (json['stage_done'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'task_type': taskType,
    'target_type': targetType,
    'target_id': targetId,
    'title': title,
    'scheduled_at': scheduledAt.toIso8601String(),
    'priority': priority,
    'state': state,
    'subject_ids': subjectIds,
    'completed_subject_ids': completedSubjectIds,
    'stage_total': stageTotal,
    'stage_done': stageDone,
    'notes': notes,
    'version': version,
  };
}

class TaskReminderItem {
  const TaskReminderItem({
    required this.id,
    required this.taskId,
    required this.channel,
    required this.status,
    required this.scheduledAt,
    this.dedupeKey,
  });

  final String id;
  final String taskId;
  final String channel;
  final String status;
  final DateTime scheduledAt;
  final String? dedupeKey;

  factory TaskReminderItem.fromJson(Map<String, dynamic> json) {
    return TaskReminderItem(
      id: json['id'] as String? ?? '',
      taskId: (json['task_id'] ?? json['care_task_id']) as String? ?? '',
      channel: json['channel'] as String? ?? 'local',
      status: json['status'] as String? ?? 'pending',
      scheduledAt:
          DateTime.tryParse(json['scheduled_at'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      dedupeKey: json['dedupe_key'] as String?,
    );
  }
}

class CreateCareTaskDraft {
  const CreateCareTaskDraft({
    required this.taskType,
    required this.targetType,
    required this.targetId,
    required this.scheduledAt,
    this.priority = 'normal',
    this.title,
    this.subjectIds = const <String>[],
    this.notes,
  });

  final String taskType;
  final String targetType;
  final String targetId;
  final DateTime scheduledAt;
  final String priority;
  final String? title;
  final List<String> subjectIds;
  final String? notes;
}

String taskTypeLabel(String type) {
  return switch (type) {
    'pair_prep' => '配种准备',
    'pairing_timeout' => '合笼超时',
    'separate_now' => '立即分笼',
    'gestation_window' ||
    'gestation_window_open' ||
    'gestation_window_close' => '孕期窗口',
    'no_birth_review' => '未产仔复核',
    'litter_observation' => '窝仔观察',
    'pup_weight_check' => '幼崽称重',
    'pup_weight_drop' => '幼崽掉重',
    'weaning' || 'weaning_due' => '断奶',
    'sex_separation' || 'sex_separation_due' => '分性分笼',
    'sex_recheck' => '分性复核',
    'profile_creation' || 'profile_creation_due' => '个体建档',
    'enclosure_cleaning' || 'cleaning' => '笼盒清洁',
    'medication' => '用药',
    'follow_up' => '随访',
    'custom' => '自定义任务',
    _ => type,
  };
}

String taskPriorityLabel(String priority) {
  return switch (priority) {
    'low' => '低',
    'high' => '高',
    'urgent' || 'critical' => '紧急',
    _ => '普通',
  };
}

String taskStateLabel(String state) {
  return switch (state) {
    'open' || 'pending' || 'scheduled' => '待办',
    'in_progress' => '进行中',
    'completed' => '已完成',
    'cancelled' || 'dismissed' || 'closed' => '已关闭',
    'overdue' => '逾期',
    _ => state,
  };
}
