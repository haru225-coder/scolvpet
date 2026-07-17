import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../i2/i2_controller.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'weight_alerts.dart';

/// Batch gram weight entry for active hamsters (T-P0-04).
class WeightBatchPage extends StatefulWidget {
  const WeightBatchPage({
    super.key,
    required this.controller,
    this.onSaved,
  });

  final I2Controller controller;
  final VoidCallback? onSaved;

  @override
  State<WeightBatchPage> createState() => _WeightBatchPageState();
}

class _WeightBatchPageState extends State<WeightBatchPage> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String hamsterId) {
    return _controllers.putIfAbsent(hamsterId, TextEditingController.new);
  }

  Future<void> _save(List<I2Hamster> hamsters) async {
    final drafts = <I2WeightDraft>[];
    final now = DateTime.now();
    for (final hamster in hamsters) {
      final raw = _controllerFor(hamster.id).text.trim();
      if (raw.isEmpty) continue;
      final value = num.tryParse(raw);
      if (value == null || value <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${hamster.displayName} 体重无效（需 > 0 g）')),
        );
        return;
      }
      drafts.add(
        I2WeightDraft(
          hamsterId: hamster.id,
          weightG: value,
          recordedAt: now,
        ),
      );
    }
    if (drafts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少填写一只仓鼠的体重')));
      return;
    }
    await widget.controller.createWeightsBatch(drafts);
    if (!mounted) return;
    if (widget.controller.actionState.status == I2AsyncStatus.data) {
      final alerts = buildWeightAlerts(
        widget.controller.snapshotState.data?.recentWeights ??
            const <I2WeightRecord>[],
      );
      final alertCount = alerts.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alertCount == 0
                ? '已保存 ${drafts.length} 条体重'
                : '已保存 ${drafts.length} 条，其中 $alertCount 条异常',
          ),
        ),
      );
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
        final snapshot = widget.controller.snapshotState.data;
        final hamsters =
            (snapshot?.hamsters ?? const <I2Hamster>[])
                .where((h) => h.lifecycleStatus == 'active')
                .toList();
        final alerts = {
          for (final a in buildWeightAlerts(
            snapshot?.recentWeights ?? const <I2WeightRecord>[],
          ))
            a.hamsterId: a,
        };
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;

        return Scaffold(
          appBar: AppBar(title: const Text('批量称重（g）')),
          body: Column(
            children: [
              I2OfflineBanner(
                offline: widget.controller.offline,
                lastSyncLabel: widget.controller.lastSyncLabel,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  '单位固定为克。留空表示跳过该只；掉重或低于阈值会在首页与列表高亮。',
                  style: TextStyle(color: Color(0xff6c7774), fontSize: 13),
                ),
              ),
              Expanded(
                child: hamsters.isEmpty
                    ? const Center(child: Text('没有在养仓鼠'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: hamsters.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final hamster = hamsters[index];
                          final alert = alerts[hamster.id];
                          return Card(
                            color: alert == null
                                ? null
                                : const Color(0xffffe8e5),
                            child: ListTile(
                              title: Text(hamster.displayName),
                              subtitle: alert == null
                                  ? Text('笼盒 ${hamster.currentEnclosureId ?? '未分配'}')
                                  : Text(
                                      '⚠ ${alert.summary}',
                                      style: const TextStyle(
                                        color: Color(0xffb6534a),
                                      ),
                                    ),
                              trailing: SizedBox(
                                width: 96,
                                child: TextField(
                                  controller: _controllerFor(hamster.id),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]'),
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                    labelText: 'g',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: I2WriteButton(
                    enabled: widget.controller.canWrite && !busy,
                    label: busy ? '保存中…' : '批量保存',
                    icon: Icons.save_outlined,
                    onPressed: () => _save(hamsters),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
