import 'package:flutter/material.dart';

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
    final draft = await Navigator.of(context).push<HealthRecordDraft>(
      MaterialPageRoute(
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (ok) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
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
                onPressed: () =>
                    widget.controller.loadForHamster(widget.hamsterId),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: widget.canWrite
              ? FloatingActionButton.extended(
                  key: const Key('health-quick-add'),
                  onPressed: _openCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('快捷记录'),
                )
              : null,
          body: I2AsyncStateView<List<HealthRecordItem>>(
            state: widget.controller.listState,
            onRetry: () => widget.controller.loadForHamster(widget.hamsterId),
            emptyBuilder: (context) => const I2StateMessage(
              icon: Icons.health_and_safety_outlined,
              message: '暂无健康记录，点右下角快捷录入',
            ),
            builder: (records) {
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                itemCount: records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final record = records[index];
                  return Card(
                    key: Key('health-card-${record.id}'),
                    child: ListTile(
                      leading: Icon(
                        switch (record.type) {
                          'medication' => Icons.medication_outlined,
                          'anomaly' => Icons.warning_amber_outlined,
                          'isolation' => Icons.health_and_safety_outlined,
                          'death' => Icons.heart_broken_outlined,
                          _ => Icons.fact_check_outlined,
                        },
                        color: record.type == 'anomaly' ||
                                record.severity == 'high' ||
                                record.severity == 'critical'
                            ? const Color(0xffb6534a)
                            : const Color(0xffc77852),
                      ),
                      title: Text(
                        record.typeLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        [
                          _fmt(record.observedAt),
                          '严重度 ${healthSeverityLabel(record.severity)}',
                          if (record.followUpAt != null)
                            '复查 ${_fmt(record.followUpAt!)}',
                          if (record.notes != null && record.notes!.isNotEmpty)
                            record.notes!,
                        ].join('\n'),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
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
  final _notes = TextEditingController();
  final _medName = TextEditingController();
  bool _needFollowUp = false;
  int _followUpDays = 3;

  @override
  void dispose() {
    _notes.dispose();
    _medName.dispose();
    super.dispose();
  }

  void _submit() {
    final now = DateTime.now().toUtc();
    final med = <String, dynamic>{};
    if (_medName.text.trim().isNotEmpty) {
      med['name'] = _medName.text.trim();
    }
    final draft = HealthRecordDraft(
      hamsterId: widget.hamsterId,
      type: _type,
      observedAt: now,
      severity: _severity,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      followUpAt: _needFollowUp
          ? now.add(Duration(days: _followUpDays))
          : null,
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
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '一键记录日常检查、异常、用药或隔离；勾选复查将同步创建护理任务。',
            style: TextStyle(color: Color(0xff6c7774), fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in healthQuickTypes)
                ChoiceChip(
                  key: Key('health-type-$type'),
                  label: Text(healthTypeLabel(type)),
                  selected: _type == type,
                  onSelected: widget.canWrite
                      ? (_) => setState(() => _type = type)
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            key: const Key('health-severity'),
            initialValue: _severity,
            decoration: const InputDecoration(
              labelText: '严重度',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('未标')),
              DropdownMenuItem(value: 'info', child: Text('信息')),
              DropdownMenuItem(value: 'low', child: Text('低')),
              DropdownMenuItem(value: 'medium', child: Text('中')),
              DropdownMenuItem(value: 'high', child: Text('高')),
              DropdownMenuItem(value: 'critical', child: Text('危急')),
            ],
            onChanged: widget.canWrite
                ? (value) => setState(() => _severity = value)
                : null,
          ),
          if (_type == 'medication') ...[
            const SizedBox(height: 12),
            TextField(
              key: const Key('health-med-name'),
              controller: _medName,
              decoration: const InputDecoration(
                labelText: '药品 / 方案',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            key: const Key('health-notes'),
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: '备注',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            key: const Key('health-follow-up-switch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('需要复查并创建任务'),
            subtitle: Text(
              _needFollowUp ? '$_followUpDays 天后提醒' : '不创建复查任务',
            ),
            value: _needFollowUp,
            onChanged: widget.canWrite
                ? (value) => setState(() => _needFollowUp = value)
                : null,
          ),
          if (_needFollowUp)
            Row(
              children: [
                const Text('复查间隔（天）'),
                Expanded(
                  child: Slider(
                    key: const Key('health-follow-up-days'),
                    value: _followUpDays.toDouble(),
                    min: 1,
                    max: 14,
                    divisions: 13,
                    label: '$_followUpDays',
                    onChanged: widget.canWrite
                        ? (v) => setState(() => _followUpDays = v.round())
                        : null,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const Key('health-save'),
            onPressed: widget.canWrite ? _submit : null,
            icon: const Icon(Icons.save_outlined),
            label: const Text('保存记录'),
          ),
        ],
      ),
    );
  }
}
