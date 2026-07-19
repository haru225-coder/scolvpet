import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'health_controller.dart';
import 'health_models.dart';

/// Health history + quick create for one hamster.
class HealthQuickPage extends StatefulWidget {
  const HealthQuickPage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.hamsterLabel,
    this.canWrite = true,
  });

  final HealthController controller;
  final String hamsterId;
  final String? hamsterLabel;
  final bool canWrite;

  @override
  State<HealthQuickPage> createState() => _HealthQuickPageState();
}

class _HealthQuickPageState extends State<HealthQuickPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadForHamster(widget.hamsterId);
  }

  Future<void> _openCreate() async {
    if (widget.controller.isBusy) return;
    final draft = await Navigator.of(context).push<HealthRecordDraft>(
      iosPageRoute(
        builder: (_) => HealthCreatePage(
          hamsterId: widget.hamsterId,
          canWrite: widget.canWrite,
        ),
      ),
    );
    if (draft == null || !mounted) return;
    final ok = await widget.controller.create(draft);
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (message != null) {
      showIosMessage(context, message);
    }
    if (ok) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final saving = widget.controller.isBusy;
        final refreshing = widget.controller.isRefreshing;
        final busy = saving || refreshing;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.hamsterLabel == null
                  ? '健康记录'
                  : '健康 · ${widget.hamsterLabel}',
            ),
            actions: [
              IconButton(
                key: const Key('health-refresh'),
                onPressed: busy
                    ? null
                    : () => widget.controller.loadForHamster(widget.hamsterId),
                icon: busy
                    ? const CupertinoActivityIndicator()
                    : const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          floatingActionButton: widget.canWrite
              ? FloatingActionButton.extended(
                  key: const Key('health-quick-add'),
                  onPressed: busy ? null : _openCreate,
                  backgroundColor: ScolvPalette.of(context).accent,
                  foregroundColor: ScolvPalette.of(context).groupedBackground,
                  elevation: 0,
                  icon: busy
                      ? const CupertinoActivityIndicator()
                      : const Icon(CupertinoIcons.add),
                  label: Text(refreshing ? '正在载入' : (saving ? '正在保存' : '快捷记录')),
                )
              : null,
          body: Column(
            children: [
              if (!widget.canWrite)
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    IosMetrics.pagePadding,
                    12,
                    IosMetrics.pagePadding,
                    0,
                  ),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看健康记录，新增记录已设为只读。',
                  ),
                ),
              if (widget.controller.hadPartialSuccess)
                Padding(
                  key: const Key('health-partial-success'),
                  padding: const EdgeInsets.fromLTRB(
                    IosMetrics.pagePadding,
                    12,
                    IosMetrics.pagePadding,
                    0,
                  ),
                  child: IosBanner(
                    icon: CupertinoIcons.exclamationmark_triangle,
                    color: IosColors.systemOrange,
                    text:
                        '${widget.controller.lastMessage ?? '健康记录已保存，复查任务未创建'}。'
                        '${widget.controller.lastFollowUpTaskError == null ? '' : ' 原因：${widget.controller.lastFollowUpTaskError}'}',
                  ),
                )
              else if (widget.controller.actionState.status ==
                  I2AsyncStatus.error)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IosMetrics.pagePadding,
                    12,
                    IosMetrics.pagePadding,
                    0,
                  ),
                  child: IosBanner(
                    icon: CupertinoIcons.exclamationmark_circle,
                    color: IosColors.systemRed,
                    text: widget.controller.actionState.message ?? '健康记录保存未完成',
                  ),
                ),
              Expanded(
                child: I2AsyncStateView<List<HealthRecordItem>>(
                  state: widget.controller.listState,
                  onRetry: () =>
                      widget.controller.loadForHamster(widget.hamsterId),
                  emptyBuilder: (context) =>
                      _HealthEmptyState(canWrite: widget.canWrite),
                  builder: (records) {
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                      children: [
                        IosGroupedSection(
                          children: [
                            for (final record in records)
                              IosListTile(
                                key: Key('health-card-${record.id}'),
                                leading: IosGlyph(
                                  icon: _healthIcon(record.type),
                                  color: _healthTone(context, record),
                                ),
                                title: record.typeLabel,
                                subtitle: [
                                  _healthDateTimeLabel(record.observedAt),
                                  record.readableSummary,
                                  if (record.followUpAt != null)
                                    '复查 ${_healthDateTimeLabel(record.followUpAt!)}',
                                ].join('\n'),
                                onTap: () {
                                  Navigator.of(context).push<void>(
                                    iosPageRoute(
                                      builder: (_) => HealthRecordDetailPage(
                                        record: record,
                                        hamsterLabel: widget.hamsterLabel,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
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

class HealthCreatePage extends StatefulWidget {
  const HealthCreatePage({
    super.key,
    required this.hamsterId,
    this.canWrite = true,
  });

  final String hamsterId;
  final bool canWrite;

  @override
  State<HealthCreatePage> createState() => _HealthCreatePageState();
}

class _HealthCreatePageState extends State<HealthCreatePage> {
  String _type = 'daily_check';
  String? _severity;
  DateTime _observedAt = DateTime.now();
  final _notes = TextEditingController();
  final _medName = TextEditingController();
  bool _needFollowUp = false;
  int _followUpDays = 3;
  String? _severityError;
  String? _medicationError;

  @override
  void dispose() {
    _notes.dispose();
    _medName.dispose();
    super.dispose();
  }

  void _setType(String type) {
    setState(() {
      _type = type;
      if (!healthTypeRequiresSeverity(type)) _severityError = null;
      if (!healthTypeRequiresMedicationPlan(type)) _medicationError = null;
    });
  }

  Future<void> _pickObservedAt() async {
    var picked = _observedAt;
    final maximum = DateTime.now().add(const Duration(minutes: 1));
    if (picked.isAfter(maximum)) picked = maximum;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) {
        final palette = ScolvPalette.of(ctx);
        return Container(
          height: 330,
          color: palette.secondaryGroupedBackground,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                      CupertinoButton(
                        onPressed: () {
                          setState(() => _observedAt = picked);
                          Navigator.pop(ctx);
                        },
                        child: const Text('完成'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    key: const Key('health-observed-at-picker'),
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: picked,
                    minimumDate: DateTime.now().subtract(
                      const Duration(days: 3650),
                    ),
                    maximumDate: maximum,
                    use24hFormat: true,
                    onDateTimeChanged: (value) => picked = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (!widget.canWrite) return;
    final plan = _medName.text.trim();
    final severityMissing =
        healthTypeRequiresSeverity(_type) &&
        (_severity == null || _severity!.isEmpty);
    final medicationMissing =
        healthTypeRequiresMedicationPlan(_type) && plan.isEmpty;
    setState(() {
      _severityError = severityMissing ? '异常记录必须选择严重度' : null;
      _medicationError = medicationMissing ? '请填写药品、剂量或处理方案' : null;
    });
    if (severityMissing || medicationMissing) return;

    final now = DateTime.now().toUtc();
    final med = <String, dynamic>{};
    if (plan.isNotEmpty) {
      med['plan'] = plan;
    }
    final draft = HealthRecordDraft(
      hamsterId: widget.hamsterId,
      type: _type,
      observedAt: _observedAt.toUtc(),
      severity: _severity,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      followUpAt: _needFollowUp ? now.add(Duration(days: _followUpDays)) : null,
      medication: med,
      structuredChecks: {
        'source': 'mobile_quick',
        'type_label': healthTypeLabel(_type),
      },
      createFollowUpTask: _needFollowUp,
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('快捷健康记录')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          if (!widget.canWrite) ...[
            const IosBanner(
              icon: CupertinoIcons.lock_shield,
              color: IosColors.systemOrange,
              text: '当前为只读模式，可查看字段但不能保存。',
            ),
            const SizedBox(height: 12),
          ],
          Text(
            '记录实际观察时间和处理情况。需要复查时，可同步建立护理任务。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          const IosSectionHeader('类型'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in healthQuickTypes)
                ChoiceChip(
                  key: Key('health-type-$type'),
                  label: Text(healthTypeLabel(type)),
                  selected: _type == type,
                  selectedColor: ScolvPalette.of(context).accentSoft,
                  labelStyle: TextStyle(
                    color: _type == type
                        ? ScolvPalette.of(context).accent
                        : ScolvPalette.of(context).label,
                    fontWeight: _type == type
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: _type == type
                        ? ScolvPalette.of(
                            context,
                          ).accent.withValues(alpha: 0.35)
                        : ScolvPalette.of(context).opaqueSeparator,
                    width: IosMetrics.hairline,
                  ),
                  onSelected: widget.canWrite ? (_) => _setType(type) : null,
                ),
            ],
          ),
          const SizedBox(height: 20),
          const IosSectionHeader('详情'),
          IosGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              IosListTile(
                key: const Key('health-observed-at'),
                leading: const IosGlyph(icon: CupertinoIcons.clock),
                title: '记录时间',
                subtitle: _healthDateTimeLabel(_observedAt),
                onTap: widget.canWrite ? _pickObservedAt : null,
                showChevron: widget.canWrite,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IosPickerField<String?>(
                      key: const Key('health-severity'),
                      label: healthTypeRequiresSeverity(_type)
                          ? '严重度（必填）'
                          : '严重度',
                      selected: _severity,
                      items: const [
                        IosPickerItem(value: null, label: '未标'),
                        IosPickerItem(value: 'info', label: '信息'),
                        IosPickerItem(value: 'low', label: '低'),
                        IosPickerItem(value: 'medium', label: '中'),
                        IosPickerItem(value: 'high', label: '高'),
                        IosPickerItem(value: 'critical', label: '危急'),
                      ],
                      enabled: widget.canWrite,
                      onSelected: (value) {
                        setState(() {
                          _severity = value;
                          _severityError = null;
                        });
                      },
                    ),
                    if (_severityError != null)
                      _HealthInlineError(
                        key: const Key('health-severity-error'),
                        message: _severityError!,
                      ),
                  ],
                ),
              ),
              if (_type == 'medication')
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    key: const Key('health-med-name'),
                    controller: _medName,
                    enabled: widget.canWrite,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      if (_medicationError == null) return;
                      setState(() => _medicationError = null);
                    },
                    decoration: InputDecoration(
                      labelText: '用药方案（必填）',
                      helperText: '填写药品、剂量、频次或处理方案',
                      errorText: _medicationError,
                      filled: false,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  key: const Key('health-notes'),
                  controller: _notes,
                  enabled: widget.canWrite,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: '观察与处理说明',
                    filled: false,
                  ),
                ),
              ),
              SwitchListTile(
                key: const Key('health-follow-up-switch'),
                title: const Text('需要复查并创建任务'),
                subtitle: Text(
                  _needFollowUp ? '$_followUpDays 天后提醒' : '不创建复查任务',
                ),
                value: _needFollowUp,
                activeThumbColor: ScolvPalette.of(context).accent,
                onChanged: widget.canWrite
                    ? (value) => setState(() => _needFollowUp = value)
                    : null,
              ),
              if (_needFollowUp)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Text(
                        '复查间隔（天）',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Expanded(
                        child: Slider(
                          key: const Key('health-follow-up-days'),
                          value: _followUpDays.toDouble(),
                          min: 1,
                          max: 14,
                          divisions: 13,
                          activeColor: ScolvPalette.of(context).accent,
                          label: '$_followUpDays',
                          onChanged: widget.canWrite
                              ? (v) => setState(() => _followUpDays = v.round())
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('health-save'),
            onPressed: widget.canWrite ? _submit : null,
            icon: const Icon(CupertinoIcons.checkmark_circle_fill),
            label: const Text('保存记录'),
          ),
        ],
      ),
    );
  }
}

class HealthRecordDetailPage extends StatelessWidget {
  const HealthRecordDetailPage({
    super.key,
    required this.record,
    this.hamsterLabel,
  });

  final HealthRecordItem record;
  final String? hamsterLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('健康记录详情')),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 32),
        children: [
          IosModuleIntro(
            icon: _healthIcon(record.type),
            title: record.typeLabel,
            description: hamsterLabel == null || hamsterLabel!.trim().isEmpty
                ? record.readableSummary
                : '${hamsterLabel!.trim()}：${record.readableSummary}',
            metrics: [
              IosModuleMetric(
                label: '记录时间',
                value: _healthDateLabel(record.observedAt),
                color: _healthTone(context, record),
              ),
              IosModuleMetric(
                label: '严重度',
                value: healthSeverityLabel(record.severity),
                color: _healthTone(context, record),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const IosSectionHeader('记录信息'),
          IosGroupedSection(
            children: [
              I2InfoTile(label: '类型', value: record.typeLabel),
              I2InfoTile(
                label: '记录时间',
                value: _healthDateTimeLabel(record.observedAt),
              ),
              I2InfoTile(
                label: '严重度',
                value: healthSeverityLabel(record.severity),
              ),
              if (record.followUpAt != null)
                I2InfoTile(
                  label: '复查时间',
                  value: _healthDateTimeLabel(record.followUpAt!),
                ),
            ],
          ),
          if (record.medicationPlan != null) ...[
            const SizedBox(height: 16),
            const IosSectionHeader('用药方案'),
            IosGroupedSection(
              children: [
                I2InfoTile(label: '方案', value: record.medicationPlan!),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const IosSectionHeader('观察与处理说明'),
          IosGroupedSection(
            children: [
              I2InfoTile(
                label: '说明',
                value: record.notes?.trim().isNotEmpty == true
                    ? record.notes!.trim()
                    : '未填写',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthEmptyState extends StatelessWidget {
  const _HealthEmptyState({required this.canWrite});

  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IosGlyph(icon: CupertinoIcons.heart, size: 46),
            const SizedBox(height: 14),
            Text(
              '暂无健康记录',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              canWrite ? '点右下角“快捷记录”，添加第一条观察。' : '这只仓鼠目前没有已登记的健康记录。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryLabel,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthInlineError extends StatelessWidget {
  const _HealthInlineError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message,
        style: const TextStyle(color: IosColors.systemRed, fontSize: 12),
      ),
    );
  }
}

IconData _healthIcon(String type) => switch (type) {
  'medication' => CupertinoIcons.bandage,
  'anomaly' => CupertinoIcons.exclamationmark_triangle_fill,
  'isolation' => CupertinoIcons.shield_lefthalf_fill,
  'death' => CupertinoIcons.heart_slash_fill,
  'follow_up' => CupertinoIcons.arrow_clockwise_circle_fill,
  _ => CupertinoIcons.checkmark_seal,
};

Color _healthTone(BuildContext context, HealthRecordItem record) {
  if (record.type == 'anomaly' ||
      record.severity == 'high' ||
      record.severity == 'critical') {
    return IosColors.systemRed;
  }
  if (record.type == 'medication') return IosColors.systemOrange;
  return ScolvPalette.of(context).accent;
}

String _healthDateTimeLabel(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

String _healthDateLabel(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.month)}-${two(local.day)}';
}
