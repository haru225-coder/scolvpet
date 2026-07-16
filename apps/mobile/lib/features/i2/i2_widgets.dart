import 'package:flutter/material.dart';

import 'i2_models.dart';

class I2AsyncStateView<T> extends StatelessWidget {
  const I2AsyncStateView({
    super.key,
    required this.state,
    required this.onRetry,
    required this.builder,
    this.emptyBuilder,
  });

  final I2AsyncState<T> state;
  final VoidCallback onRetry;
  final Widget Function(T value) builder;
  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case I2AsyncStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case I2AsyncStatus.data:
        return state.data == null
            ? const SizedBox.shrink()
            : builder(state.data as T);
      case I2AsyncStatus.empty:
        return emptyBuilder?.call(context) ??
            I2StateMessage(
              icon: Icons.inbox_outlined,
              message: state.message ?? '暂无数据',
              onRetry: state.retryable ? onRetry : null,
            );
      case I2AsyncStatus.conflict:
        return I2StateMessage(
          icon: Icons.warning_amber_rounded,
          message: state.message ?? '数据存在冲突，请刷新后重试',
          actionLabel: '重新检查',
          onRetry: onRetry,
          tone: Colors.orange,
        );
      case I2AsyncStatus.error:
        return I2StateMessage(
          icon: Icons.cloud_off_outlined,
          message: state.message ?? '请求未完成，请稍后重试',
          actionLabel: '重试',
          onRetry: state.retryable ? onRetry : null,
          tone: Colors.redAccent,
        );
      case I2AsyncStatus.idle:
        return const SizedBox.shrink();
    }
  }
}

class I2StateMessage extends StatelessWidget {
  const I2StateMessage({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onRetry,
    this.tone,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final Color? tone;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: tone ?? Colors.grey),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(actionLabel ?? '重试'),
            ),
          ],
        ],
      ),
    ),
  );
}

class I2OfflineBanner extends StatelessWidget {
  const I2OfflineBanner({super.key, required this.offline, this.lastSyncLabel});

  final bool offline;
  final String? lastSyncLabel;

  @override
  Widget build(BuildContext context) {
    if (!offline) return const SizedBox.shrink();
    return MaterialBanner(
      leading: const Icon(Icons.offline_bolt_outlined),
      content: Text(
        lastSyncLabel == null
            ? '离线只读 · 联网后重新提交/再操作'
            : '离线只读 · 最近同步 $lastSyncLabel',
      ),
      actions: const [SizedBox.shrink()],
    );
  }
}

class I2WriteButton extends StatelessWidget {
  const I2WriteButton({
    super.key,
    required this.enabled,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final bool enabled;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: enabled ? onPressed : null,
    icon: Icon(icon ?? Icons.edit_outlined),
    label: Text(enabled ? label : '$label（联网后可用）'),
  );
}

class I2InfoTile extends StatelessWidget {
  const I2InfoTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    title: Text(label, style: Theme.of(context).textTheme.labelMedium),
    subtitle: Text(value.isEmpty ? '—' : value),
  );
}

String i2SexLabel(String value) => switch (value) {
  'male' => '公',
  'female' => '母',
  _ => '待定',
};

String i2LifecycleLabel(String value) => switch (value) {
  'active' => '在养',
  'transferred' => '已转出',
  'retired' => '已退役',
  'deceased' => '已离世',
  _ => value,
};

String i2EnclosureStateLabel(String value) => switch (value) {
  'vacant' => '空置',
  'occupied_single' => '单住',
  'pairing_temp' => '临时配对',
  'gestation' => '孕期',
  'dam_with_litter' => '母带崽',
  'isolation' => '隔离',
  'cleaning_due' => '待清洁',
  'disabled' => '停用',
  _ => value,
};

String i2LitterStateLabel(String value) => switch (value) {
  'newborn' => '新生',
  'nursing' => '哺乳',
  'weaning_due' => '待断奶',
  'sexing_due' => '待分性',
  'individualizing' => '待个体化',
  'closed' => '已关闭',
  'voided' => '已作废',
  _ => value,
};

String i2DateLabel(DateTime? value) {
  if (value == null) return '—';
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}

String i2DateTimeLabel(DateTime? value) {
  if (value == null) return '—';
  final local = value.toLocal();
  return '${i2DateLabel(value)} ${local.hour.toString().padLeft(2, '0')}:​'
      '${local.minute.toString().padLeft(2, '0')}';
}
