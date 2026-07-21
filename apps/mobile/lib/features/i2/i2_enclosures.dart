import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import 'i2_controller.dart';
import 'i2_models.dart';
import 'i2_widgets.dart';

String _hamsterLabel(I2Snapshot? snapshot, String hamsterId) {
  for (final hamster in snapshot?.hamsters ?? const <I2Hamster>[]) {
    if (hamster.id == hamsterId) return hamster.displayName;
  }
  return '仓鼠';
}

String _writeRestrictionMessage(I2Controller controller, String action) {
  if (controller.offline) return '当前为离线只读，联网后再$action';
  return '当前角色没有$action的权限';
}

class EnclosureGridPage extends StatelessWidget {
  const EnclosureGridPage({
    super.key,
    required this.controller,
    this.onOpenDetail,
    this.onCreate,
    this.canWrite = true,
  });

  final I2Controller controller;
  final ValueChanged<I2Enclosure>? onOpenDetail;
  final VoidCallback? onCreate;
  final bool canWrite;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final canPop = Navigator.of(context).canPop();
      final hasWritePermission = canWrite && controller.hasWritePermission;
      final canCreate = hasWritePermission && controller.canWrite;
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: IosLargeTitle(
                  '笼舍',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canPop)
                        IconButton(
                          key: const Key('enclosure-grid-back'),
                          tooltip: '返回',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(CupertinoIcons.chevron_back),
                        ),
                      BearGlyphTile(
                        icon: CupertinoIcons.square_grid_2x2_fill,
                        semanticLabel: '笼舍',
                        size: 32,
                        padding: 4,
                      ),
                      IconButton(
                        tooltip: '刷新笼舍',
                        onPressed: controller.retry,
                        icon: const Icon(CupertinoIcons.arrow_clockwise),
                      ),
                      if (onCreate != null)
                        IconButton(
                          key: const Key('enclosure-add'),
                          tooltip: '添加笼盒',
                          onPressed: canCreate
                              ? onCreate
                              : () => showIosMessage(
                                  context,
                                  _writeRestrictionMessage(controller, '新增笼盒'),
                                ),
                          icon: const Icon(CupertinoIcons.add),
                        ),
                    ],
                  ),
                ),
              ),
              I2OfflineBanner(
                offline: controller.offline,
                lastSyncLabel: controller.lastSyncLabel,
              ),
              if (!hasWritePermission && !controller.offline)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看笼舍记录，新增、移笼与清洁操作已设为只读。',
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: IosBanner(
                  icon: CupertinoIcons.info_circle,
                  color: IosColors.systemTeal,
                  text: '笼舍就是每个饲养空间：可查看入住、移笼、清洁和隔离记录。',
                ),
              ),
              Expanded(
                child: I2AsyncStateView<I2Snapshot>(
                  state: controller.snapshotState,
                  onRetry: controller.retry,
                  emptyBuilder: (context) => I2StateMessage(
                    icon: CupertinoIcons.square_grid_2x2,
                    message: '暂无笼盒记录',
                    illustration: BearAssets.emptyList,
                    mood: BearMood.sleepy,
                    actionLabel: canCreate && onCreate != null ? '添加笼盒' : null,
                    onRetry: canCreate ? onCreate : null,
                  ),
                  builder: (snapshot) {
                    if (snapshot.enclosures.isEmpty) {
                      return I2StateMessage(
                        icon: CupertinoIcons.square_grid_2x2,
                        message: '暂无笼盒记录',
                        illustration: BearAssets.emptyList,
                        mood: BearMood.sleepy,
                        actionLabel: canCreate && onCreate != null
                            ? '添加笼盒'
                            : null,
                        onRetry: canCreate ? onCreate : null,
                      );
                    }
                    final racks = <String, Map<String, List<I2Enclosure>>>{};
                    for (final enclosure in snapshot.enclosures) {
                      racks
                          .putIfAbsent(
                            enclosure.rackLabel,
                            () => <String, List<I2Enclosure>>{},
                          )
                          .putIfAbsent(
                            enclosure.levelLabel,
                            () => <I2Enclosure>[],
                          )
                          .add(enclosure);
                    }
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: _EnclosureLegend(),
                        ),
                        const SizedBox(height: 8),
                        for (final rack in racks.entries) ...[
                          IosSectionHeader('笼架 ${rack.key}'),
                          for (final level in rack.value.entries) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
                              child: Text(
                                '层位 ${level.key}',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: ScolvPalette.of(
                                        context,
                                      ).secondaryLabel,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final compact =
                                      constraints.maxWidth < 360 ||
                                      MediaQuery.textScalerOf(
                                            context,
                                          ).scale(1) >
                                          1.2;
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: compact ? 1 : 2,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          mainAxisExtent: compact ? 184 : 176,
                                        ),
                                    itemCount: level.value.length,
                                    itemBuilder: (context, index) {
                                      final enclosure = level.value[index];
                                      return _EnclosureBoardTile(
                                        enclosure: enclosure,
                                        hamsters: snapshot.hamsters
                                            .where(
                                              (hamster) => enclosure
                                                  .currentHamsterIds
                                                  .contains(hamster.id),
                                            )
                                            .toList(),
                                        recentWeights: snapshot.recentWeights,
                                        onTap: onOpenDetail == null
                                            ? null
                                            : () => onOpenDetail!(enclosure),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class EnclosureEditorPage extends StatefulWidget {
  const EnclosureEditorPage({
    super.key,
    required this.controller,
    this.canWrite = true,
  });

  final I2Controller controller;
  final bool canWrite;

  @override
  State<EnclosureEditorPage> createState() => _EnclosureEditorPageState();
}

class _EnclosureEditorPageState extends State<EnclosureEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _rack = TextEditingController();
  final _level = TextEditingController();
  final _capacity = TextEditingController(text: '1');
  final _equipment = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    _rack.dispose();
    _level.dispose();
    _capacity.dispose();
    _equipment.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final canSubmit =
        widget.canWrite &&
        widget.controller.hasWritePermission &&
        widget.controller.canWrite;
    if (!canSubmit) {
      showIosMessage(
        context,
        _writeRestrictionMessage(widget.controller, '新增笼盒'),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final code = _code.text.trim();
    final capacity = int.parse(_capacity.text.trim());
    setState(() => _busy = true);
    try {
      await widget.controller.createEnclosure(
        I2EnclosureDraft(
          code: code,
          rackCode: _rack.text.trim().isEmpty ? null : _rack.text.trim(),
          levelCode: _level.text.trim().isEmpty ? null : _level.text.trim(),
          capacity: capacity,
          equipment: _equipment.text
              .split(RegExp(r'[,，、\n]'))
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList(),
        ),
      );
      if (!mounted) return;
      if (widget.controller.actionState.status == I2AsyncStatus.data) {
        showIosMessage(context, '笼盒已添加');
        Navigator.of(context).pop(true);
      } else if (widget.controller.actionState.message != null) {
        showIosMessage(context, widget.controller.actionState.message!);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final hasWritePermission =
          widget.canWrite && widget.controller.hasWritePermission;
      final canSubmit = hasWritePermission && widget.controller.canWrite;
      return Scaffold(
        appBar: AppBar(title: const Text('添加笼盒')),
        body: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
            children: [
              I2OfflineBanner(
                offline: widget.controller.offline,
                lastSyncLabel: widget.controller.lastSyncLabel,
              ),
              if (!hasWritePermission && !widget.controller.offline)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色没有新增笼盒的权限。',
                  ),
                ),
              IosGroupedSection(
                header: const IosSectionHeader('笼盒资料'),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: TextFormField(
                      key: const Key('enclosure-code'),
                      controller: _code,
                      enabled: canSubmit && !_busy,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: '笼盒编号 *',
                        hintText: '例如：A-01',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return '请填写笼盒编号';
                        if (text.length > 64) return '笼盒编号最多 64 个字符';
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextFormField(
                      controller: _rack,
                      enabled: canSubmit && !_busy,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: '笼架（可选）'),
                      validator: (value) => (value?.trim().length ?? 0) > 64
                          ? '笼架最多 64 个字符'
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextFormField(
                      controller: _level,
                      enabled: canSubmit && !_busy,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: '层位（可选）'),
                      validator: (value) => (value?.trim().length ?? 0) > 64
                          ? '层位最多 64 个字符'
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextFormField(
                      key: const Key('enclosure-capacity'),
                      controller: _capacity,
                      enabled: canSubmit && !_busy,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: '容量 *',
                        helperText: '至少 1 只',
                      ),
                      validator: (value) {
                        final capacity = int.tryParse(value?.trim() ?? '');
                        if (capacity == null) return '请输入整数容量';
                        if (capacity < 1) return '容量至少为 1';
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: TextFormField(
                      controller: _equipment,
                      enabled: canSubmit && !_busy,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: '设施（可选）',
                        hintText: '用逗号分隔，例如：跑轮、躲避屋',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: I2WriteButton(
                  key: const Key('enclosure-save'),
                  enabled: canSubmit && !_busy,
                  label: _busy ? '保存中…' : '保存笼盒',
                  disabledLabel: _busy
                      ? '保存中…'
                      : !hasWritePermission
                      ? '保存笼盒（无编辑权限）'
                      : '保存笼盒（联网后可用）',
                  icon: CupertinoIcons.checkmark,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _EnclosureLegend extends StatelessWidget {
  const _EnclosureLegend();

  @override
  Widget build(BuildContext context) {
    const tones = EnclosureBoardTone.values;
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        for (final tone in tones)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: enclosureBoardColor(context, tone),
                  border: Border.all(
                    color: enclosureBoardAccent(context, tone),
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                enclosureBoardToneLabel(tone),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }
}

class _EnclosureBoardTile extends StatelessWidget {
  const _EnclosureBoardTile({
    required this.enclosure,
    this.hamsters = const <I2Hamster>[],
    this.recentWeights = const <I2WeightRecord>[],
    this.onTap,
  });

  final I2Enclosure enclosure;
  final List<I2Hamster> hamsters;
  final List<I2WeightRecord> recentWeights;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = enclosureBoardTone(enclosure);
    final accent = enclosureBoardAccent(context, tone);
    final occupants = enclosure.currentHamsterIds.length;
    final capacity = enclosure.capacity?.toString() ?? '—';
    final dirty =
        tone == EnclosureBoardTone.dirty ||
        enclosure.cleanlinessState.toLowerCase() != 'clean';
    final semanticLabel =
        '笼盒 ${enclosure.code.isEmpty ? '未命名' : enclosure.code}，'
        '${i2EnclosureStateLabel(enclosure.state)}，'
        '${occupants == 0 ? '无人入住' : '在住 $occupants 只'}，'
        '${dirty ? '待清洁' : '清洁正常'}';
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('enclosure-tile-${enclosure.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: enclosureBoardColor(context, tone),
              borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
              border: Border.all(
                color: accent.withValues(alpha: 0.22),
                width: IosMetrics.hairline,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 16,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        enclosure.code.isEmpty ? '未命名笼盒' : enclosure.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.41,
                            ),
                      ),
                    ),
                    Icon(
                      switch (tone) {
                        EnclosureBoardTone.isolation =>
                          CupertinoIcons.shield_lefthalf_fill,
                        EnclosureBoardTone.dirty => CupertinoIcons.sparkles,
                        EnclosureBoardTone.vacant => CupertinoIcons.square,
                        EnclosureBoardTone.gestation =>
                          CupertinoIcons.heart_fill,
                        EnclosureBoardTone.pairing =>
                          CupertinoIcons.arrow_2_squarepath,
                        EnclosureBoardTone.disabled =>
                          CupertinoIcons.minus_circle,
                        EnclosureBoardTone.occupied => CupertinoIcons.paw,
                      },
                      size: 15,
                      color: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (hamsters.isEmpty && occupants == 0)
                  Text(
                    '空笼盒 · 可入住',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else if (hamsters.isEmpty)
                  Text(
                    '$occupants 只 · 档案同步中',
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                else
                  for (final hamster in hamsters.take(2))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          HamsterAvatar(
                            label: hamster.name ?? hamster.internalCode,
                            imageUrl: hamster.avatarUrl,
                            imageBytes: hamster.avatarBytes,
                            size: 24,
                            statusColor: accent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _enclosureHamsterSummary(hamster, recentWeights),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                if (hamsters.length > 2)
                  Text(
                    '还有 ${hamsters.length - 2} 只',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                const Spacer(),
                Text(
                  i2EnclosureStateLabel(enclosure.state),
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.08,
                  ),
                ),
                Text(
                  occupants == 0
                      ? '无人入住'
                      : '容量 $occupants/$capacity · 在住 $occupants',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  dirty ? '待清洁' : '清洁正常',
                  style: TextStyle(
                    fontSize: 11,
                    color: dirty
                        ? IosColors.systemOrange
                        : IosColors.systemGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _enclosureHamsterSummary(
  I2Hamster hamster,
  List<I2WeightRecord> recentWeights,
) {
  final latest = recentWeights
      .where((record) => record.hamsterId == hamster.id)
      .fold<I2WeightRecord?>(
        null,
        (current, next) =>
            current == null || next.recordedAt.isAfter(current.recordedAt)
            ? next
            : current,
      );
  final age = hamster.birthDate == null
      ? null
      : _hamsterAgeLabel(hamster.birthDate!);
  final parts = <String>[
    hamster.name ?? hamster.internalCode,
    i2SexLabel(hamster.sex),
    if (age != null) age,
    if (latest != null) '${latest.weightG}g',
  ];
  return parts.join(' · ');
}

String _hamsterAgeLabel(DateTime birthDate) {
  final now = DateTime.now();
  var months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
  if (now.day < birthDate.day) months--;
  if (months < 1) return '未满月';
  if (months < 12) return '$months 个月';
  final years = months ~/ 12;
  final remaining = months % 12;
  return remaining == 0 ? '$years 岁' : '$years 岁 $remaining 个月';
}

class _EnclosureInlineEmpty extends StatelessWidget {
  const _EnclosureInlineEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Icon(
          CupertinoIcons.tray,
          size: 18,
          color: ScolvPalette.of(context).secondaryLabel,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );
}

class EnclosureDetailPage extends StatefulWidget {
  const EnclosureDetailPage({
    super.key,
    required this.controller,
    required this.enclosureId,
    this.onMove,
    this.onCare,
    this.canWrite = true,
  });

  final I2Controller controller;
  final String enclosureId;
  final VoidCallback? onMove;
  final VoidCallback? onCare;
  final bool canWrite;

  @override
  State<EnclosureDetailPage> createState() => _EnclosureDetailPageState();
}

class _EnclosureDetailPageState extends State<EnclosureDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadEnclosureDetail(widget.enclosureId);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final hasWritePermission =
          widget.canWrite && widget.controller.hasWritePermission;
      final canWrite = hasWritePermission && widget.controller.canWrite;
      return Scaffold(
        appBar: AppBar(title: const Text('笼盒详情')),
        body: Column(
          children: [
            I2OfflineBanner(
              offline: widget.controller.offline,
              lastSyncLabel: widget.controller.lastSyncLabel,
            ),
            if (!hasWritePermission && !widget.controller.offline)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: IosBanner(
                  icon: CupertinoIcons.lock_shield,
                  color: IosColors.systemOrange,
                  text: '当前角色可查看笼舍详情，入住、移笼与清洁操作已禁用。',
                ),
              ),
            Expanded(
              child: I2AsyncStateView<I2EnclosureDetail>(
                state: widget.controller.enclosureDetailState,
                onRetry: () =>
                    widget.controller.loadEnclosureDetail(widget.enclosureId),
                builder: (detail) {
                  final snapshot = widget.controller.snapshotState.data;
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    children: [
                      IosGroupedSection(
                        margin: EdgeInsets.zero,
                        children: [
                          IosListTile(
                            title: detail.enclosure.code,
                            subtitle: i2EnclosureStateLabel(
                              detail.enclosure.state,
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: ScolvPalette.of(context).secondaryFill,
                                borderRadius: BorderRadius.circular(
                                  IosMetrics.pillRadius,
                                ),
                              ),
                              child: Text(
                                i2CleanlinessLabel(
                                  detail.enclosure.cleanlinessState,
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            showChevron: false,
                          ),
                          I2InfoTile(
                            label: '笼架 / 层位',
                            value:
                                '${detail.enclosure.rackLabel} / ${detail.enclosure.levelLabel}',
                          ),
                          I2InfoTile(
                            label: '容量',
                            value: '${detail.enclosure.capacity ?? '—'}',
                          ),
                          I2InfoTile(
                            label: '设施',
                            value: detail.enclosure.equipment.isEmpty
                                ? '—'
                                : detail.enclosure.equipment.join('、'),
                          ),
                          I2InfoTile(
                            label: '最近清洁',
                            value: i2DateTimeLabel(
                              detail.enclosure.lastCleanedAt,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (widget.onMove != null)
                            I2WriteButton(
                              enabled: canWrite,
                              label: '入住 / 移笼',
                              disabledLabel: widget.controller.offline
                                  ? '入住 / 移笼（联网后可用）'
                                  : '入住 / 移笼（无编辑权限）',
                              icon: CupertinoIcons.arrow_right_arrow_left,
                              onPressed: widget.onMove,
                            ),
                          if (widget.onCare != null)
                            I2WriteButton(
                              enabled: canWrite,
                              label: '记录清洁',
                              disabledLabel: widget.controller.offline
                                  ? '记录清洁（联网后可用）'
                                  : '记录清洁（无编辑权限）',
                              icon: CupertinoIcons.sparkles,
                              onPressed: widget.onCare,
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '入住与移笼历史',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: ScolvPalette.of(context).secondaryLabel,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (detail.stays.isEmpty)
                        Text(
                          widget.controller.offline
                              ? '离线缓存不含入住与移笼历史'
                              : '暂无入住记录',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else
                        IosGroupedSection(
                          margin: EdgeInsets.zero,
                          children: [
                            for (final stay in detail.stays)
                              IosListTile(
                                leading: IosGlyph(
                                  icon: stay.endedAt == null
                                      ? CupertinoIcons.arrow_down_left
                                      : CupertinoIcons.arrow_up_right,
                                  color: stay.endedAt == null
                                      ? IosColors.systemGreen
                                      : IosColors.systemOrange,
                                ),
                                title:
                                    '${_hamsterLabel(snapshot, stay.hamsterId)} · ${i2StayPurposeLabel(stay.purpose)}',
                                subtitle:
                                    '${i2DateTimeLabel(stay.startedAt)} → ${i2DateTimeLabel(stay.endedAt)}'
                                    '${stay.reason == null ? '' : '\n${stay.reason}'}',
                                showChevron: false,
                              ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Text(
                        '清洁历史',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: ScolvPalette.of(context).secondaryLabel,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      I2AsyncStateView<List<I2CleaningRecord>>(
                        state: widget.controller.cleaningState,
                        onRetry: () => widget.controller.loadCleaningHistory(
                          widget.enclosureId,
                        ),
                        emptyBuilder: (context) => _EnclosureInlineEmpty(
                          message:
                              widget.controller.cleaningState.message ??
                              '暂无清洁记录',
                        ),
                        builder: (records) => IosGroupedSection(
                          margin: EdgeInsets.zero,
                          children: [
                            for (final record in records)
                              IosListTile(
                                leading: const IosGlyph(
                                  icon: CupertinoIcons.sparkles,
                                  color: IosColors.systemTeal,
                                ),
                                title: i2CleaningTypeLabel(record.type),
                                subtitle:
                                    '${i2DateTimeLabel(record.completedAt)}'
                                    '${record.reason == null ? '' : ' · ${record.reason}'}',
                                trailing: record.healthRecordId == null
                                    ? null
                                    : const Icon(
                                        CupertinoIcons.heart_fill,
                                        size: 16,
                                        color: IosColors.systemRed,
                                      ),
                                showChevron: false,
                              ),
                          ],
                        ),
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

class MoveHamsterPage extends StatefulWidget {
  const MoveHamsterPage({
    super.key,
    required this.controller,
    required this.enclosureId,
    this.enclosureVersion = 1,
    this.onSaved,
  });

  final I2Controller controller;
  final String enclosureId;
  final int enclosureVersion;
  final VoidCallback? onSaved;

  @override
  State<MoveHamsterPage> createState() => _MoveHamsterPageState();
}

class _MoveHamsterPageState extends State<MoveHamsterPage> {
  final _reason = TextEditingController();
  String _purpose = 'single';
  String? _selectedHamsterId;
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy ||
        widget.controller.actionState.status == I2AsyncStatus.loading) {
      return;
    }
    if (!widget.controller.canWrite) {
      showIosMessage(
        context,
        _writeRestrictionMessage(widget.controller, '提交入住或移笼'),
      );
      return;
    }
    final hamsterId = _selectedHamsterId?.trim() ?? '';
    if (hamsterId.isEmpty) {
      showIosMessage(context, '请选择一只仓鼠');
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.controller.moveHamster(
        I2MoveDraft(
          enclosureId: widget.enclosureId,
          hamsterId: hamsterId,
          purpose: _purpose,
          startedAt: DateTime.now(),
          reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
        ),
        enclosureVersion: widget.enclosureVersion,
      );
      if (!mounted) return;
      if (widget.controller.actionState.status == I2AsyncStatus.data) {
        showIosMessage(context, '入住 / 移笼已提交');
        widget.onSaved?.call();
      } else if (widget.controller.actionState.message != null) {
        showIosMessage(context, widget.controller.actionState.message!);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final hamsters =
            widget.controller.snapshotState.data?.hamsters ??
            const <I2Hamster>[];
        final active = hamsters
            .where((hamster) => hamster.lifecycleStatus == 'active')
            .toList();
        final busy =
            _busy ||
            widget.controller.actionState.status == I2AsyncStatus.loading;
        final canWrite = widget.controller.canWrite;
        return Scaffold(
          appBar: AppBar(title: const Text('入住 / 移笼')),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              I2OfflineBanner(
                offline: widget.controller.offline,
                lastSyncLabel: widget.controller.lastSyncLabel,
              ),
              if (!widget.controller.hasWritePermission &&
                  !widget.controller.offline)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色没有入住或移笼的权限。',
                  ),
                ),
              Text(
                '把仓鼠移入这个笼盒，并保留完整的入住记录。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              const IosSectionHeader('目标'),
              IosGroupedSection(
                margin: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: active.isNotEmpty
                        ? IosPickerField<String?>(
                            key: const Key('move-hamster-picker'),
                            label: '选择仓鼠 *',
                            selected: _selectedHamsterId,
                            items: [
                              for (final h in active)
                                IosPickerItem(
                                  value: h.id,
                                  label:
                                      '${h.displayName}'
                                      '${h.currentEnclosureId == null ? '' : ' · 已在其他笼盒'}',
                                ),
                            ],
                            enabled: canWrite && !busy,
                            onSelected: (value) => setState(() {
                              _selectedHamsterId = value;
                            }),
                          )
                        : const Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: IosBanner(
                              icon: CupertinoIcons.paw,
                              text: '暂无可选择的在养仓鼠',
                              color: IosColors.systemOrange,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: IosPickerField<String>(
                      key: const Key('move-purpose'),
                      label: '用途 / 入住类型',
                      selected: _purpose,
                      items: const [
                        IosPickerItem(value: 'single', label: '单住'),
                        IosPickerItem(value: 'pairing_temp', label: '临时配对'),
                        IosPickerItem(value: 'gestation', label: '孕期'),
                        IosPickerItem(value: 'isolation', label: '隔离'),
                        IosPickerItem(value: 'dam_with_litter', label: '母带崽'),
                      ],
                      enabled: canWrite && !busy,
                      onSelected: (value) {
                        if (value != null) {
                          setState(() => _purpose = value);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: TextField(
                      controller: _reason,
                      enabled: canWrite && !busy,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: '原因 / 备注',
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              I2WriteButton(
                enabled: canWrite && active.isNotEmpty && !busy,
                label: busy ? '提交中…' : '提交移笼 / 入住',
                disabledLabel: busy
                    ? '提交中…'
                    : !widget.controller.hasWritePermission
                    ? '提交移笼 / 入住（无编辑权限）'
                    : widget.controller.offline
                    ? '提交移笼 / 入住（联网后可用）'
                    : '提交移笼 / 入住（暂无在养仓鼠）',
                icon: CupertinoIcons.arrow_right_arrow_left,
                onPressed: _save,
              ),
            ],
          ),
        );
      },
    );
  }
}

class EnclosureCarePage extends StatefulWidget {
  const EnclosureCarePage({
    super.key,
    required this.controller,
    required this.enclosureId,
    this.enclosureVersion = 1,
    this.onSaved,
  });

  final I2Controller controller;
  final String enclosureId;
  final int enclosureVersion;
  final VoidCallback? onSaved;

  @override
  State<EnclosureCarePage> createState() => _EnclosureCarePageState();
}

class _EnclosureCarePageState extends State<EnclosureCarePage> {
  final _reason = TextEditingController();
  String _type = 'full';
  bool _busy = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    if (!widget.controller.canWrite) {
      showIosMessage(
        context,
        _writeRestrictionMessage(widget.controller, '记录清洁'),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.controller.recordCleaning(
        I2CleaningDraft(
          enclosureId: widget.enclosureId,
          type: _type,
          completedAt: DateTime.now(),
          enclosureVersion: widget.enclosureVersion,
          reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
        ),
      );
      if (mounted &&
          widget.controller.actionState.status == I2AsyncStatus.data) {
        showIosMessage(context, '清洁记录已保存');
        widget.onSaved?.call();
      } else if (mounted && widget.controller.actionState.message != null) {
        showIosMessage(context, widget.controller.actionState.message!);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final canWrite = widget.controller.canWrite && !_busy;
      return Scaffold(
        appBar: AppBar(title: const Text('记录笼舍清洁')),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            I2OfflineBanner(
              offline: widget.controller.offline,
              lastSyncLabel: widget.controller.lastSyncLabel,
            ),
            if (!widget.controller.hasWritePermission &&
                !widget.controller.offline)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: IosBanner(
                  icon: CupertinoIcons.lock_shield,
                  color: IosColors.systemOrange,
                  text: '当前角色没有记录笼舍清洁的权限。',
                ),
              ),
            const IosBanner(
              icon: CupertinoIcons.info_circle,
              color: IosColors.systemTeal,
              text: '这里记录环境维护。需要隔离时，请在“入住 / 移笼”中选择隔离。',
            ),
            const SizedBox(height: 16),
            const IosSectionHeader('清洁记录'),
            IosGroupedSection(
              margin: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: IosPickerField<String>(
                    label: '清洁类型',
                    selected: _type,
                    items: const [
                      IosPickerItem(value: 'full', label: '全面清洁'),
                      IosPickerItem(value: 'partial', label: '局部清洁'),
                      IosPickerItem(value: 'disinfection', label: '消毒'),
                    ],
                    enabled: canWrite,
                    onSelected: (value) {
                      if (value != null) setState(() => _type = value);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: TextField(
                    controller: _reason,
                    enabled: canWrite,
                    textInputAction: TextInputAction.done,
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      labelText: '原因 / 备注',
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            I2WriteButton(
              enabled: canWrite,
              label: _busy ? '保存中…' : '记录清洁',
              disabledLabel: _busy
                  ? '保存中…'
                  : !widget.controller.hasWritePermission
                  ? '记录清洁（无编辑权限）'
                  : '记录清洁（联网后可用）',
              icon: CupertinoIcons.sparkles,
              onPressed: _save,
            ),
            const SizedBox(height: 12),
            Text(
              '需要隔离时，请在入住 / 移笼时选择“隔离”。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    },
  );
}
