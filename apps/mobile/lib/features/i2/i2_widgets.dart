import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
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
        return const IosLoading(showSkeleton: true);
      case I2AsyncStatus.data:
        return state.data == null
            ? const SizedBox.shrink()
            : builder(state.data as T);
      case I2AsyncStatus.empty:
        return emptyBuilder?.call(context) ??
            I2StateMessage(
              icon: CupertinoIcons.tray,
              message: state.message ?? '暂无数据',
              onRetry: state.retryable ? onRetry : null,
            );
      case I2AsyncStatus.conflict:
        return I2StateMessage(
          icon: CupertinoIcons.exclamationmark_triangle,
          message: state.message ?? '数据存在冲突，请刷新后重试',
          actionLabel: '重新检查',
          onRetry: onRetry,
          tone: IosColors.systemOrange,
        );
      case I2AsyncStatus.error:
        return I2StateMessage(
          icon: CupertinoIcons.cloud,
          message: state.message ?? '请求未完成，请稍后重试',
          actionLabel: '重试',
          onRetry: state.retryable ? onRetry : null,
          tone: IosColors.systemRed,
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
    this.subtitle,
    this.actionLabel,
    this.onRetry,
    this.tone,
    this.illustration,
    this.mood = BearMood.sleepy,
  });

  final IconData icon;
  final String message;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final Color? tone;
  final String? illustration;
  final BearMood mood;

  String get _defaultSubtitle {
    if (subtitle != null && subtitle!.trim().isNotEmpty) return subtitle!;
    final action = actionLabel?.trim() ?? '';
    if (action.contains('新建') || action.contains('创建')) {
      return '点下方开始录入，或从数据中心导入。';
    }
    if (onRetry != null) return '下拉或点重试，同步最新记录。';
    return '新建或同步记录后会显示在这里。';
  }

  String get _defaultIllustration {
    if (illustration != null) return illustration!;
    if (mood == BearMood.worried) return BearAssets.emptyAttention;
    if (mood == BearMood.happy) return BearAssets.emptyCare;
    return BearAssets.emptyList;
  }

  @override
  Widget build(BuildContext context) {
    final color = tone ?? ScolvPalette.of(context).secondaryLabel;
    final isError =
        tone == IosColors.systemRed || tone == IosColors.systemOrange;
    if (!isError) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: BearEmptyCard(
            title: message,
            subtitle: _defaultSubtitle,
            mood: mood,
            illustration: _defaultIllustration,
            actionLabel: onRetry == null ? null : (actionLabel ?? '重试'),
            onAction: onRetry,
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: IosBanner(
          icon: icon,
          text: message,
          color: color,
          actionLabel: onRetry == null ? null : (actionLabel ?? '重试'),
          onAction: onRetry,
        ),
      ),
    );
  }
}

class I2OfflineBanner extends StatelessWidget {
  const I2OfflineBanner({super.key, required this.offline, this.lastSyncLabel});

  final bool offline;
  final String? lastSyncLabel;

  @override
  Widget build(BuildContext context) {
    if (!offline) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: IosBanner(
        icon: CupertinoIcons.cloud,
        color: IosColors.systemOrange,
        text: lastSyncLabel == null
            ? '离线只读 · 联网后重新提交/再操作'
            : '离线只读 · 最近同步 $lastSyncLabel',
      ),
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
    this.disabledLabel,
  });

  final bool enabled;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? disabledLabel;

  @override
  Widget build(BuildContext context) => IosPrimaryButton(
    label: enabled ? label : (disabledLabel ?? '$label（暂不可用）'),
    icon: icon ?? CupertinoIcons.pencil,
    onPressed: enabled ? onPressed : null,
  );
}

class I2InfoTile extends StatelessWidget {
  const I2InfoTile({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ScolvPalette.of(context).secondaryLabel,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    ),
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
  _ => '状态待更新',
};

/// 繁育状态展示（领域码不变，仅中文标签）。
String i2BreedingStatusLabel(String value) {
  final v = value.trim().toLowerCase();
  if (v.isEmpty) return '—';
  return switch (v) {
    'candidate' => '候选',
    'pairing' || 'pair' || 'pair_ready' => '配对中',
    'post_pair' => '配对后观察',
    'gestating' || 'gestation' || 'pregnant' || 'expecting' => '孕期',
    'nursing' || 'litter_nursing' => '育仔中',
    'resting' || 'rest' => '休养',
    'retired' => '繁育退役',
    'hold' => '暂缓',
    _ => value.trim(),
  };
}

String i2EnclosureStateLabel(String value) => switch (value) {
  'vacant' => '空置',
  'occupied' || 'occupied_single' => '在住',
  'pairing_temp' => '临时配对',
  'gestation' => '孕期',
  'dam_with_litter' => '母带崽',
  'isolation' => '隔离',
  'quarantine' => '隔离检疫',
  'cleaning_due' => '待清洁',
  'disabled' || 'out_of_service' => '停用',
  _ => '状态待更新',
};

String i2CleanlinessLabel(String value) => switch (value) {
  'clean' => '干净',
  'dirty' || 'soiled' => '需要清洁',
  'needs_clean' || 'needs_cleaning' => '待清洁',
  'disinfecting' => '消毒中',
  _ => '状态待更新',
};

String i2CleaningTypeLabel(String value) => switch (value) {
  'full' => '全面清洁',
  'partial' => '局部清洁',
  'disinfection' => '消毒',
  _ => '清洁记录',
};

String i2StayPurposeLabel(String value) => switch (value) {
  'single' => '单住',
  'pairing_temp' => '临时配对',
  'gestation' => '孕期',
  'isolation' || 'quarantine' => '隔离',
  'dam_with_litter' => '母带崽',
  _ => '入住',
};

/// Board visual tone for enclosure cards (T-P0-08).
enum EnclosureBoardTone {
  vacant,
  occupied,
  pairing,
  gestation,
  isolation,
  dirty,
  disabled,
}

EnclosureBoardTone enclosureBoardTone(I2Enclosure enclosure) {
  final state = enclosure.state.toLowerCase();
  final clean = enclosure.cleanlinessState.toLowerCase();
  if (state == 'disabled' || state == 'out_of_service') {
    return EnclosureBoardTone.disabled;
  }
  if (state == 'isolation' || state == 'quarantine') {
    return EnclosureBoardTone.isolation;
  }
  if (state.contains('gestat') || state == 'dam_with_litter') {
    return EnclosureBoardTone.gestation;
  }
  if (state.contains('pair')) {
    return EnclosureBoardTone.pairing;
  }
  if (clean.contains('dirty') ||
      clean.contains('soil') ||
      clean == 'needs_clean' ||
      clean == 'needs_cleaning' ||
      state == 'cleaning_due') {
    return EnclosureBoardTone.dirty;
  }
  if (state == 'vacant' ||
      state == 'empty' ||
      enclosure.currentHamsterIds.isEmpty) {
    if (state.contains('occup') && enclosure.currentHamsterIds.isNotEmpty) {
      return EnclosureBoardTone.occupied;
    }
    if (state == 'vacant' ||
        state == 'empty' ||
        enclosure.currentHamsterIds.isEmpty) {
      return EnclosureBoardTone.vacant;
    }
  }
  return EnclosureBoardTone.occupied;
}

Color enclosureBoardColor(BuildContext context, EnclosureBoardTone tone) {
  final p = ScolvPalette.of(context);
  return switch (tone) {
    EnclosureBoardTone.vacant => p.secondaryGroupedBackground,
    EnclosureBoardTone.occupied => const Color(0xffe8f8ef),
    EnclosureBoardTone.pairing => p.accentSoft,
    EnclosureBoardTone.gestation => const Color(0xfff3e8ff),
    EnclosureBoardTone.isolation => const Color(0xffffe5e3),
    EnclosureBoardTone.dirty => const Color(0xfffff6e0),
    EnclosureBoardTone.disabled => p.tertiaryFill,
  };
}

Color enclosureBoardAccent(BuildContext context, EnclosureBoardTone tone) {
  final p = ScolvPalette.of(context);
  return switch (tone) {
    EnclosureBoardTone.vacant => p.secondaryLabel,
    EnclosureBoardTone.occupied => IosColors.systemGreen,
    EnclosureBoardTone.pairing => p.accent,
    EnclosureBoardTone.gestation => IosColors.systemPurple,
    EnclosureBoardTone.isolation => IosColors.systemRed,
    EnclosureBoardTone.dirty => IosColors.systemOrange,
    EnclosureBoardTone.disabled => p.tertiaryLabel,
  };
}

String enclosureBoardToneLabel(EnclosureBoardTone tone) => switch (tone) {
  EnclosureBoardTone.vacant => '空置',
  EnclosureBoardTone.occupied => '在住',
  EnclosureBoardTone.pairing => '配对',
  EnclosureBoardTone.gestation => '孕期/带崽',
  EnclosureBoardTone.isolation => '隔离',
  EnclosureBoardTone.dirty => '待清洁',
  EnclosureBoardTone.disabled => '停用',
};

String i2LitterStateLabel(String value) => switch (value) {
  'newborn' => '新生',
  'nursing' => '哺乳',
  'weaning_due' => '待断奶',
  'sexing_due' => '待分性',
  'individualizing' => '待个体化',
  'closed' => '已关闭',
  'voided' => '已作废',
  _ => '状态待更新',
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
  return '${i2DateLabel(value)} ${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}
