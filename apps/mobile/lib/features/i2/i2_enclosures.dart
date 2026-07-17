import 'package:flutter/material.dart';

import 'i2_controller.dart';
import 'i2_models.dart';
import 'i2_widgets.dart';

class EnclosureGridPage extends StatelessWidget {
  const EnclosureGridPage({
    super.key,
    required this.controller,
    this.onOpenDetail,
  });

  final I2Controller controller;
  final ValueChanged<I2Enclosure>? onOpenDetail;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('笼舍'),
        actions: [
          IconButton(
            onPressed: controller.retry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          I2OfflineBanner(
            offline: controller.offline,
            lastSyncLabel: controller.lastSyncLabel,
          ),
          Expanded(
            child: I2AsyncStateView<I2Snapshot>(
              state: controller.snapshotState,
              onRetry: controller.retry,
              builder: (snapshot) {
                if (snapshot.enclosures.isEmpty) {
                  return const I2StateMessage(
                    icon: Icons.grid_view_outlined,
                    message: '暂无笼盒记录',
                  );
                }
                final racks = <String, Map<String, List<I2Enclosure>>>{};
                for (final enclosure in snapshot.enclosures) {
                  racks
                      .putIfAbsent(
                        enclosure.rackLabel,
                        () => <String, List<I2Enclosure>>{},
                      )
                      .putIfAbsent(enclosure.levelLabel, () => <I2Enclosure>[])
                      .add(enclosure);
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const _EnclosureLegend(),
                    const SizedBox(height: 12),
                    ...racks.entries.map(
                      (rack) => Card(
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Text('笼架 ${rack.key}'),
                          children: rack.value.entries
                              .map(
                                (level) => Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    12,
                                    12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '层位 ${level.key}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelLarge,
                                      ),
                                      const SizedBox(height: 8),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              crossAxisSpacing: 8,
                                              mainAxisSpacing: 8,
                                              childAspectRatio: 1.35,
                                            ),
                                        itemCount: level.value.length,
                                        itemBuilder: (context, index) {
                                          final enclosure = level.value[index];
                                          return _EnclosureBoardTile(
                                            enclosure: enclosure,
                                            onTap: onOpenDetail == null
                                                ? null
                                                : () =>
                                                      onOpenDetail!(enclosure),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
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
                  color: enclosureBoardColor(tone),
                  border: Border.all(color: enclosureBoardAccent(tone)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                enclosureBoardToneLabel(tone),
                style: const TextStyle(fontSize: 11, color: Color(0xff6c7774)),
              ),
            ],
          ),
      ],
    );
  }
}

class _EnclosureBoardTile extends StatelessWidget {
  const _EnclosureBoardTile({required this.enclosure, this.onTap});

  final I2Enclosure enclosure;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = enclosureBoardTone(enclosure);
    final accent = enclosureBoardAccent(tone);
    final occupants = enclosure.currentHamsterIds.length;
    return InkWell(
      key: Key('enclosure-tile-${enclosure.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: enclosureBoardColor(tone),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: accent, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    enclosure.code,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  switch (tone) {
                    EnclosureBoardTone.isolation => Icons.health_and_safety,
                    EnclosureBoardTone.dirty => Icons.cleaning_services,
                    EnclosureBoardTone.vacant => Icons.crop_square,
                    _ => Icons.pets,
                  },
                  size: 16,
                  color: accent,
                ),
              ],
            ),
            const Spacer(),
            Text(
              i2EnclosureStateLabel(enclosure.state),
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              occupants == 0 ? '无人入住' : '在住 $occupants',
              style: const TextStyle(fontSize: 12, color: Color(0xff6c7774)),
            ),
            Text(
              enclosureBoardTone(enclosure) == EnclosureBoardTone.dirty ||
                      enclosure.cleanlinessState.toLowerCase() != 'clean'
                  ? '待清洁'
                  : '清洁正常',
              style: TextStyle(
                fontSize: 11,
                color:
                    enclosureBoardTone(enclosure) == EnclosureBoardTone.dirty
                    ? const Color(0xff8a6d3b)
                    : const Color(0xff3d7a62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnclosureDetailPage extends StatefulWidget {
  const EnclosureDetailPage({
    super.key,
    required this.controller,
    required this.enclosureId,
    this.onMove,
    this.onCare,
  });

  final I2Controller controller;
  final String enclosureId;
  final VoidCallback? onMove;
  final VoidCallback? onCare;

  @override
  State<EnclosureDetailPage> createState() => _EnclosureDetailPageState();
}

class _EnclosureDetailPageState extends State<EnclosureDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadEnclosureDetail(widget.enclosureId);
    widget.controller.loadCleaningHistory(widget.enclosureId);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('笼盒详情')),
      body: Column(
        children: [
          I2OfflineBanner(
            offline: widget.controller.offline,
            lastSyncLabel: widget.controller.lastSyncLabel,
          ),
          Expanded(
            child: I2AsyncStateView<I2EnclosureDetail>(
              state: widget.controller.enclosureDetailState,
              onRetry: () =>
                  widget.controller.loadEnclosureDetail(widget.enclosureId),
              builder: (detail) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(detail.enclosure.code),
                          subtitle: Text(
                            i2EnclosureStateLabel(detail.enclosure.state),
                          ),
                          trailing: Chip(
                            label: Text(detail.enclosure.cleanlinessState),
                          ),
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
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (widget.onMove != null)
                        I2WriteButton(
                          enabled: widget.controller.canWrite,
                          label: '入住 / 移笼 · A05',
                          icon: Icons.swap_horiz,
                          onPressed: widget.onMove,
                        ),
                      if (widget.onCare != null)
                        I2WriteButton(
                          enabled: widget.controller.canWrite,
                          label: '清洁 / 隔离 · A06',
                          icon: Icons.cleaning_services_outlined,
                          onPressed: widget.onCare,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '入住与移笼历史',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (detail.stays.isEmpty)
                    const Text('暂无入住记录')
                  else
                    ...detail.stays.map(
                      (stay) => Card(
                        child: ListTile(
                          leading: Icon(
                            stay.endedAt == null ? Icons.login : Icons.logout,
                          ),
                          title: Text('${stay.hamsterId} · ${stay.purpose}'),
                          subtitle: Text(
                            '${i2DateTimeLabel(stay.startedAt)} → ${i2DateTimeLabel(stay.endedAt)}'
                            '${stay.reason == null ? '' : '\n${stay.reason}'}',
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text('清洁历史', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  I2AsyncStateView<List<I2CleaningRecord>>(
                    state: widget.controller.cleaningState,
                    onRetry: () => widget.controller.loadCleaningHistory(
                      widget.enclosureId,
                    ),
                    builder: (records) => Column(
                      children: records
                          .map(
                            (record) => Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.cleaning_services_outlined,
                                ),
                                title: Text(
                                  record.type == 'partial' ? '局部清洁' : '全面清洁',
                                ),
                                subtitle: Text(
                                  '${i2DateTimeLabel(record.completedAt)}'
                                  '${record.reason == null ? '' : ' · ${record.reason}'}',
                                ),
                                trailing: record.healthRecordId == null
                                    ? null
                                    : const Icon(
                                        Icons.health_and_safety_outlined,
                                      ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
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
  final _hamsterId = TextEditingController();
  final _reason = TextEditingController();
  String _purpose = 'single';
  String? _selectedHamsterId;

  @override
  void dispose() {
    _hamsterId.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final hamsterId = (_selectedHamsterId ?? _hamsterId.text).trim();
    if (hamsterId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择或填写仓鼠')));
      return;
    }
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('移笼 / 入住已提交')));
      widget.onSaved?.call();
    } else if (widget.controller.actionState.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.controller.actionState.message!)),
      );
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
            .where((h) => h.lifecycleStatus.toLowerCase() != 'archived')
            .toList();
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(title: const Text('入住 / 移笼 · A05')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                '将仓鼠移入本笼盒并写入 enclosure stay；原笼状态会在服务端/内存仓库中同步。',
                style: TextStyle(color: Color(0xff6c7774), fontSize: 13),
              ),
              const SizedBox(height: 12),
              if (active.isNotEmpty)
                DropdownButtonFormField<String>(
                  key: const Key('move-hamster-picker'),
                  initialValue: _selectedHamsterId,
                  decoration: const InputDecoration(
                    labelText: '选择仓鼠 *',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final h in active)
                      DropdownMenuItem(
                        value: h.id,
                        child: Text(
                          '${h.displayName}'
                          '${h.currentEnclosureId == null ? '' : ' · 现 ${h.currentEnclosureId}'}',
                        ),
                      ),
                  ],
                  onChanged: widget.controller.canWrite && !busy
                      ? (value) => setState(() {
                          _selectedHamsterId = value;
                          _hamsterId.text = value ?? '';
                        })
                      : null,
                )
              else
                TextField(
                  key: const Key('move-hamster-id'),
                  controller: _hamsterId,
                  decoration: const InputDecoration(
                    labelText: '仓鼠 ID *',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const Key('move-purpose'),
                initialValue: _purpose,
                decoration: const InputDecoration(labelText: '用途 / 入住类型'),
                items: const [
                  DropdownMenuItem(value: 'single', child: Text('单住')),
                  DropdownMenuItem(value: 'pairing_temp', child: Text('临时配对')),
                  DropdownMenuItem(value: 'gestation', child: Text('孕期')),
                  DropdownMenuItem(value: 'isolation', child: Text('隔离')),
                  DropdownMenuItem(value: 'dam_with_litter', child: Text('母带崽')),
                ],
                onChanged: widget.controller.canWrite && !busy
                    ? (value) => setState(() => _purpose = value!)
                    : null,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reason,
                decoration: const InputDecoration(
                  labelText: '原因 / 备注',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              I2WriteButton(
                enabled: widget.controller.canWrite && !busy,
                label: busy ? '提交中…' : '提交移笼 / 入住',
                icon: Icons.swap_horiz,
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
  final _healthRecordId = TextEditingController();
  String _type = 'full';

  @override
  void dispose() {
    _reason.dispose();
    _healthRecordId.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.controller.recordCleaning(
      I2CleaningDraft(
        enclosureId: widget.enclosureId,
        type: _type,
        completedAt: DateTime.now(),
        enclosureVersion: widget.enclosureVersion,
        reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
        healthRecordId: _healthRecordId.text.trim().isEmpty
            ? null
            : _healthRecordId.text.trim(),
      ),
    );
    if (mounted && widget.controller.actionState.status == I2AsyncStatus.data) {
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('清洁 / 隔离 · A06')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: const InputDecoration(labelText: '清洁类型'),
          items: const [
            DropdownMenuItem(value: 'full', child: Text('全面清洁')),
            DropdownMenuItem(value: 'partial', child: Text('局部清洁')),
            DropdownMenuItem(value: 'disinfection', child: Text('消毒')),
          ],
          onChanged: widget.controller.canWrite
              ? (value) => setState(() => _type = value!)
              : null,
        ),
        TextField(
          controller: _reason,
          decoration: const InputDecoration(labelText: '原因 / 备注'),
        ),
        TextField(
          controller: _healthRecordId,
          decoration: const InputDecoration(labelText: '关联健康记录 ID（可选）'),
        ),
        const SizedBox(height: 20),
        I2WriteButton(
          enabled: widget.controller.canWrite,
          label: '记录清洁',
          icon: Icons.cleaning_services_outlined,
          onPressed: _save,
        ),
        const SizedBox(height: 8),
        const Text('隔离请从入住 / 移笼动作选择“隔离”用途，以保留完整入住历史。'),
      ],
    ),
  );
}
