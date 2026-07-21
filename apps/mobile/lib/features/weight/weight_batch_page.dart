import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_controller.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'weight_alerts.dart';

/// Batch gram weight entry for active hamsters (T-P0-04).
class WeightBatchPage extends StatefulWidget {
  const WeightBatchPage({super.key, required this.controller, this.onSaved});

  final I2Controller controller;
  final VoidCallback? onSaved;

  @override
  State<WeightBatchPage> createState() => _WeightBatchPageState();
}

class _WeightBatchPageState extends State<WeightBatchPage> {
  final Map<String, TextEditingController> _controllers = {};
  Map<String, String> _fieldErrors = const <String, String>{};
  bool _busy = false;

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

  void _clearFieldError(String hamsterId) {
    if (!_fieldErrors.containsKey(hamsterId)) return;
    setState(() {
      final next = Map<String, String>.from(_fieldErrors)..remove(hamsterId);
      _fieldErrors = next;
    });
  }

  Future<void> _save(List<I2Hamster> hamsters) async {
    if (_busy ||
        widget.controller.actionState.status == I2AsyncStatus.loading) {
      return;
    }
    if (!widget.controller.canWrite) {
      showIosMessage(
        context,
        widget.controller.offline ? '当前为离线只读，联网后再提交体重' : '当前角色没有录入体重的权限',
      );
      return;
    }
    final drafts = <I2WeightDraft>[];
    final validationErrors = <String, String>{};
    final now = DateTime.now();
    for (final hamster in hamsters) {
      final raw = _controllerFor(hamster.id).text.trim().replaceAll(',', '.');
      if (raw.isEmpty) continue;
      final value = num.tryParse(raw);
      if (value == null || value <= 0) {
        validationErrors[hamster.id] = '请输入大于 0 的克值';
        continue;
      }
      drafts.add(
        I2WeightDraft(hamsterId: hamster.id, weightG: value, recordedAt: now),
      );
    }
    if (validationErrors.isNotEmpty) {
      setState(() => _fieldErrors = validationErrors);
      showIosMessage(context, '有 ${validationErrors.length} 条体重需要修正');
      return;
    }
    if (drafts.isEmpty) {
      showIosMessage(context, '请至少填写一只仓鼠的体重');
      return;
    }
    setState(() {
      _busy = true;
      _fieldErrors = const <String, String>{};
    });
    final result = await widget.controller.createWeightsBatch(drafts);
    if (!mounted) return;
    setState(() => _busy = false);
    if (result == null) {
      final message = widget.controller.actionState.message;
      if (message != null) showIosMessage(context, message);
      return;
    }
    for (final hamsterId in result.successfulHamsterIds) {
      _controllers[hamsterId]?.clear();
    }
    if (result.failures.isNotEmpty) {
      setState(() {
        _fieldErrors = {
          for (final failure in result.failures)
            if (failure.hamsterId != null) failure.hamsterId!: failure.message,
        };
      });
    }
    if (result.isCompleteSuccess) {
      final alerts = buildWeightAlerts(
        widget.controller.snapshotState.data?.recentWeights ??
            const <I2WeightRecord>[],
      );
      final savedIds = result.successfulHamsterIds.toSet();
      final alertCount = alerts
          .where((alert) => savedIds.contains(alert.hamsterId))
          .length;
      showIosMessage(
        context,
        alertCount == 0
            ? '已保存 ${result.successCount} 条体重'
            : '已保存 ${result.successCount} 条，其中 $alertCount 条需关注',
      );
      widget.onSaved?.call();
    } else if (result.isPartialSuccess) {
      showIosMessage(
        context,
        '已保存 ${result.successCount} 条，${result.failureCount} 条未保存',
      );
    } else {
      showIosMessage(context, '${result.failureCount} 条体重均未保存');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final snapshot = widget.controller.snapshotState.data;
        final hamsters = (snapshot?.hamsters ?? const <I2Hamster>[])
            .where((h) => h.lifecycleStatus == 'active')
            .toList();
        final alerts = {
          for (final a in buildWeightAlerts(
            snapshot?.recentWeights ?? const <I2WeightRecord>[],
          ))
            a.hamsterId: a,
        };
        final busy =
            _busy ||
            widget.controller.actionState.status == I2AsyncStatus.loading;
        final result = widget.controller.weightBatchResult;
        final canSubmit =
            widget.controller.canWrite && hamsters.isNotEmpty && !busy;

        return Scaffold(
          appBar: AppBar(title: const Text('批量称重')),
          body: Column(
            children: [
              I2OfflineBanner(
                offline: widget.controller.offline,
                lastSyncLabel: widget.controller.lastSyncLabel,
              ),
              if (!widget.controller.hasWritePermission &&
                  !widget.controller.offline)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看体重记录，批量录入已设为只读。',
                  ),
                ),
              if (result != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    key: const Key('weight-batch-result'),
                    icon: result.isCompleteSuccess
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.exclamationmark_triangle_fill,
                    color: result.isCompleteSuccess
                        ? IosColors.systemGreen
                        : result.isPartialSuccess
                        ? IosColors.systemOrange
                        : IosColors.systemRed,
                    text: _batchResultMessage(result, snapshot),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  '单位固定为克。留空会跳过该只；掉重或低于阈值会标记为需关注。',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: I2AsyncStateView<I2Snapshot>(
                  state: widget.controller.snapshotState,
                  onRetry: widget.controller.retry,
                  emptyBuilder: (context) => const I2StateMessage(
                    icon: CupertinoIcons.paw,
                    message: '没有可称重的在养仓鼠',
                  ),
                  builder: (loadedSnapshot) {
                    final active = loadedSnapshot.hamsters
                        .where((hamster) => hamster.lifecycleStatus == 'active')
                        .toList();
                    if (active.isEmpty) {
                      return const I2StateMessage(
                        icon: CupertinoIcons.paw,
                        message: '没有可称重的在养仓鼠',
                      );
                    }
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
                      children: [
                        IosGroupedSection(
                          children: [
                            for (final hamster in active)
                              _WeightRow(
                                hamster: hamster,
                                snapshot: loadedSnapshot,
                                alert: alerts[hamster.id],
                                controller: _controllerFor(hamster.id),
                                errorText: _fieldErrors[hamster.id],
                                enabled: widget.controller.canWrite && !busy,
                                onChanged: () => _clearFieldError(hamster.id),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: I2WriteButton(
                    enabled: canSubmit,
                    label: busy ? '保存中…' : '批量保存',
                    disabledLabel: busy
                        ? '保存中…'
                        : !widget.controller.hasWritePermission
                        ? '批量保存（无编辑权限）'
                        : widget.controller.offline
                        ? '批量保存（联网后可用）'
                        : '批量保存（暂无可录入仓鼠）',
                    icon: CupertinoIcons.checkmark_circle_fill,
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

String _batchResultMessage(I2WeightBatchResult result, I2Snapshot? snapshot) {
  if (result.isCompleteSuccess) {
    return '上次提交已保存 ${result.successCount} 条体重。';
  }
  final failedNames = result.failures
      .map((failure) => _batchHamsterLabel(snapshot, failure.hamsterId))
      .toSet()
      .take(3)
      .join('、');
  final names = failedNames.isEmpty ? '' : '（$failedNames）';
  if (result.isPartialSuccess) {
    return '上次提交已保存 ${result.successCount} 条，'
        '${result.failureCount} 条未保存$names。失败项已保留，可修正后再次提交。';
  }
  return '上次提交的 ${result.failureCount} 条体重均未保存$names。'
      '输入内容已保留，请检查后重试。';
}

String _batchHamsterLabel(I2Snapshot? snapshot, String? hamsterId) {
  if (hamsterId == null || hamsterId.isEmpty) return '未识别仓鼠';
  for (final hamster in snapshot?.hamsters ?? const <I2Hamster>[]) {
    if (hamster.id == hamsterId) {
      final name = hamster.name?.trim();
      return name == null || name.isEmpty ? hamster.internalCode : name;
    }
  }
  return '未识别仓鼠';
}

class _WeightRow extends StatelessWidget {
  const _WeightRow({
    required this.hamster,
    required this.snapshot,
    required this.controller,
    required this.enabled,
    required this.onChanged,
    this.alert,
    this.errorText,
  });

  final I2Hamster hamster;
  final I2Snapshot? snapshot;
  final WeightAlert? alert;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final abnormal = alert != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth < 330 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.2;
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hamster.displayName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: abnormal
                    ? IosColors.systemRed
                    : ScolvPalette.of(context).label,
              ),
            ),
            const SizedBox(height: 3),
            if (abnormal)
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    size: 14,
                    color: IosColors.systemRed,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      alert!.summary,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: IosColors.systemRed,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                '笼盒 ${_weightEnclosureLabel(snapshot, hamster.currentEnclosureId)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ScolvPalette.of(context).secondaryLabel,
                ),
              ),
          ],
        );
        final input = Semantics(
          label: '${hamster.displayName}体重，单位克',
          child: TextField(
            key: Key('batch-weight-input-${hamster.id}'),
            controller: controller,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            onChanged: (_) => onChanged(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
            decoration: InputDecoration(
              labelText: '体重',
              suffixText: 'g',
              errorText: errorText,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              fillColor: abnormal
                  ? IosColors.systemRed.withValues(alpha: 0.08)
                  : ScolvPalette.of(context).tertiaryFill,
            ),
          ),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [details, const SizedBox(height: 10), input],
                )
              : Row(
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: 12),
                    SizedBox(width: 112, child: input),
                  ],
                ),
        );
      },
    );
  }
}

String _weightEnclosureLabel(I2Snapshot? snapshot, String? enclosureId) {
  if (enclosureId == null || enclosureId.isEmpty) return '未分配';
  for (final enclosure in snapshot?.enclosures ?? const <I2Enclosure>[]) {
    if (enclosure.id == enclosureId) {
      return enclosure.code.isEmpty ? '已分配' : enclosure.code;
    }
  }
  return '已分配';
}
