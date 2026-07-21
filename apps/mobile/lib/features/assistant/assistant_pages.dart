import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import 'assistant_controller.dart';
import 'assistant_models.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_controller.dart';
import '../i2/i2_models.dart';
import '../tasks/task_controller.dart';
import '../tasks/task_models.dart';

/// 问问管家：读取熊舍现状、回答经营问题，并连接到可执行的业务入口。
class AssistantPage extends StatefulWidget {
  const AssistantPage({
    super.key,
    required this.controller,
    this.i2Controller,
    this.taskController,
    this.onOpenTasks,
    this.onCreateTask,
    this.onOpenHamsters,
    this.onOpenHamsterDetail,
    this.onOpenEnclosures,
    this.onOpenEnclosureDetail,
    this.onOpenGrowth,
    this.onOpenDataCenter,
    this.onOpenTaskDraft,
  });

  final AssistantController controller;
  final I2Controller? i2Controller;
  final TaskController? taskController;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onCreateTask;
  final VoidCallback? onOpenHamsters;
  final ValueChanged<I2Hamster>? onOpenHamsterDetail;
  final VoidCallback? onOpenEnclosures;
  final ValueChanged<I2Enclosure>? onOpenEnclosureDetail;
  final VoidCallback? onOpenGrowth;
  final VoidCallback? onOpenDataCenter;
  final ValueChanged<CreateCareTaskDraft>? onOpenTaskDraft;

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _input = TextEditingController();
  final _presets = const [
    '现在有多少只在养？',
    '有没有逾期任务？',
    '繁育概况怎么样？',
    '幼崽护理要注意什么？',
    '你能做什么？',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.refreshCapabilities();
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _ask([String? text]) async {
    final q = text ?? _input.text;
    FocusManager.instance.primaryFocus?.unfocus();
    final ok = await widget.controller.ask(q);
    if (!mounted) return;
    if (ok) _input.clear();
    final message = widget.controller.lastMessage;
    if (!ok && message != null) {
      showIosMessage(context, message);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final asking =
            widget.controller.askingState.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('问问管家'),
            actions: [
              if (widget.controller.turns.isNotEmpty)
                IconButton(
                  key: const Key('assistant-clear'),
                  tooltip: '清空对话',
                  onPressed: asking
                      ? null
                      : () {
                          widget.controller.clear();
                          setState(() {});
                        },
                  icon: const Icon(CupertinoIcons.trash),
                ),
            ],
          ),
          body: Column(
            children: [
              _AgentOverview(
                i2Controller: widget.i2Controller,
                taskController: widget.taskController,
                onOpenTasks: widget.onOpenTasks,
                onCreateTask: widget.onCreateTask,
                onOpenEnclosures: widget.onOpenEnclosures,
                onOpenGrowth: widget.onOpenGrowth,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _AssistantAvailabilityBanner(
                  state: widget.controller.capabilitiesState,
                  onRetry: widget.controller.refreshCapabilities,
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    for (final p in _presets) ...[
                      ActionChip(
                        key: Key('assistant-preset-$p'),
                        label: Text(p),
                        backgroundColor: ScolvPalette.of(
                          context,
                        ).secondaryGroupedBackground,
                        side: BorderSide(
                          color: ScolvPalette.of(context).opaqueSeparator,
                          width: IosMetrics.hairline,
                        ),
                        onPressed: asking ? null : () => _ask(p),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              if (widget.controller.askingState.status == I2AsyncStatus.error)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: IosBanner(
                    key: const Key('assistant-question-error'),
                    icon: CupertinoIcons.exclamationmark_circle,
                    color: IosColors.systemRed,
                    text: widget.controller.lastMessage ?? '这次没有查到结果，请稍后重试。',
                    actionLabel: _input.text.trim().isEmpty ? null : '重试',
                    onAction: _input.text.trim().isEmpty || asking
                        ? null
                        : () => _ask(),
                  ),
                ),
              Expanded(
                child: widget.controller.turns.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Center(
                          child: BearEmptyCard(
                            title: '想查什么，直接问我',
                            subtitle: '可以从上方快捷问题开始，也可以输入仓鼠、任务或繁育问题。',
                            illustration: BearAssets.emptyList,
                            mood: BearMood.happy,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: widget.controller.turns.length,
                        itemBuilder: (context, index) {
                          final turn = widget.controller.turns[index];
                          final executableActions = _executableActions(
                            turn.answer.actions,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              key: Key('assistant-turn-$index'),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: ScolvPalette.of(
                                  context,
                                ).secondaryGroupedBackground,
                                borderRadius: BorderRadius.circular(
                                  IosMetrics.continuousRadius,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '问：${turn.question}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    turn.answer.answer,
                                    key: Key('assistant-answer-$index'),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                  if (turn.answer.facts.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      '相关数据',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        for (final fact in turn.answer.facts)
                                          Chip(
                                            visualDensity:
                                                VisualDensity.compact,
                                            label: Text(
                                              '${fact.label} ${fact.value}',
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  Text(
                                    '建议',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _recommendationFor(turn.answer.intent),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  if (executableActions.isNotEmpty ||
                                      _hasTurnActions(turn.answer.intent)) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      '操作',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (executableActions.isNotEmpty)
                                      Column(
                                        children: [
                                          for (final action
                                              in executableActions) ...[
                                            _AgentProposalCard(
                                              action: action,
                                              onTap: () =>
                                                  _handleAgentAction(action),
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ],
                                      )
                                    else
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _turnActions(
                                          turn.answer.intent,
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('assistant-input'),
                          controller: _input,
                          decoration: const InputDecoration(
                            hintText: '例如：现在有多少只在养？',
                            isDense: true,
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: asking ? null : (_) => _ask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        key: const Key('assistant-send'),
                        onPressed: asking ? null : () => _ask(),
                        child: asking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('发送'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _recommendationFor(String intent) => switch (intent) {
    'overdue' => '先处理逾期任务；如需新增跟进，可先打开任务草案并确认后写入。',
    'tasks' => '进入任务列表核对优先级，新增任务会先进入编辑确认页。',
    'hamsters' => '打开仓鼠档案查看个体状态、体重与头像资料。',
    'breeding' => '结合笼舍入住与繁育记录核对下一步安排。',
    _ => '先核对相关记录，再决定是否进入业务页面处理。',
  };

  List<AssistantAction> _executableActions(List<AssistantAction> actions) =>
      actions.where(_canExecuteAction).toList(growable: false);

  bool _canExecuteAction(AssistantAction action) {
    switch (action.type) {
      case 'task_draft':
        return widget.onOpenTaskDraft != null &&
            _payloadText(action, 'target_type').isNotEmpty &&
            _payloadText(action, 'target_id').isNotEmpty;
      case 'create_task':
      case 'complete_task':
      case 'create_weight_record':
      case 'create_hamster':
      case 'update_hamster':
      case 'create_enclosure':
        return action.requiresConfirmation &&
            (action.actionId?.trim().isNotEmpty ?? false);
      case 'open_hamster':
        final id = _payloadText(action, 'hamster_id');
        return widget.onOpenHamsterDetail != null &&
            id.isNotEmpty &&
            (widget.i2Controller?.snapshotState.data?.hamsters ??
                    const <I2Hamster>[])
                .any((value) => value.id == id);
      case 'open_enclosure':
        final id = _payloadText(action, 'enclosure_id');
        return widget.onOpenEnclosureDetail != null &&
            id.isNotEmpty &&
            (widget.i2Controller?.snapshotState.data?.enclosures ??
                    const <I2Enclosure>[])
                .any((value) => value.id == id);
      case 'open_tasks':
        return widget.onOpenTasks != null;
      case 'open_data_center':
        return widget.onOpenDataCenter != null;
      case 'open_growth':
        return widget.onOpenGrowth != null;
      default:
        return false;
    }
  }

  String _payloadText(AssistantAction action, String key) =>
      action.payload[key]?.toString().trim() ?? '';

  bool get _canOpenHamsterRecords {
    final hasDetailTarget =
        widget.onOpenHamsterDetail != null &&
        (widget.i2Controller?.snapshotState.data?.hamsters.isNotEmpty ?? false);
    return widget.onOpenHamsters != null || hasDetailTarget;
  }

  bool get _canOpenEnclosureRecords {
    final hasDetailTarget =
        widget.onOpenEnclosureDetail != null &&
        (widget.i2Controller?.snapshotState.data?.enclosures.isNotEmpty ??
            false);
    return widget.onOpenEnclosures != null || hasDetailTarget;
  }

  bool _hasTurnActions(String intent) => switch (intent) {
    'tasks' ||
    'overdue' => widget.onOpenTasks != null || widget.onCreateTask != null,
    'hamsters' => _canOpenHamsterRecords,
    'breeding' => _canOpenEnclosureRecords,
    _ => false,
  };

  List<Widget> _turnActions(String intent) => switch (intent) {
    'tasks' || 'overdue' => [
      if (widget.onOpenTasks != null)
        _AgentAction(
          icon: CupertinoIcons.checkmark_square,
          label: '打开任务',
          onTap: widget.onOpenTasks!,
        ),
      if (widget.onCreateTask != null)
        _AgentAction(
          icon: CupertinoIcons.add_circled,
          label: '新建任务',
          onTap: widget.onCreateTask!,
        ),
    ],
    'hamsters' => [
      if (_canOpenHamsterRecords)
        _AgentAction(
          icon: CupertinoIcons.paw,
          label:
              widget.onOpenHamsterDetail != null &&
                  (widget
                          .i2Controller
                          ?.snapshotState
                          .data
                          ?.hamsters
                          .isNotEmpty ??
                      false)
              ? '打开仓鼠详情'
              : '打开仓鼠列表',
          onTap: _chooseHamsterDetail,
        ),
    ],
    'breeding' => [
      if (_canOpenEnclosureRecords)
        _AgentAction(
          icon: CupertinoIcons.square_grid_2x2,
          label:
              widget.onOpenEnclosureDetail != null &&
                  (widget
                          .i2Controller
                          ?.snapshotState
                          .data
                          ?.enclosures
                          .isNotEmpty ??
                      false)
              ? '打开笼盒详情'
              : '打开笼舍列表',
          onTap: _chooseEnclosureDetail,
        ),
    ],
    _ => const <Widget>[],
  };

  void _handleAgentAction(AssistantAction action) {
    switch (action.type) {
      case 'create_task':
      case 'complete_task':
      case 'create_weight_record':
      case 'create_hamster':
      case 'update_hamster':
      case 'create_enclosure':
        _confirmServerAction(action);
        return;
      case 'task_draft':
        final targetType = action.payload['target_type']?.toString() ?? '';
        final targetId = action.payload['target_id']?.toString() ?? '';
        if (targetType.isEmpty || targetId.isEmpty) {
          showIosMessage(context, '任务草案缺少目标，请重新描述要处理的对象');
          return;
        }
        final scheduledAt =
            DateTime.tryParse(
              action.payload['scheduled_at']?.toString() ?? '',
            ) ??
            DateTime.now().add(const Duration(hours: 1));
        final callback = widget.onOpenTaskDraft;
        if (callback == null) {
          showIosMessage(context, '当前页面暂未接入任务确认入口');
          return;
        }
        callback(
          CreateCareTaskDraft(
            taskType: action.payload['task_type']?.toString() ?? 'custom',
            targetType: targetType,
            targetId: targetId,
            scheduledAt: scheduledAt,
            priority: action.payload['priority']?.toString() ?? 'normal',
            title: _optionalPayloadText(action.payload['title']),
            notes: _optionalPayloadText(action.payload['notes']),
          ),
        );
        return;
      case 'open_hamster':
        final id = action.payload['hamster_id']?.toString() ?? '';
        final hamster = widget.i2Controller?.snapshotState.data?.hamsters
            .where((value) => value.id == id)
            .firstOrNull;
        if (hamster == null || widget.onOpenHamsterDetail == null) {
          showIosMessage(context, '仓鼠档案已变化，请刷新后重试');
          return;
        }
        widget.onOpenHamsterDetail!(hamster);
        return;
      case 'open_enclosure':
        final id = action.payload['enclosure_id']?.toString() ?? '';
        final enclosure = widget.i2Controller?.snapshotState.data?.enclosures
            .where((value) => value.id == id)
            .firstOrNull;
        if (enclosure == null || widget.onOpenEnclosureDetail == null) {
          showIosMessage(context, '笼盒资料已变化，请刷新后重试');
          return;
        }
        widget.onOpenEnclosureDetail!(enclosure);
        return;
      case 'open_tasks':
        widget.onOpenTasks?.call();
        return;
      case 'open_data_center':
        widget.onOpenDataCenter?.call();
        return;
      case 'open_growth':
        widget.onOpenGrowth?.call();
        return;
      default:
        return;
    }
  }

  Future<void> _confirmServerAction(AssistantAction action) async {
    final summary = action.summary.isEmpty ? action.label : action.summary;
    final go = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(action.label),
        content: Text(summary),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确认执行'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (go != true) {
      final cancelled = await widget.controller.cancelAction(action);
      if (!mounted) return;
      final msg = widget.controller.lastMessage;
      if (msg != null) showIosMessage(context, msg);
      if (cancelled) setState(() {});
      return;
    }
    final ok = await widget.controller.confirmAction(action);
    if (!mounted) return;
    final msg = widget.controller.lastMessage;
    if (msg != null) showIosMessage(context, msg);
    if (ok) setState(() {});
  }

  String? _optionalPayloadText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  Future<void> _chooseHamsterDetail() async {
    final values =
        widget.i2Controller?.snapshotState.data?.hamsters ??
        const <I2Hamster>[];
    if (values.isEmpty || widget.onOpenHamsterDetail == null) {
      widget.onOpenHamsters?.call();
      return;
    }
    if (values.length == 1) {
      widget.onOpenHamsterDetail!(values.single);
      return;
    }
    final selected = await showCupertinoModalPopup<I2Hamster>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择仓鼠'),
        actions: [
          for (final hamster in values.take(20))
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context, hamster),
              child: Text(hamster.displayName),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
    if (selected != null) widget.onOpenHamsterDetail!(selected);
  }

  Future<void> _chooseEnclosureDetail() async {
    final values =
        widget.i2Controller?.snapshotState.data?.enclosures ??
        const <I2Enclosure>[];
    if (values.isEmpty || widget.onOpenEnclosureDetail == null) {
      widget.onOpenEnclosures?.call();
      return;
    }
    if (values.length == 1) {
      widget.onOpenEnclosureDetail!(values.single);
      return;
    }
    final selected = await showCupertinoModalPopup<I2Enclosure>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('选择笼盒'),
        actions: [
          for (final enclosure in values.take(20))
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context, enclosure),
              child: Text(enclosure.code),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
    if (selected != null) widget.onOpenEnclosureDetail!(selected);
  }
}

class _AssistantAvailabilityBanner extends StatelessWidget {
  const _AssistantAvailabilityBanner({
    required this.state,
    required this.onRetry,
  });

  final I2AsyncState<AssistantCapabilities> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case I2AsyncStatus.idle:
      case I2AsyncStatus.loading:
        return IosBanner(
          key: const Key('assistant-capabilities-loading'),
          icon: CupertinoIcons.sparkles,
          color: ScolvPalette.of(context).accent,
          text: '正在准备熊舍记录，稍后就可以开始提问。',
        );
      case I2AsyncStatus.error:
      case I2AsyncStatus.conflict:
        return IosBanner(
          key: const Key('assistant-capabilities-error'),
          icon: CupertinoIcons.exclamationmark_circle,
          color: IosColors.systemRed,
          text: state.message ?? '问答服务暂时没有准备好，请稍后重试。',
          actionLabel: '重试',
          onAction: onRetry,
        );
      case I2AsyncStatus.data:
      case I2AsyncStatus.empty:
        return IosBanner(
          key: const Key('assistant-read-only-note'),
          icon: CupertinoIcons.lock_shield,
          color: ScolvPalette.of(context).accent,
          text: '回答会读取已同步记录。需要修改数据时，我会先打开对应页面请你确认。',
        );
    }
  }
}

class _AgentOverview extends StatelessWidget {
  const _AgentOverview({
    this.i2Controller,
    this.taskController,
    this.onOpenTasks,
    this.onCreateTask,
    this.onOpenEnclosures,
    this.onOpenGrowth,
  });

  final I2Controller? i2Controller;
  final TaskController? taskController;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onCreateTask;
  final VoidCallback? onOpenEnclosures;
  final VoidCallback? onOpenGrowth;

  @override
  Widget build(BuildContext context) {
    final snapshot = i2Controller?.snapshotState.data;
    final hamsterCount = snapshot?.hamsters.length ?? 0;
    final enclosureCount = snapshot?.enclosures.length ?? 0;
    final openTasks = taskController?.openCount ?? 0;
    final overdueTasks = taskController?.overdueCount ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ScolvPalette.of(context).accentSoft,
              borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
              border: Border.all(
                color: ScolvPalette.of(context).accent.withValues(alpha: 0.18),
              ),
            ),
            child: Row(
              children: [
                const BearMascot(size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '问问管家',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '帮你读懂记录，并把下一步带到正确页面。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ScolvPalette.of(context).secondaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CupertinoIcons.sparkles,
                  color: ScolvPalette.of(context).accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 74,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _AgentMetric(label: '在养仓鼠', value: '$hamsterCount 只'),
                _AgentMetric(label: '笼盒', value: '$enclosureCount 个'),
                _AgentMetric(
                  label: overdueTasks == 0 ? '待办任务' : '逾期任务',
                  value: '${overdueTasks == 0 ? openTasks : overdueTasks} 项',
                  danger: overdueTasks > 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onCreateTask != null)
                _AgentAction(
                  icon: CupertinoIcons.add_circled,
                  label: '添加任务',
                  onTap: onCreateTask!,
                ),
              if (onOpenTasks != null)
                _AgentAction(
                  icon: CupertinoIcons.checkmark_square,
                  label: '任务列表',
                  onTap: onOpenTasks!,
                ),
              if (onOpenEnclosures != null)
                _AgentAction(
                  icon: CupertinoIcons.square_grid_2x2,
                  label: '笼舍数据',
                  onTap: onOpenEnclosures!,
                ),
              if (onOpenGrowth != null)
                _AgentAction(
                  icon: CupertinoIcons.bolt,
                  label: '获客工作台',
                  onTap: onOpenGrowth!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AgentMetric extends StatelessWidget {
  const _AgentMetric({
    required this.label,
    required this.value,
    this.danger = false,
  });

  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) => Container(
    width: 124,
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 8),
    decoration: BoxDecoration(
      color: ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      border: Border.all(color: ScolvPalette.of(context).separator),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: danger
                ? IosColors.systemRed
                : ScolvPalette.of(context).accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _AgentAction extends StatelessWidget {
  const _AgentAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 17),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: ScolvPalette.of(context).accent,
      side: BorderSide(
        color: ScolvPalette.of(context).accent.withValues(alpha: 0.32),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    ),
  );
}

class _AgentProposalCard extends StatelessWidget {
  const _AgentProposalCard({required this.action, required this.onTap});

  final AssistantAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: ScolvPalette.of(context).groupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      border: Border.all(color: ScolvPalette.of(context).separator),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          action.type == 'task_draft'
              ? CupertinoIcons.doc_text
              : CupertinoIcons.arrow_right_circle,
          color: ScolvPalette.of(context).accent,
          size: 21,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      action.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (action.requiresConfirmation)
                    Text(
                      '需确认',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ScolvPalette.of(context).accent,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                action.summary,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  key: Key('assistant-action-${action.type}'),
                  onPressed: onTap,
                  child: Text(action.requiresConfirmation ? '查看并确认' : '打开'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
