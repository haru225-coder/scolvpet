import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'task_controller.dart';
import 'task_models.dart';

/// Open care tasks list with one-tap complete (T-P0-05).
class TaskListPage extends StatefulWidget {
  const TaskListPage({
    super.key,
    required this.controller,
    this.canWrite = true,
    this.offline = false,
    this.organizationId,
    this.hamsters = const <I2Hamster>[],
    this.enclosures = const <I2Enclosure>[],
  });

  final TaskController controller;
  final bool canWrite;
  final bool offline;
  final String? organizationId;
  final List<I2Hamster> hamsters;
  final List<I2Enclosure> enclosures;

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String? _completingTaskId;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (widget.controller.listState.status == I2AsyncStatus.loading ||
        widget.controller.actionState.status == I2AsyncStatus.loading) {
      return;
    }
    await widget.controller.refresh();
  }

  Future<void> _complete(CareTaskItem task) async {
    if (!widget.canWrite || widget.offline) return;
    if (widget.controller.actionState.status == I2AsyncStatus.loading) return;
    setState(() => _completingTaskId = task.id);
    final ok = await widget.controller.complete(task);
    if (!mounted) return;
    setState(() => _completingTaskId = null);
    final message = widget.controller.lastMessage;
    if (message != null) {
      showIosMessage(context, message);
    }
    if (ok) setState(() {});
  }

  Future<void> _create() async {
    if (!widget.canWrite || widget.offline) {
      showIosMessage(
        context,
        widget.offline ? '当前离线，只能查看已有任务' : '当前账号为只读成员，暂不能添加任务',
      );
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (_) => TaskComposerPage(
          controller: widget.controller,
          canWrite: widget.canWrite,
          organizationId: widget.organizationId,
          hamsters: widget.hamsters,
          enclosures: widget.enclosures,
        ),
      ),
    );
    if (saved == true && mounted) {
      showIosMessage(context, '任务已添加');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final actionBusy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
        final refreshing =
            widget.controller.listState.status == I2AsyncStatus.loading;
        final canEdit = widget.canWrite && !widget.offline;
        return Scaffold(
          appBar: AppBar(
            title: const Text('任务'),
            actions: [
              IconButton(
                key: const Key('task-refresh'),
                tooltip: '刷新',
                onPressed: actionBusy || refreshing ? null : _refresh,
                icon: refreshing
                    ? const CupertinoActivityIndicator(radius: 9)
                    : const Icon(CupertinoIcons.arrow_clockwise),
              ),
              IconButton(
                key: const Key('task-add'),
                tooltip: canEdit ? '添加任务' : '当前为只读模式',
                onPressed: actionBusy || refreshing || !canEdit
                    ? null
                    : _create,
                icon: const Icon(CupertinoIcons.add),
              ),
            ],
          ),
          body: Column(
            children: [
              if (widget.offline)
                const I2OfflineBanner(offline: true, lastSyncLabel: null),
              if (!widget.offline && !widget.canWrite)
                Padding(
                  key: const Key('task-readonly-banner'),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.eye,
                    color: ScolvPalette.of(context).secondaryLabel,
                    text: '当前账号为只读成员，可查看任务，任务变更由有权限成员处理。',
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _StatChip(
                      label: '待办 ${widget.controller.openCount}',
                      color: ScolvPalette.of(context).accent,
                    ),
                    _StatChip(
                      label: '逾期 ${widget.controller.overdueCount}',
                      color: widget.controller.overdueCount == 0
                          ? ScolvPalette.of(context).secondaryLabel
                          : IosColors.systemRed,
                    ),
                    if (widget.controller.notificationsReady)
                      _StatChip(label: '通知已同步', color: IosColors.systemGreen),
                  ],
                ),
              ),
              Expanded(
                child: I2AsyncStateView<List<CareTaskItem>>(
                  state: widget.controller.listState,
                  onRetry: _refresh,
                  emptyBuilder: (context) => _TaskEmptyState(
                    offline: widget.offline,
                    canCreate: canEdit,
                  ),
                  builder: (tasks) {
                    if (tasks.isEmpty) {
                      return _TaskEmptyState(
                        offline: widget.offline,
                        canCreate: canEdit,
                      );
                    }
                    return RefreshIndicator(
                      color: ScolvPalette.of(context).accent,
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                        children: [
                          IosGroupedSection(
                            children: [
                              for (final task in tasks)
                                _TaskRow(
                                  task: task,
                                  canWrite: canEdit,
                                  busy: actionBusy,
                                  completing:
                                      _completingTaskId == task.id &&
                                      actionBusy,
                                  onComplete: () => _complete(task),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TaskComposerPage extends StatefulWidget {
  const TaskComposerPage({
    super.key,
    required this.controller,
    required this.organizationId,
    this.hamsters = const <I2Hamster>[],
    this.enclosures = const <I2Enclosure>[],
    this.canWrite = true,
    this.initialDraft,
  });

  final TaskController controller;
  final String? organizationId;
  final List<I2Hamster> hamsters;
  final List<I2Enclosure> enclosures;
  final bool canWrite;
  final CreateCareTaskDraft? initialDraft;

  @override
  State<TaskComposerPage> createState() => _TaskComposerPageState();
}

class _TaskComposerPageState extends State<TaskComposerPage> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  String _taskType = 'custom';
  String _targetType = 'organization';
  String? _targetId;
  String _priority = 'normal';
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));
  bool _busy = false;

  static const _taskTypes = <IosPickerItem<String>>[
    IosPickerItem(value: 'custom', label: '自定义任务'),
    IosPickerItem(value: 'enclosure_cleaning', label: '笼盒清洁'),
    IosPickerItem(value: 'medication', label: '用药'),
    IosPickerItem(value: 'follow_up', label: '随访'),
    IosPickerItem(value: 'pup_weight_check', label: '幼崽称重'),
    IosPickerItem(value: 'profile_creation', label: '个体建档'),
  ];

  static const _priorities = <IosPickerItem<String>>[
    IosPickerItem(value: 'low', label: '低'),
    IosPickerItem(value: 'normal', label: '普通'),
    IosPickerItem(value: 'high', label: '高'),
    IosPickerItem(value: 'urgent', label: '紧急'),
  ];

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    if (draft == null) {
      _targetId = _defaultTargetId('organization');
      return;
    }
    _taskType = draft.taskType;
    _targetType = draft.targetType;
    _targetId = draft.targetId;
    _priority = draft.priority;
    _scheduledAt = draft.scheduledAt.isAfter(DateTime.now())
        ? draft.scheduledAt
        : DateTime.now().add(const Duration(hours: 1));
    _title.text = draft.title ?? '';
    _notes.text = draft.notes ?? '';
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? _defaultTargetId(String type) {
    return switch (type) {
      'organization' => widget.organizationId,
      'hamster' => widget.hamsters.isEmpty ? null : widget.hamsters.first.id,
      'enclosure' =>
        widget.enclosures.isEmpty ? null : widget.enclosures.first.id,
      _ => widget.organizationId,
    };
  }

  List<IosPickerItem<String>> get _targets => [
    if (widget.organizationId != null)
      IosPickerItem(value: 'organization', label: '整个熊舍'),
    ...widget.hamsters.map(
      (value) =>
          IosPickerItem(value: 'hamster:${value.id}', label: value.displayName),
    ),
    ...widget.enclosures.map(
      (value) => IosPickerItem(
        value: 'enclosure:${value.id}',
        label: '笼盒 ${value.code}',
      ),
    ),
  ];

  String get _targetLabel {
    if (_targetType == 'organization') return '整个熊舍';
    final id = _targetId;
    if (id == null) return '暂无可选对象';
    if (_targetType == 'hamster') {
      return widget.hamsters
              .where((value) => value.id == id)
              .map((value) => value.displayName)
              .firstOrNull ??
          '选择仓鼠';
    }
    return widget.enclosures
            .where((value) => value.id == id)
            .map((value) => '笼盒 ${value.code}')
            .firstOrNull ??
        '选择笼盒';
  }

  Future<void> _pickTarget() async {
    final selected = await showIosActionSheet<String>(
      context: context,
      title: '选择关联对象',
      items: [
        for (final item in _targets)
          IosActionItem(value: item.value, label: item.label),
      ],
    );
    if (selected == null) return;
    if (selected == 'organization') {
      setState(() {
        _targetType = 'organization';
        _targetId = widget.organizationId;
      });
      return;
    }
    final separator = selected.indexOf(':');
    if (separator <= 0) return;
    setState(() {
      _targetType = selected.substring(0, separator);
      _targetId = selected.substring(separator + 1);
    });
  }

  Future<void> _pickSchedule() async {
    var picked = _scheduledAt;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        color: ScolvPalette.of(context).secondaryGroupedBackground,
        height: 320,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('取消'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  CupertinoButton(
                    child: const Text('完成'),
                    onPressed: () {
                      setState(() => _scheduledAt = picked);
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: _scheduledAt,
                  minimumDate: DateTime.now(),
                  onDateTimeChanged: (value) => picked = value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_busy) return;
    if (!widget.canWrite) {
      showIosMessage(context, '当前为只读模式，暂不能保存任务');
      return;
    }
    final targetId = _targetId;
    if (targetId == null || targetId.isEmpty) {
      showIosMessage(context, '请选择关联对象');
      return;
    }
    setState(() => _busy = true);
    final ok = await widget.controller.create(
      CreateCareTaskDraft(
        taskType: _taskType,
        targetType: _targetType,
        targetId: targetId,
        scheduledAt: _scheduledAt,
        priority: _priority,
        title: _title.text.trim().isEmpty ? null : _title.text.trim(),
        subjectIds: _targetType == 'hamster' ? [targetId] : const <String>[],
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Navigator.of(context).pop(true);
    if (!ok && widget.controller.lastMessage != null) {
      showIosMessage(context, widget.controller.lastMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetAvailable = _targetId != null && _targetId!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('添加任务')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
        children: [
          IosGroupedSection(
            header: const IosSectionHeader('任务内容'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: TextField(
                  controller: _title,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '任务标题',
                    hintText: '例如：给雪团称重',
                  ),
                ),
              ),
              IosPickerField<String>(
                label: '任务类型',
                items: _taskTypes,
                selected: _taskType,
                onSelected: (value) =>
                    setState(() => _taskType = value ?? 'custom'),
              ),
              IosListTile(
                leading: const IosGlyph(icon: CupertinoIcons.link),
                title: '关联对象',
                subtitle: _targetLabel,
                onTap: _targets.isEmpty ? null : _pickTarget,
              ),
              IosPickerField<String>(
                label: '优先级',
                items: _priorities,
                selected: _priority,
                onSelected: (value) =>
                    setState(() => _priority = value ?? 'normal'),
              ),
              IosListTile(
                leading: const IosGlyph(icon: CupertinoIcons.calendar),
                title: '计划时间',
                subtitle: _formatDateTime(_scheduledAt),
                onTap: _pickSchedule,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: TextField(
                  controller: _notes,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: '备注（可选）',
                    hintText: '补充执行要求或观察重点',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              key: const Key('task-save'),
              onPressed: _busy || !targetAvailable ? null : _save,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(CupertinoIcons.checkmark),
              label: const Text('保存任务'),
            ),
          ),
          if (!targetAvailable)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text('请先创建仓鼠、笼盒或完成熊舍初始化，再添加关联任务。'),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$minute';
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.canWrite,
    required this.busy,
    required this.completing,
    required this.onComplete,
  });

  final CareTaskItem task;
  final bool canWrite;
  final bool busy;
  final bool completing;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final overdue = task.isOverdue;
    final open = task.isOpen;
    final accent = open
        ? (overdue ? IosColors.systemRed : ScolvPalette.of(context).accent)
        : IosColors.systemGreen;
    return IosListTile(
      key: Key('task-card-${task.id}'),
      leading: Icon(
        open ? CupertinoIcons.circle : CupertinoIcons.checkmark_circle_fill,
        color: accent,
        size: 22,
      ),
      title: task.displayTitle,
      subtitle:
          '${taskTypeLabel(task.taskType)} · '
          '${taskPriorityLabel(task.priority)} · '
          '${taskStateLabel(task.state)}\n'
          '计划 ${_fmt(task.scheduledAt)}'
          '${overdue ? ' · 已逾期' : ''}',
      trailing: open && canWrite
          ? TextButton(
              key: Key('task-complete-${task.id}'),
              onPressed: busy ? null : onComplete,
              child: completing
                  ? const CupertinoActivityIndicator(radius: 8)
                  : const Text('完成'),
            )
          : Text(
              taskStateLabel(task.state),
              style: Theme.of(context).textTheme.bodySmall,
            ),
      showChevron: false,
      onTap: open && canWrite && !busy ? onComplete : null,
    );
  }

  String _fmt(DateTime value) {
    final local = value.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$mi';
  }
}

class _TaskEmptyState extends StatelessWidget {
  const _TaskEmptyState({required this.offline, required this.canCreate});

  final bool offline;
  final bool canCreate;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final title = offline ? '离线期间没有可显示的缓存任务' : '还没有任务记录';
    final subtitle = offline
        ? '联网并刷新后会重新载入任务。'
        : canCreate
        ? '使用右上角的加号安排清洁、称重或随访。'
        : '当前账号可以查看任务，有权限的成员添加后会显示在这里。';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                offline
                    ? CupertinoIcons.cloud
                    : CupertinoIcons.checkmark_circle,
                size: 38,
                color: palette.secondaryLabel,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                key: const Key('task-empty-title'),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.secondaryLabel,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: -0.08,
        ),
      ),
    );
  }
}
