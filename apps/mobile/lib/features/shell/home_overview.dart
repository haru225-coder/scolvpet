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

/// P0-2: 轻量问候 + 日期（纯表现，不引新数据源）。
String workbenchGreeting(DateTime now) {
  final hour = now.hour;
  if (hour < 5) return '夜深了';
  if (hour < 11) return '早上好';
  if (hour < 14) return '中午好';
  if (hour < 18) return '下午好';
  return '晚上好';
}

String workbenchDateLabel(DateTime now) {
  const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  final local = now.toLocal();
  final wd = weekdays[local.weekday - 1];
  return '${local.month}月${local.day}日 · $wd';
}

/// 工作台「繁育动态」条目：只聚合 I2 快照已有字段。
class BreedingFeedItem {
  const BreedingFeedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String id;
  final String title;
  final String subtitle;
  final String kind; // gestation | litter | wean
}

/// 从仓鼠/窝次快照抽出最多 [maxItems] 条繁育动态（不调 API）。
List<BreedingFeedItem> buildBreedingFeed({
  I2Snapshot? snapshot,
  DateTime? now,
  int maxItems = 3,
}) {
  final clock = now ?? DateTime.now();
  final hamsters = snapshot?.hamsters ?? const <I2Hamster>[];
  final litters = snapshot?.litters ?? const <I2Litter>[];
  final byId = {for (final h in hamsters) h.id: h};
  final items = <BreedingFeedItem>[];

  for (final h in hamsters) {
    final b = h.breedingStatus.toLowerCase();
    if (b.contains('gestat') || b.contains('pregnan') || b == 'expecting') {
      items.add(
        BreedingFeedItem(
          id: 'gest-${h.id}',
          title: h.displayName,
          subtitle: '孕期观察 · ${h.breedingStatus}',
          kind: 'gestation',
        ),
      );
    }
  }

  for (final litter in litters) {
    if (!HomeOverviewMetrics._isActiveLitter(litter)) continue;
    final ageDays = clock.difference(litter.bornAt).inDays;
    final dam = byId[litter.damId]?.displayName;
    final sire = byId[litter.sireId]?.displayName;
    final parents = [
      if (sire != null && sire.isNotEmpty) sire,
      if (dam != null && dam.isNotEmpty) dam,
    ].join(' × ');
    final rawCode = litter.code?.trim() ?? '';
    final code = rawCode.isEmpty ? '窝次' : rawCode;
    final title = parents.isEmpty ? code : '$code · $parents';
    final state = litter.state.toLowerCase();
    final needsWean =
        state.contains('wean') ||
        state.contains('sex') ||
        state.contains('separat') ||
        ageDays >= 18;
    items.add(
      BreedingFeedItem(
        id: 'litter-${litter.id}',
        title: title,
        subtitle: needsWean
            ? '育仔 $ageDays 日龄 · 待断奶/分性跟进'
            : '育仔 $ageDays 日龄 · ${litter.currentManagedCount} 只在管',
        kind: needsWean ? 'wean' : 'litter',
      ),
    );
  }

  // 孕期优先，再窝次；截断
  items.sort((a, b) {
    int rank(String k) => switch (k) {
      'gestation' => 0,
      'wean' => 1,
      _ => 2,
    };
    final byKind = rank(a.kind).compareTo(rank(b.kind));
    if (byKind != 0) return byKind;
    return a.title.compareTo(b.title);
  });
  if (items.length <= maxItems) return items;
  return items.sublist(0, maxItems);
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
    this.onOpenAccount,
    this.onOpenAssistant,
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
  /// P0-1: Account menu (原「我的」能力入口)
  final VoidCallback? onOpenAccount;
  /// P0-1: AI 管家（原一级 Tab，现 push）
  final VoidCallback? onOpenAssistant;

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
                      '工作台',
                      subtitle: () {
                        final now = DateTime.now();
                        final name = state.account?.displayName?.trim();
                        final who = (name != null && name.isNotEmpty)
                            ? name
                            : (metrics.organizationName ?? '熊舍');
                        return '${workbenchGreeting(now)}，$who\n${workbenchDateLabel(now)}';
                      }(),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onOpenAssistant != null)
                            IconButton(
                              key: const Key('home-open-assistant'),
                              tooltip: '问问管家',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              onPressed: onOpenAssistant,
                              icon: Icon(
                                CupertinoIcons.sparkles,
                                size: 22,
                                color: ScolvPalette.of(context).accent,
                              ),
                            ),
                          if (onOpenAccount != null)
                            IconButton(
                              key: const Key('home-open-account'),
                              tooltip: '账号与设置',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              onPressed: onOpenAccount,
                              icon: Icon(
                                CupertinoIcons.person_crop_circle,
                                size: 24,
                                color: ScolvPalette.of(context).label,
                              ),
                            ),
                        ],
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
                    _PrimaryActionsSection(
                      onCreateHamster: onCreateHamster,
                      onOpenTasks: onOpenTasks,
                    ),
                  ] else ...[
                    // P0-2 信息优先级：待办 → 概览 → 繁育动态 → 精简快捷
                    const SizedBox(height: 10),
                    _TodayCareQueueSection(
                      items: careQueue,
                      taskController: taskController,
                      onOpenTasks: onOpenTasks,
                      onOpenBatchWeight: onOpenBatchWeight,
                      onOpenEnclosures: onOpenEnclosures,
                      onOpenLitters: onOpenLitters,
                    ),
                    const SizedBox(height: IosMetrics.sectionGap),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _OpsOverviewStrip(
                        metrics: metrics,
                        openTaskCount: taskController?.openCount ?? 0,
                        onOpenHamsters: onOpenHamsters,
                        onOpenLitters: onOpenLitters,
                        onOpenBreeding: onOpenBreeding,
                      ),
                    ),
                    const SizedBox(height: IosMetrics.sectionGap),
                    _BreedingFeedSection(
                      items: buildBreedingFeed(snapshot: snapshot),
                      gestatingCount: metrics.gestatingDamCount,
                      activeLitterCount: metrics.activeLitterCount,
                      onOpenBreeding: onOpenBreeding,
                      onOpenLitters: onOpenLitters,
                    ),
                    const SizedBox(height: IosMetrics.sectionGap),
                    _PrimaryActionsSection(
                      onCreateHamster: onCreateHamster,
                      onOpenTasks: onOpenTasks,
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

/// P0-2 经营概览：单层 4 指标，不造厚 Card。
class _OpsOverviewStrip extends StatelessWidget {
  const _OpsOverviewStrip({
    required this.metrics,
    required this.onOpenHamsters,
    required this.onOpenLitters,
    required this.onOpenBreeding,
    this.openTaskCount = 0,
  });

  final HomeOverviewMetrics metrics;
  final int openTaskCount;
  final VoidCallback onOpenHamsters;
  final VoidCallback onOpenLitters;
  final VoidCallback onOpenBreeding;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final attention = metrics.attentionWithTasks(openTaskCount);
    final hasAttention = attention > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '经营概览',
          key: const Key('home-ops-overview-title'),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: p.label,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(
            color: p.secondaryGroupedBackground,
            borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
            border: Border.all(color: p.separator, width: IosMetrics.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: _MiniMetric(
                  label: '在养',
                  value: '${metrics.hamsterCount}',
                  onTap: onOpenHamsters,
                ),
              ),
              _MetricDivider(color: p.separator),
              Expanded(
                child: _MiniMetric(
                  label: '活跃窝次',
                  value: '${metrics.activeLitterCount}',
                  onTap: onOpenLitters,
                ),
              ),
              _MetricDivider(color: p.separator),
              Expanded(
                child: _MiniMetric(
                  label: '孕期',
                  value: '${metrics.gestatingDamCount}',
                  onTap: onOpenBreeding,
                ),
              ),
              _MetricDivider(color: p.separator),
              Expanded(
                child: _MiniMetric(
                  label: '需关注',
                  value: '$attention',
                  alert: hasAttention,
                  onTap: hasAttention ? onOpenHamsters : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreedingFeedSection extends StatelessWidget {
  const _BreedingFeedSection({
    required this.items,
    required this.gestatingCount,
    required this.activeLitterCount,
    required this.onOpenBreeding,
    required this.onOpenLitters,
  });

  final List<BreedingFeedItem> items;
  final int gestatingCount;
  final int activeLitterCount;
  final VoidCallback onOpenBreeding;
  final VoidCallback onOpenLitters;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final summary = <String>[
      if (gestatingCount > 0) '孕期 $gestatingCount',
      if (activeLitterCount > 0) '育仔窝 $activeLitterCount',
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '繁育动态',
                  key: const Key('home-breeding-feed-title'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: p.label,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              TextButton(
                key: const Key('home-breeding-feed-open'),
                onPressed: onOpenBreeding,
                child: const Text('查看繁育'),
              ),
            ],
          ),
        ),
        if (summary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              summary,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: p.secondaryLabel,
              ),
            ),
          ),
        if (items.isEmpty)
          BearEmptyCard(
            key: const Key('home-breeding-feed-empty'),
            title: '暂无进行中的繁育节点',
            subtitle: '有配对、孕期或育仔窝次时，会在这里按优先级展示。',
            mood: BearMood.sleepy,
            illustration: BearAssets.emptyList,
            actionLabel: '打开繁育',
            onAction: onOpenBreeding,
          )
        else
          IosGroupedSection(
            children: [
              for (final item in items)
                IosListTile(
                  key: Key('home-breeding-item-${item.id}'),
                  leading: Icon(
                    item.kind == 'gestation'
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.square_favorites_alt,
                    size: 22,
                    color: p.accent,
                  ),
                  title: item.title,
                  subtitle: item.subtitle,
                  onTap: item.kind == 'litter' || item.kind == 'wean'
                      ? onOpenLitters
                      : onOpenBreeding,
                ),
            ],
          ),
      ],
    );
  }
}

class _PrimaryActionsSection extends StatelessWidget {
  const _PrimaryActionsSection({
    required this.onCreateHamster,
    this.onOpenTasks,
  });

  final VoidCallback onCreateHamster;
  final VoidCallback? onOpenTasks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickChip(
              buttonKey: const Key('home-quick-create-hamster'),
              icon: CupertinoIcons.plus,
              label: '新建仓鼠',
              onTap: onCreateHamster,
            ),
          ),
          if (onOpenTasks != null) ...[
            const SizedBox(width: 10),
            Expanded(
              child: _QuickChip(
                buttonKey: const Key('home-quick-tasks'),
                icon: CupertinoIcons.checkmark_circle,
                label: '全部任务',
                onTap: onOpenTasks!,
              ),
            ),
          ],
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
    this.onTap,
  });

  final String label;
  final String value;
  final bool alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final child = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: alert ? IosColors.systemOrange : p.label,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ],
    );
    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
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
                  items.isEmpty ? '今日待办' : '今日待办  ${items.length}',
                  key: const Key('home-today-care-title'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: ScolvPalette.of(context).label,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
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
            title: '今天没有待处理事项',
            subtitle: '当前护理与关注队列为空，繁育与笼舍状态可继续观察。',
            mood: BearMood.happy,
            illustration: BearAssets.emptyCare,
          )
        else
          IosGroupedSection(
            children: [
              for (final item in items)
                IosListTile(
                  key: Key('home-care-item-${item.id}'),
                  leading: Icon(
                    switch (item.kind) {
                      TodayCareKind.overdueTask =>
                        CupertinoIcons.exclamationmark_circle,
                      TodayCareKind.dueTodayTask => CupertinoIcons.clock,
                      TodayCareKind.weightAlert => CupertinoIcons.graph_square,
                      TodayCareKind.dirtyEnclosure => CupertinoIcons.square_grid_2x2,
                      TodayCareKind.pendingWean => CupertinoIcons.heart,
                    },
                    size: 22,
                    color:
                        item.kind == TodayCareKind.overdueTask ||
                            item.kind == TodayCareKind.weightAlert
                        ? IosColors.systemOrange
                        : ScolvPalette.of(context).secondaryLabel,
                  ),
                  title: item.title,
                  subtitle: item.subtitle,
                  trailing: item.canComplete && taskController != null
                      ? TextButton(
                          key: Key('home-care-complete-${item.task!.id}'),
                          onPressed: () => _complete(context, item.task!),
                          child: const Text('完成'),
                        )
                      : Text(
                          switch (item.kind) {
                            TodayCareKind.overdueTask => '逾期',
                            TodayCareKind.dueTodayTask => '待完成',
                            TodayCareKind.weightAlert => '需关注',
                            TodayCareKind.dirtyEnclosure => '需关注',
                            TodayCareKind.pendingWean => '跟进',
                          },
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color:
                                    item.kind == TodayCareKind.overdueTask
                                    ? IosColors.systemRed
                                    : ScolvPalette.of(context).secondaryLabel,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                  onTap: _tapFor(item),
                ),
            ],
          ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    this.buttonKey,
    this.asset,
    this.icon,
    required this.label,
    required this.onTap,
  }) : assert(asset != null || icon != null);

  final Key? buttonKey;
  final String? asset;
  final IconData? icon;
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
        minimumSize: const Size(0, 48),
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
          if (icon != null)
            Icon(icon, size: 20, color: p.groupedBackground)
          else
            Image.asset(asset!, width: 22, height: 22, fit: BoxFit.contain),
          const SizedBox(width: 8),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

