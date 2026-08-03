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

/// 工作台「繁育动态」条目：只聚合 I2 快照已有字段（能力保留，首页不再主推）。
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

/// 首页「我的血统库」预览：仅消费 I2 快照中的窝次父母关系（不另开 API）。
class BloodlinePreviewItem {
  const BloodlinePreviewItem({
    required this.hamsterId,
    required this.name,
    this.sireName,
    this.damName,
  });

  final String hamsterId;
  final String name;
  final String? sireName;
  final String? damName;
}

/// 优先展示有父母信息的在养个体；不足时回退为近期活跃个体。
List<BloodlinePreviewItem> buildBloodlinePreviews({
  I2Snapshot? snapshot,
  int maxItems = 4,
}) {
  if (snapshot == null || maxItems <= 0) return const [];
  final byId = {for (final h in snapshot.hamsters) h.id: h};
  final litterById = {for (final l in snapshot.litters) l.id: l};

  String? shortOf(String? id) {
    if (id == null || id.isEmpty) return null;
    final h = byId[id];
    if (h == null) return null;
    final name = h.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final code = h.internalCode.trim();
    return code.isEmpty ? null : code;
  }

  final withParents = <BloodlinePreviewItem>[];
  final withoutParents = <BloodlinePreviewItem>[];

  for (final h in snapshot.hamsters) {
    if (h.lifecycleStatus.toLowerCase() == 'archived') continue;
    final lid = h.litterId?.trim();
    final litter = (lid == null || lid.isEmpty) ? null : litterById[lid];
    final sire = litter == null ? null : shortOf(litter.sireId);
    final dam = litter == null ? null : shortOf(litter.damId);
    final item = BloodlinePreviewItem(
      hamsterId: h.id,
      name: h.displayName,
      sireName: sire,
      damName: dam,
    );
    if (sire != null || dam != null) {
      withParents.add(item);
    } else {
      withoutParents.add(item);
    }
  }

  final merged = [...withParents, ...withoutParents];
  if (merged.length <= maxItems) return merged;
  return merged.sublist(0, maxItems);
}

/// 首页：我的繁育空间（v2 · 决策优先，非经营 ERP）。
class HomeOverviewPage extends StatelessWidget {
  const HomeOverviewPage({
    super.key,
    required this.state,
    required this.controller,
    required this.onOpenHamsters,
    required this.onOpenSimulate,
    required this.onCreateHamster,
    this.taskController,
    this.onOpenPedigree,
    this.onOpenCrm,
    this.onOpenBreeding,
    this.onOpenLitters,
    this.onOpenEnclosures,
    this.onOpenDataCenter,
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
  final VoidCallback onOpenSimulate;
  final VoidCallback onCreateHamster;
  final ValueChanged<I2Hamster>? onOpenPedigree;
  final VoidCallback? onOpenCrm;
  final VoidCallback? onOpenBreeding;
  final VoidCallback? onOpenLitters;
  final VoidCallback? onOpenEnclosures;
  final VoidCallback? onOpenDataCenter;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenCalendar;
  final VoidCallback? onOpenBatchWeight;
  final VoidCallback? onOpenAccount;
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
        final bloodlines = buildBloodlinePreviews(snapshot: snapshot);
        final byId = {
          for (final h in snapshot?.hamsters ?? const <I2Hamster>[]) h.id: h,
        };

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
                      '我的繁育空间',
                      key: const Key('home-breeding-space-title'),
                      subtitle: () {
                        final now = DateTime.now();
                        final org = metrics.organizationName?.trim();
                        final name = state.account?.displayName?.trim();
                        final who = (org != null && org.isNotEmpty)
                            ? org
                            : ((name != null && name.isNotEmpty) ? name : '熊舍');
                        return '${workbenchGreeting(now)}，$who\n'
                            '预测配对 · 管理血统 · 展示专业';
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
                              icon: const BearMascot(
                                size: 28,
                                mood: BearMood.happy,
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
                    _SimulateHeroCard(onOpenSimulate: onOpenSimulate),
                  ] else ...[
                    const SizedBox(height: 12),
                    // 1. 快速模拟（最高优先级）
                    _SimulateHeroCard(onOpenSimulate: onOpenSimulate),
                    const SizedBox(height: IosMetrics.sectionGap),
                    // 2. 最近血统
                    _BloodlineSection(
                      items: bloodlines,
                      onOpenAll: onOpenHamsters,
                      onOpenItem: onOpenPedigree == null
                          ? null
                          : (item) {
                              final h = byId[item.hamsterId];
                              if (h != null) onOpenPedigree!(h);
                            },
                    ),
                    const SizedBox(height: IosMetrics.sectionGap),
                    // 3. 我的仓鼠
                    _MyHamstersSection(
                      count: metrics.hamsterCount,
                      onOpenHamsters: onOpenHamsters,
                      onCreateHamster: onCreateHamster,
                    ),
                    const SizedBox(height: IosMetrics.sectionGap),
                    // 4. 交易入口（降权）
                    if (onOpenCrm != null) ...[
                      _SecondaryCrmEntry(onOpenCrm: onOpenCrm!),
                      const SizedBox(height: IosMetrics.sectionGap),
                    ],
                    // 二级能力：不删，折叠入口
                    _SecondaryToolsRow(
                      onOpenBreeding: onOpenBreeding,
                      onOpenLitters: onOpenLitters,
                      onOpenTasks: onOpenTasks,
                      onOpenEnclosures: onOpenEnclosures,
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
        title: '繁育数据暂时不可用',
        subtitle: message,
        trailing: TextButton(onPressed: onRetry, child: const Text('重试')),
        showChevron: false,
      ),
    ],
  );
}

/// 繁育模拟主卡：把“父本 × 母本 → 结果”作为首页第一视觉对象。
class _SimulateHeroCard extends StatelessWidget {
  const _SimulateHeroCard({required this.onOpenSimulate});

  final VoidCallback onOpenSimulate;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: p.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        child: InkWell(
          key: const Key('home-simulate-hero'),
          onTap: onOpenSimulate,
          borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
              border: Border.all(
                color: p.separator,
                width: IosMetrics.hairline,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.accentSoft, p.secondaryGroupedBackground],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: p.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.lab_flask_solid,
                        color: p.groupedBackground,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '这两只会生出什么',
                            key: const Key('home-simulate-title'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: p.label,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '用现有权威规则，先看下一代可能出现什么',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: p.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const BearMascot(size: 46, mood: BearMood.happy),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '选择两只仓鼠，预测下一代毛色与携带',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.secondaryLabel,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _ParentSlot(
                        sexLabel: '父本',
                        hint: '点选公鼠',
                        icon: CupertinoIcons.arrow_up_right,
                        color: IosColors.systemBlue,
                        onTap: onOpenSimulate,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.add,
                            size: 18,
                            color: p.tertiaryLabel,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '配对',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: p.tertiaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _ParentSlot(
                        sexLabel: '母本',
                        hint: '点选母鼠',
                        icon: CupertinoIcons.arrow_down_right,
                        color: IosColors.systemRed,
                        onTap: onOpenSimulate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const Key('home-simulate-start'),
                  onPressed: onOpenSimulate,
                  icon: const Icon(CupertinoIcons.play_fill, size: 16),
                  style: FilledButton.styleFrom(
                    backgroundColor: p.accent,
                    foregroundColor: p.groupedBackground,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        IosMetrics.continuousRadius,
                      ),
                    ),
                  ),
                  label: const Text(
                    '试配一下',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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

class _ParentSlot extends StatelessWidget {
  const _ParentSlot({
    required this.sexLabel,
    required this.hint,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String sexLabel;
  final String hint;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Material(
      color: p.groupedBackground.withValues(alpha: 0.86),
      borderRadius: BorderRadius.circular(IosMetrics.smallRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IosMetrics.smallRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IosMetrics.smallRadius),
            border: Border.all(color: p.separator, width: IosMetrics.hairline),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sexLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: p.label,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: p.tertiaryLabel),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: p.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 我的血统库
class _BloodlineSection extends StatelessWidget {
  const _BloodlineSection({
    required this.items,
    required this.onOpenAll,
    this.onOpenItem,
  });

  final List<BloodlinePreviewItem> items;
  final VoidCallback onOpenAll;
  final ValueChanged<BloodlinePreviewItem>? onOpenItem;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.arrow_branch,
                      size: 18,
                      color: p.accent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '我的血统库',
                      key: const Key('home-bloodline-title'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: p.label,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                key: const Key('home-bloodline-all'),
                onPressed: onOpenAll,
                child: const Text('全部仓鼠'),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          BearEmptyCard(
            key: const Key('home-bloodline-empty'),
            title: '还没有可展示的血统',
            subtitle: '建档并关联父母后，这里会显示父本 / 母本摘要。',
            mood: BearMood.sleepy,
            illustration: BearAssets.emptyList,
            actionLabel: '去建档',
            onAction: onOpenAll,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: IosGroupedSection(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      thickness: IosMetrics.hairline,
                      color: p.separator,
                    ),
                  _BloodlineRow(
                    item: items[i],
                    onTap: onOpenItem == null
                        ? onOpenAll
                        : () => onOpenItem!(items[i]),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _BloodlineRow extends StatelessWidget {
  const _BloodlineRow({required this.item, required this.onTap});

  final BloodlinePreviewItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      if (item.sireName != null) '└ 父：${item.sireName}',
      if (item.damName != null) '└ 母：${item.damName}',
    ];
    final subtitle = lines.isEmpty ? '暂无父母记录 · 点开查看血统档案' : lines.join('\n');
    return IosListTile(
      key: Key('home-bloodline-item-${item.hamsterId}'),
      leading: const IosGlyph(
        icon: CupertinoIcons.arrow_branch,
        color: IosColors.systemIndigo,
      ),
      title: item.name,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

/// 我的仓鼠入口
class _MyHamstersSection extends StatelessWidget {
  const _MyHamstersSection({
    required this.count,
    required this.onOpenHamsters,
    required this.onCreateHamster,
  });

  final int count;
  final VoidCallback onOpenHamsters;
  final VoidCallback onCreateHamster;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.paw, size: 18, color: p.accent),
              const SizedBox(width: 8),
              Text(
                '我的仓鼠',
                key: const Key('home-my-hamsters-title'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: p.label,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IosGroupedSection(
            children: [
              IosListTile(
                key: const Key('home-open-hamsters'),
                leading: const IosGlyph(
                  icon: CupertinoIcons.paw,
                  color: IosColors.systemOrange,
                ),
                title: count == 0 ? '进入个体档案' : '在养 $count 只 · 进入个体档案',
                subtitle: '身份、血统与繁育价值',
                onTap: onOpenHamsters,
              ),
              Divider(
                height: 1,
                thickness: IosMetrics.hairline,
                color: p.separator,
              ),
              IosListTile(
                key: const Key('home-quick-create-hamster'),
                leading: const IosGlyph(
                  icon: CupertinoIcons.plus_circle,
                  color: IosColors.systemGreen,
                ),
                title: '新建仓鼠',
                subtitle: '补档后再做配对预测',
                onTap: onCreateHamster,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 📋 客户预约（降权二级入口）
class _SecondaryCrmEntry extends StatelessWidget {
  const _SecondaryCrmEntry({required this.onOpenCrm});

  final VoidCallback onOpenCrm;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IosGroupedSection(
        children: [
          IosListTile(
            key: const Key('home-open-crm'),
            leading: IosGlyph(
              icon: CupertinoIcons.doc_text,
              color: p.secondaryLabel,
            ),
            title: '客户预约',
            subtitle: '宝宝展示与预约（非首页主推）',
            onTap: onOpenCrm,
          ),
        ],
      ),
    );
  }
}

/// 管理类能力保留但降权：繁育进度 / 窝次 / 任务 / 笼舍
class _SecondaryToolsRow extends StatelessWidget {
  const _SecondaryToolsRow({
    this.onOpenBreeding,
    this.onOpenLitters,
    this.onOpenTasks,
    this.onOpenEnclosures,
  });

  final VoidCallback? onOpenBreeding;
  final VoidCallback? onOpenLitters;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenEnclosures;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (onOpenBreeding != null)
        _QuickChip(
          buttonKey: const Key('home-secondary-breeding'),
          icon: CupertinoIcons.heart,
          label: '繁育进度',
          onTap: onOpenBreeding!,
        ),
      if (onOpenLitters != null)
        _QuickChip(
          buttonKey: const Key('home-secondary-litters'),
          icon: CupertinoIcons.square_favorites_alt,
          label: '窝次',
          onTap: onOpenLitters!,
        ),
      if (onOpenTasks != null)
        _QuickChip(
          buttonKey: const Key('home-secondary-tasks'),
          icon: CupertinoIcons.checkmark_circle,
          label: '任务',
          onTap: onOpenTasks!,
        ),
      if (onOpenEnclosures != null)
        _QuickChip(
          buttonKey: const Key('home-secondary-enclosures'),
          icon: CupertinoIcons.square_grid_2x2,
          label: '笼舍',
          onTap: onOpenEnclosures!,
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '更多工具',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ScolvPalette.of(context).tertiaryLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Material(
      color: p.secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: InkWell(
        key: buttonKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
            border: Border.all(color: p.separator, width: IosMetrics.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: p.secondaryLabel),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: p.secondaryLabel,
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
