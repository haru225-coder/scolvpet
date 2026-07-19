import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/bear_motion.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2.dart';
import '../tasks/tasks.dart';
import '../weight/weight_alerts.dart';
import 'today_care_queue.dart';

/// Pure aggregation over the I2 domain snapshot for the home dashboard.
class HomeOverviewMetrics {
  const HomeOverviewMetrics({
    required this.hamsterCount,
    required this.enclosureCount,
    required this.activeLitterCount,
    required this.pendingWeanOrSexCount,
    required this.gestatingDamCount,
    required this.dirtyEnclosureCount,
    required this.draftCount,
    required this.weightAlertCount,
    required this.offline,
    this.lastSyncLabel,
    this.organizationName,
    this.weightAlerts = const <WeightAlert>[],
  });

  final int hamsterCount;
  final int enclosureCount;
  final int activeLitterCount;
  final int pendingWeanOrSexCount;
  final int gestatingDamCount;
  final int dirtyEnclosureCount;
  final int draftCount;
  final int weightAlertCount;
  final bool offline;
  final String? lastSyncLabel;
  final String? organizationName;
  final List<WeightAlert> weightAlerts;

  /// Base attention without open care tasks (tasks injected at page level).
  int get attentionCount =>
      pendingWeanOrSexCount +
      gestatingDamCount +
      dirtyEnclosureCount +
      draftCount +
      weightAlertCount;

  int attentionWithTasks(int openTaskCount) => attentionCount + openTaskCount;

  factory HomeOverviewMetrics.fromSnapshot({
    required I2Snapshot? snapshot,
    required List<I2Draft> drafts,
    required bool offline,
    String? lastSyncLabel,
    String? organizationName,
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final hamsters = snapshot?.hamsters ?? const <I2Hamster>[];
    final litters = snapshot?.litters ?? const <I2Litter>[];
    final enclosures = snapshot?.enclosures ?? const <I2Enclosure>[];

    final activeHamsters = hamsters
        .where((h) => h.lifecycleStatus.toLowerCase() != 'archived')
        .length;

    final activeLitters = litters.where(_isActiveLitter).toList();
    final pendingWeanOrSex = activeLitters.where((litter) {
      final ageDays = clock.difference(litter.bornAt).inDays;
      final state = litter.state.toLowerCase();
      if (state.contains('wean') ||
          state.contains('sex') ||
          state.contains('separat') ||
          state.contains('individual')) {
        return true;
      }
      // Nursing litters past typical weaning window need attention.
      if (state.contains('nurs') || state.contains('litter')) {
        return ageDays >= 18;
      }
      return ageDays >= 21 && state != 'closed';
    }).length;

    final gestating = hamsters.where((h) {
      final b = h.breedingStatus.toLowerCase();
      return b.contains('gestat') || b.contains('pregnan') || b == 'expecting';
    }).length;

    final dirty = enclosures.where((e) {
      final c = e.cleanlinessState.toLowerCase();
      return c.contains('dirty') ||
          c.contains('soil') ||
          c == 'needs_clean' ||
          c == 'needs_cleaning';
    }).length;

    final weightAlerts = buildWeightAlerts(
      snapshot?.recentWeights ?? const <I2WeightRecord>[],
    );

    return HomeOverviewMetrics(
      hamsterCount: activeHamsters,
      enclosureCount: enclosures.length,
      activeLitterCount: activeLitters.length,
      pendingWeanOrSexCount: pendingWeanOrSex,
      gestatingDamCount: gestating,
      dirtyEnclosureCount: dirty,
      draftCount: drafts.length,
      weightAlertCount: weightAlerts.length,
      offline: offline,
      lastSyncLabel: lastSyncLabel,
      organizationName: organizationName,
      weightAlerts: weightAlerts,
    );
  }

  static bool _isActiveLitter(I2Litter litter) {
    final state = litter.state.toLowerCase();
    if (state == 'closed' ||
        state == 'archived' ||
        state.contains('individualized') ||
        state == 'done') {
      return false;
    }
    return true;
  }
}

class HomeOverviewPage extends StatelessWidget {
  const HomeOverviewPage({
    super.key,
    required this.state,
    required this.controller,
    required this.onOpenHamsters,
    required this.onOpenEnclosures,
    required this.onOpenBreeding,
    required this.onOpenLitters,
    required this.onOpenDataCenter,
    required this.onCreateHamster,
    this.taskController,
    this.onOpenTasks,
    this.onOpenCalendar,
    this.onOpenBatchWeight,
  });

  final AppState state;
  final I2Controller controller;
  final TaskController? taskController;
  final VoidCallback onOpenHamsters;
  final VoidCallback onOpenEnclosures;
  final VoidCallback onOpenBreeding;
  final VoidCallback onOpenLitters;
  final VoidCallback onOpenDataCenter;
  final VoidCallback onCreateHamster;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenBatchWeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        state,
        controller,
        if (taskController != null) taskController!,
      ]),
      builder: (context, _) {
        final load = controller.snapshotState;
        final snapshot =
            load.data ??
            (load.status == I2AsyncStatus.empty
                ? const I2Snapshot(
                    hamsters: <I2Hamster>[],
                    litters: <I2Litter>[],
                    enclosures: <I2Enclosure>[],
                    lastSyncedAt: null,
                  )
                : null);
        final metrics = HomeOverviewMetrics.fromSnapshot(
          snapshot: snapshot,
          drafts: controller.drafts,
          offline: controller.offline || state.offline,
          lastSyncLabel: controller.lastSyncLabel,
          organizationName: state.organization?.name,
        );
        final loading =
            load.status == I2AsyncStatus.loading && load.data == null;
        final errorMessage = load.status == I2AsyncStatus.error
            ? (load.message ?? '加载失败')
            : null;
        final hasUncachedError = errorMessage != null && snapshot == null;

        final careQueue = buildTodayCareQueue(
          tasks: taskController?.listState.data ?? const <CareTaskItem>[],
          metrics: metrics,
          snapshot: snapshot,
        );

        return RefreshIndicator(
          color: ScolvPalette.of(context).accent,
          onRefresh: () async {
            await controller.retry();
            await taskController?.refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              0,
              8,
              0,
              IosMetrics.bottomSafePadding,
            ),
            child: BearPageEntrance(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: IosLargeTitle(
                      '今日',
                      subtitle: metrics.organizationName ?? '我的熊舍',
                      trailing: _HomeStatusPill(
                        offline: metrics.offline,
                        failed: hasUncachedError,
                        attention: metrics.attentionWithTasks(
                          taskController?.openCount ?? 0,
                        ),
                      ),
                    ),
                  ),
                  if (metrics.offline) ...[
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: IosBanner(
                        icon: CupertinoIcons.cloud,
                        text: '离线只读 · 显示缓存数据，联网后下拉刷新',
                        color: IosColors.systemOrange,
                      ),
                    ),
                  ],
                  if (errorMessage != null && snapshot != null) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: IosBanner(
                        icon: CupertinoIcons.exclamationmark_circle,
                        text: '同步失败，当前显示最近一次数据。$errorMessage',
                        color: IosColors.systemRed,
                        actionLabel: '重试',
                        onAction: controller.retry,
                      ),
                    ),
                  ],
                  if (loading) ...[
                    const SizedBox(height: 48),
                    const IosLoading(showSkeleton: true),
                  ] else if (hasUncachedError) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _HomeUnavailableState(
                        message: errorMessage,
                        onRetry: controller.retry,
                      ),
                    ),
                    const SizedBox(height: IosMetrics.sectionGap),
                    _QuickActionsSection(
                      onCreateHamster: onCreateHamster,
                      onOpenEnclosures: onOpenEnclosures,
                      onOpenLitters: onOpenLitters,
                      onOpenBreeding: onOpenBreeding,
                      onOpenDataCenter: onOpenDataCenter,
                      onOpenHamsters: onOpenHamsters,
                      onOpenBatchWeight: onOpenBatchWeight,
                      onOpenTasks: onOpenTasks,
                      onOpenCalendar: onOpenCalendar,
                    ),
                  ] else ...[
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _StatGrid(
                        metrics: metrics,
                        openTaskCount: taskController?.openCount ?? 0,
                      ),
                    ),
                    const SizedBox(height: IosMetrics.sectionGap),
                    _TodayCareQueueSection(
                      items: careQueue,
                      taskController: taskController,
                      onOpenTasks: onOpenTasks,
                      onOpenBatchWeight: onOpenBatchWeight,
                      onOpenEnclosures: onOpenEnclosures,
                      onOpenLitters: onOpenLitters,
                    ),
                    const SizedBox(height: IosMetrics.sectionGap),
                    _AttentionSection(
                      metrics: metrics,
                      openTaskCount: taskController?.openCount ?? 0,
                      overdueTaskCount: taskController?.overdueCount ?? 0,
                      onOpenLitters: onOpenLitters,
                      onOpenEnclosures: onOpenEnclosures,
                      onOpenBreeding: onOpenBreeding,
                      onOpenHamsters: onOpenHamsters,
                      onOpenBatchWeight: onOpenBatchWeight,
                      onOpenTasks: onOpenTasks,
                    ),
                    const SizedBox(height: 12),
                    _QuickActionsSection(
                      onCreateHamster: onCreateHamster,
                      onOpenEnclosures: onOpenEnclosures,
                      onOpenLitters: onOpenLitters,
                      onOpenBreeding: onOpenBreeding,
                      onOpenDataCenter: onOpenDataCenter,
                      onOpenHamsters: onOpenHamsters,
                      onOpenBatchWeight: onOpenBatchWeight,
                      onOpenTasks: onOpenTasks,
                      onOpenCalendar: onOpenCalendar,
                    ),
                    if (metrics.lastSyncLabel != null) ...[
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '最近同步：${metrics.lastSyncLabel}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: ScolvPalette.of(context).tertiaryLabel,
                              ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeStatusPill extends StatelessWidget {
  const _HomeStatusPill({
    required this.offline,
    required this.attention,
    this.failed = false,
  });

  final bool offline;
  final int attention;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (failed) {
      color = IosColors.systemRed;
      label = '未同步';
    } else if (offline) {
      color = IosColors.systemOrange;
      label = '离线';
    } else if (attention > 0) {
      color = IosColors.systemRed;
      label = '关注 $attention';
    } else {
      color = IosColors.systemGreen;
      label = '正常';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _HomeUnavailableState extends StatelessWidget {
  const _HomeUnavailableState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => IosGroupedSection(
    children: [
      IosListTile(
        leading: const IosGlyph(
          icon: CupertinoIcons.exclamationmark_circle,
          color: IosColors.systemRed,
        ),
        title: '今日数据暂时不可用',
        subtitle: message,
        trailing: TextButton(onPressed: onRetry, child: const Text('重试')),
        showChevron: false,
      ),
    ],
  );
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.metrics, this.openTaskCount = 0});

  final HomeOverviewMetrics metrics;
  final int openTaskCount;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final attention = metrics.attentionWithTasks(openTaskCount);
    final hasAttention = attention > 0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
        border: Border.all(color: p.separator),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const BearIconTile(
                asset: BearAssets.icHamster,
                size: 44,
                padding: 7,
                selected: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '在养',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: p.secondaryLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${metrics.hamsterCount}',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                color: p.label,
                                height: 1,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 6, bottom: 2),
                          child: Text(
                            '只仓鼠',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: p.secondaryLabel),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _HomeStatusPill(offline: metrics.offline, attention: attention),
            ],
          ),
          const SizedBox(height: 16),
          IosHairline(color: p.separator),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: '笼盒',
                  value: '${metrics.enclosureCount}',
                ),
              ),
              _MetricDivider(color: p.separator),
              Expanded(
                child: _MiniMetric(
                  label: '活跃窝次',
                  value: '${metrics.activeLitterCount}',
                ),
              ),
              _MetricDivider(color: p.separator),
              Expanded(
                child: _MiniMetric(
                  label: '需关注',
                  value: '$attention',
                  alert: hasAttention,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    this.alert = false,
  });

  final String label;
  final String value;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: p.secondaryLabel,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: alert ? IosColors.systemRed : p.label,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: IosMetrics.hairline,
    height: 38,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: color,
  );
}

class _TodayCareQueueSection extends StatelessWidget {
  const _TodayCareQueueSection({
    required this.items,
    required this.onOpenLitters,
    required this.onOpenEnclosures,
    this.taskController,
    this.onOpenTasks,
    this.onOpenBatchWeight,
  });

  final List<TodayCareItem> items;
  final TaskController? taskController;
  final VoidCallback onOpenLitters;
  final VoidCallback onOpenEnclosures;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenBatchWeight;

  Future<void> _complete(BuildContext context, CareTaskItem task) async {
    final tc = taskController;
    if (tc == null) return;
    final ok = await tc.complete(task);
    if (!context.mounted) return;
    final message = tc.lastMessage;
    if (message != null) {
      showIosMessage(context, message);
    }
    if (ok) {
      // AnimatedBuilder on taskController will rebuild.
    }
  }

  VoidCallback? _tapFor(TodayCareItem item) {
    switch (item.kind) {
      case TodayCareKind.overdueTask:
      case TodayCareKind.dueTodayTask:
        return onOpenTasks;
      case TodayCareKind.weightAlert:
        return onOpenBatchWeight ?? onOpenTasks;
      case TodayCareKind.dirtyEnclosure:
        return onOpenEnclosures;
      case TodayCareKind.pendingWean:
        return onOpenLitters;
    }
  }

  String _assetFor(TodayCareKind kind) => switch (kind) {
    TodayCareKind.overdueTask => BearAssets.icTasks,
    TodayCareKind.dueTodayTask => BearAssets.icCalendar,
    TodayCareKind.weightAlert => BearAssets.icWeight,
    TodayCareKind.dirtyEnclosure => BearAssets.icEnclosure,
    TodayCareKind.pendingWean => BearAssets.icLitter,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '今日护理',
                  key: const Key('home-today-care-title'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: ScolvPalette.of(context).secondaryLabel,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.08,
                  ),
                ),
              ),
              if (onOpenTasks != null)
                TextButton(
                  key: const Key('home-today-care-all-tasks'),
                  onPressed: onOpenTasks,
                  child: const Text('全部任务'),
                ),
            ],
          ),
        ),
        if (items.isEmpty)
          const BearEmptyCard(
            key: Key('home-today-care-empty'),
            title: '今天没有待办',
            subtitle: '小仓鼠都乖乖的，熊舍状态良好',
            mood: BearMood.happy,
            illustration: BearAssets.emptyCare,
          )
        else
          IosGroupedSection(
            children: [
              for (final item in items)
                IosListTile(
                  key: Key('home-care-item-${item.id}'),
                  leading: BearIconTile(
                    asset: _assetFor(item.kind),
                    size: 32,
                    padding: 4,
                    selected:
                        item.kind == TodayCareKind.overdueTask ||
                        item.kind == TodayCareKind.weightAlert,
                  ),
                  title: item.title,
                  subtitle: item.subtitle,
                  trailing: item.canComplete && taskController != null
                      ? TextButton(
                          key: Key('home-care-complete-${item.task!.id}'),
                          onPressed: () => _complete(context, item.task!),
                          child: const Text('完成'),
                        )
                      : null,
                  onTap: _tapFor(item),
                ),
            ],
          ),
      ],
    );
  }
}

class _AttentionSection extends StatelessWidget {
  const _AttentionSection({
    required this.metrics,
    required this.onOpenLitters,
    required this.onOpenEnclosures,
    required this.onOpenBreeding,
    required this.onOpenHamsters,
    this.openTaskCount = 0,
    this.overdueTaskCount = 0,
    this.onOpenBatchWeight,
    this.onOpenTasks,
  });

  final HomeOverviewMetrics metrics;
  final int openTaskCount;
  final int overdueTaskCount;
  final VoidCallback onOpenLitters;
  final VoidCallback onOpenEnclosures;
  final VoidCallback onOpenBreeding;
  final VoidCallback onOpenHamsters;
  final VoidCallback? onOpenBatchWeight;
  final VoidCallback? onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (openTaskCount > 0) {
      rows.add(
        _AttentionRow(
          title: '待办任务',
          subtitle: overdueTaskCount > 0
              ? '$openTaskCount 条待办 · $overdueTaskCount 条逾期'
              : '$openTaskCount 条待办',
          asset: BearAssets.icTasks,
          alert: overdueTaskCount > 0,
          onTap: onOpenTasks ?? onOpenHamsters,
        ),
      );
    }
    if (metrics.pendingWeanOrSexCount > 0) {
      rows.add(
        _AttentionRow(
          title: '待断奶/分性窝次',
          subtitle: '${metrics.pendingWeanOrSexCount} 窝需跟进',
          asset: BearAssets.icLitter,
          onTap: onOpenLitters,
        ),
      );
    }
    if (metrics.gestatingDamCount > 0) {
      rows.add(
        _AttentionRow(
          title: '孕期观察',
          subtitle: '${metrics.gestatingDamCount} 只疑似孕期个体',
          asset: BearAssets.icBreeding,
          onTap: onOpenBreeding,
        ),
      );
    }
    if (metrics.dirtyEnclosureCount > 0) {
      rows.add(
        _AttentionRow(
          title: '待清洁笼盒',
          subtitle: '${metrics.dirtyEnclosureCount} 个笼盒清洁状态异常',
          asset: BearAssets.icEnclosure,
          onTap: onOpenEnclosures,
        ),
      );
    }
    if (metrics.draftCount > 0) {
      rows.add(
        _AttentionRow(
          title: '本地草稿',
          subtitle: '${metrics.draftCount} 条离线草稿待提交',
          asset: BearAssets.icData,
          onTap: onOpenHamsters,
        ),
      );
    }
    if (metrics.weightAlertCount > 0) {
      final sample = metrics.weightAlerts
          .take(2)
          .map((a) => a.summary)
          .join('；');
      rows.add(
        _AttentionRow(
          title: '体重异常',
          subtitle: '${metrics.weightAlertCount} 只 · $sample',
          asset: BearAssets.icWeight,
          alert: true,
          onTap: onOpenBatchWeight ?? onOpenHamsters,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IosSectionHeader('需要关注'),
        if (rows.isEmpty)
          const BearEmptyCard(
            title: '一切正常',
            subtitle: '窝次、孕期与笼盒都安好，可以去喝口水啦',
            mood: BearMood.sleepy,
            illustration: BearAssets.emptyAttention,
          )
        else
          IosGroupedSection(children: rows),
      ],
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.onTap,
    this.alert = false,
  });

  final String title;
  final String subtitle;
  final String asset;
  final VoidCallback onTap;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return IosListTile(
      leading: BearIconTile(
        asset: asset,
        size: 32,
        padding: 4,
        selected: alert,
      ),
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _QuickActionsSection extends StatefulWidget {
  const _QuickActionsSection({
    required this.onCreateHamster,
    required this.onOpenEnclosures,
    required this.onOpenLitters,
    required this.onOpenBreeding,
    required this.onOpenDataCenter,
    required this.onOpenHamsters,
    this.onOpenBatchWeight,
    this.onOpenTasks,
    this.onOpenCalendar,
  });

  final VoidCallback onCreateHamster;
  final VoidCallback onOpenEnclosures;
  final VoidCallback onOpenLitters;
  final VoidCallback onOpenBreeding;
  final VoidCallback onOpenDataCenter;
  final VoidCallback onOpenHamsters;
  final VoidCallback? onOpenBatchWeight;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenCalendar;

  @override
  State<_QuickActionsSection> createState() => _QuickActionsSectionState();
}

class _QuickActionsSectionState extends State<_QuickActionsSection> {
  bool _showMore = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const IosSectionHeader('快捷操作'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _QuickChip(
                  buttonKey: const Key('home-quick-create-hamster'),
                  asset: BearAssets.icHamster,
                  label: '新建仓鼠',
                  onTap: widget.onCreateHamster,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 360 ? 3 : 4;
                  final width =
                      (constraints.maxWidth - 8 * (columns - 1)) / columns;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      if (widget.onOpenBatchWeight != null)
                        _QuickActionTile(
                          buttonKey: const Key('home-quick-batch-weight'),
                          asset: BearAssets.icWeight,
                          label: '批量称重',
                          onTap: widget.onOpenBatchWeight!,
                          width: width,
                        ),
                      if (widget.onOpenTasks != null)
                        _QuickActionTile(
                          buttonKey: const Key('home-quick-tasks'),
                          asset: BearAssets.icTasks,
                          label: '任务',
                          onTap: widget.onOpenTasks!,
                          width: width,
                        ),
                      _QuickActionTile(
                        buttonKey: const Key('home-quick-enclosures'),
                        asset: BearAssets.icEnclosure,
                        label: '笼舍',
                        onTap: widget.onOpenEnclosures,
                        width: width,
                      ),
                      if (_showMore) ...[
                        _QuickActionTile(
                          buttonKey: const Key('home-quick-litters'),
                          asset: BearAssets.icLitter,
                          label: '窝次',
                          onTap: widget.onOpenLitters,
                          width: width,
                        ),
                        _QuickActionTile(
                          buttonKey: const Key('home-quick-breeding'),
                          asset: BearAssets.icBreeding,
                          label: '繁育',
                          onTap: widget.onOpenBreeding,
                          width: width,
                        ),
                        _QuickActionTile(
                          buttonKey: const Key('home-quick-data-center'),
                          asset: BearAssets.icData,
                          label: '数据中心',
                          onTap: widget.onOpenDataCenter,
                          width: width,
                        ),
                        _QuickActionTile(
                          buttonKey: const Key('home-quick-hamsters'),
                          asset: BearAssets.icHamster,
                          label: '仓鼠列表',
                          onTap: widget.onOpenHamsters,
                          width: width,
                        ),
                        if (widget.onOpenCalendar != null)
                          _QuickActionTile(
                            buttonKey: const Key('home-quick-calendar'),
                            asset: BearAssets.icCalendar,
                            label: '日历',
                            onTap: widget.onOpenCalendar!,
                            width: width,
                          ),
                      ],
                      _QuickActionTile(
                        buttonKey: const Key('home-quick-more-toggle'),
                        icon: _showMore
                            ? CupertinoIcons.chevron_up
                            : CupertinoIcons.ellipsis,
                        label: _showMore ? '收起' : '更多',
                        onTap: () => setState(() => _showMore = !_showMore),
                        width: width,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    this.buttonKey,
    required this.asset,
    required this.label,
    required this.onTap,
  });

  final Key? buttonKey;
  final String asset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return FilledButton(
      key: buttonKey,
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.groupedBackground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        ),
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: p.groupedBackground,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(asset, width: 24, height: 24, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    this.buttonKey,
    this.asset,
    this.icon,
    required this.label,
    required this.onTap,
    required this.width,
  }) : assert((asset == null) != (icon == null));

  final Key? buttonKey;
  final String? asset;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return SizedBox(
      width: width,
      child: IosPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        child: Padding(
          key: buttonKey,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              if (icon != null)
                BearGlyphTile(
                  icon: icon!,
                  semanticLabel: label,
                  size: 42,
                  padding: 9,
                )
              else
                BearIconTile(asset: asset!, size: 42, padding: 7),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: p.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
