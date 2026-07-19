class AssistantFact {
  const AssistantFact({
    required this.key,
    required this.label,
    required this.value,
    required this.source,
  });

  final String key;
  final String label;
  final String value;
  final String source;

  factory AssistantFact.fromJson(Map<String, dynamic> json) => AssistantFact(
    key: json['key'] as String? ?? '',
    label: json['label'] as String? ?? '',
    value: json['value'] as String? ?? '',
    source: json['source'] as String? ?? '',
  );
}

class AssistantAction {
  const AssistantAction({
    required this.type,
    required this.label,
    required this.summary,
    required this.requiresConfirmation,
    required this.payload,
  });

  final String type;
  final String label;
  final String summary;
  final bool requiresConfirmation;
  final Map<String, dynamic> payload;

  factory AssistantAction.fromJson(Map<String, dynamic> json) =>
      AssistantAction(
        type: json['type'] as String? ?? '',
        label: json['label'] as String? ?? '继续',
        summary: json['summary'] as String? ?? '',
        requiresConfirmation: json['requires_confirmation'] as bool? ?? false,
        payload: json['payload'] is Map
            ? Map<String, dynamic>.from(json['payload'] as Map)
            : const <String, dynamic>{},
      );
}

class AssistantAnswer {
  const AssistantAnswer({
    required this.answer,
    required this.intent,
    required this.mode,
    required this.facts,
    required this.disclaimer,
    this.actions = const <AssistantAction>[],
  });

  final String answer;
  final String intent;
  final String mode;
  final List<AssistantFact> facts;
  final String disclaimer;
  final List<AssistantAction> actions;

  factory AssistantAnswer.fromJson(Map<String, dynamic> json) {
    final facts = json['facts'];
    final actions = json['actions'];
    return AssistantAnswer(
      answer: json['answer'] as String? ?? '',
      intent: json['intent'] as String? ?? 'unknown',
      mode: json['mode'] as String? ?? 'rules',
      facts: facts is List
          ? facts
                .whereType<Map>()
                .map(
                  (e) => AssistantFact.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      disclaimer: json['disclaimer'] as String? ?? '',
      actions: actions is List
          ? actions
                .whereType<Map>()
                .map(
                  (value) => AssistantAction.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
                )
                .where((value) => value.type.isNotEmpty)
                .toList()
          : const <AssistantAction>[],
    );
  }
}

class AssistantCapabilities {
  const AssistantCapabilities({
    required this.intents,
    required this.modeDefault,
    required this.llmAvailable,
    required this.disclaimer,
  });

  final List<String> intents;
  final String modeDefault;
  final bool llmAvailable;
  final String disclaimer;

  factory AssistantCapabilities.fromJson(Map<String, dynamic> json) {
    final intents = json['intents'];
    return AssistantCapabilities(
      intents: intents is List
          ? intents.map((e) => e.toString()).toList()
          : const [],
      modeDefault: json['mode_default'] as String? ?? 'rules',
      llmAvailable: json['llm_available'] as bool? ?? false,
      disclaimer: json['disclaimer'] as String? ?? '',
    );
  }
}

class AssistantSnapshot {
  const AssistantSnapshot({
    this.organizationName = '我的熊舍',
    this.activeHamsters = 0,
    this.activeLitters = 0,
    this.enclosures = 0,
    this.openTasks = 0,
    this.overdueTasks = 0,
    this.gestatingPlans = 0,
    this.mediaBytes = 0,
    this.planCode = 'free',
  });

  final String organizationName;
  final int activeHamsters;
  final int activeLitters;
  final int enclosures;
  final int openTasks;
  final int overdueTasks;
  final int gestatingPlans;
  final double mediaBytes;
  final String planCode;
}

/// Local rules engine mirroring aicore.DetectIntent / AnswerFromSnapshot.
String detectAssistantIntent(String question) {
  final q = question.trim().toLowerCase();
  bool any(List<String> keys) => keys.any(q.contains);
  if (any(['帮助', '你能做什么', 'help', '能干什么', '怎么用'])) return 'help';
  if (any(['逾期', '过期', 'overdue'])) return 'overdue';
  if (any(['待办', '任务', '提醒', 'task', 'todo'])) return 'tasks';
  if (any(['繁育', '孕期', '配种', '窝次', 'breeding', 'litter'])) {
    return 'breeding';
  }
  if (any(['用量', '配额', '空间', '媒体', 'usage', 'quota'])) return 'usage';
  if (any(['套餐', '专业版', '免费版', '权益', 'plan', 'pro'])) return 'plan';
  if (any(['多少只', '在养', '仓鼠', 'hamster', '个体'])) return 'hamsters';
  if (any(['概况', '总览', '今天', '怎么样', 'overview', 'summary', '状态'])) {
    return 'overview';
  }
  if (q.isEmpty) return 'help';
  return 'unknown';
}

AssistantAnswer answerFromSnapshot(String question, AssistantSnapshot snap) {
  final intent = detectAssistantIntent(question);
  final org = snap.organizationName.trim().isEmpty
      ? ''
      : '${snap.organizationName}：';
  final plan = snap.planCode == 'pro' ? '专业版' : '免费版';
  String body;
  switch (intent) {
    case 'help':
      body = '我可以帮你查看在养数量、待办与逾期任务、繁育概况、用量和套餐。例如「现在有多少只在养？」「有没有逾期任务？」';
    case 'hamsters':
      body = '$org当前在养仓鼠约 ${snap.activeHamsters} 只，笼盒 ${snap.enclosures} 个。';
    case 'tasks':
      body = '$org未完成任务 ${snap.openTasks} 项，其中逾期 ${snap.overdueTasks} 项。';
    case 'overdue':
      body = snap.overdueTasks == 0
          ? '$org目前没有逾期任务。'
          : '$org有 ${snap.overdueTasks} 项逾期任务，建议优先处理。';
    case 'breeding':
      body = '$org活跃窝次 ${snap.activeLitters}，繁育中计划约 ${snap.gestatingPlans}。';
    case 'usage':
      body = '$org媒体占用约 ${_fmtBytes(snap.mediaBytes)}，套餐 $plan。';
    case 'plan':
      body = '$org当前套餐为 $plan。可在「套餐与权益」查看可用范围。';
    case 'overview':
      body =
          '$org概况：在养 ${snap.activeHamsters}、笼盒 ${snap.enclosures}、窝次 ${snap.activeLitters}、待办 ${snap.openTasks}（逾期 ${snap.overdueTasks}）、繁育计划 ${snap.gestatingPlans}、套餐 $plan。';
    default:
      body =
          '我按现有数据理解可能不够准确。当前概况：在养 ${snap.activeHamsters}、待办 ${snap.openTasks}（逾期 ${snap.overdueTasks}）。';
  }
  return AssistantAnswer(
    answer: body,
    intent: intent,
    mode: 'rules',
    facts: [
      AssistantFact(
        key: 'active_hamsters',
        label: '在养',
        value: '${snap.activeHamsters}',
        source: 'local',
      ),
      AssistantFact(
        key: 'open_tasks',
        label: '待办',
        value: '${snap.openTasks}',
        source: 'local',
      ),
      AssistantFact(
        key: 'overdue_tasks',
        label: '逾期',
        value: '${snap.overdueTasks}',
        source: 'local',
      ),
    ],
    disclaimer: '回答只会读取已同步记录，不会直接修改数据。',
  );
}

String _fmtBytes(double v) {
  if (v < 1024) return '${v.toStringAsFixed(0)} B';
  if (v < 1024 * 1024) return '${(v / 1024).toStringAsFixed(1)} KB';
  if (v < 1024 * 1024 * 1024) {
    return '${(v / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(v / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
