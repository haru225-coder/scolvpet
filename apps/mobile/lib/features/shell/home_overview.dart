import 'package:flutter/material.dart';

import '../../core/app_state.dart';
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
        // empty/error states may leave data == null; still render a zeroed dashboard.
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

        return RefreshIndicator(
          onRefresh: () => controller.retry(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Text(
                '今日',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff1f2928),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metrics.organizationName ?? '我的熊舍',
                style: const TextStyle(color: Color(0xff6c7774)),
              ),
              if (metrics.offline) ...[
                const SizedBox(height: 12),
                const _HomeBanner(
                  icon: Icons.cloud_off_outlined,
                  text: '离线只读 · 显示缓存数据，联网后下拉刷新',
                  color: Color(0xff8a6d3b),
                ),
              ],
              if (errorMessage != null && snapshot == null) ...[
                const SizedBox(height: 12),
                _HomeBanner(
                  icon: Icons.error_outline,
                  text: errorMessage,
                  color: Colors.redAccent,
                  actionLabel: '重试',
                  onAction: controller.retry,
                ),
              ],
              if (loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ] else ...[
                const SizedBox(height: 16),
                _StatGrid(
                  metrics: metrics,
                  openTaskCount: taskController?.openCount ?? 0,
                ),
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                const Text(
                  '快捷操作',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1f2928),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickChip(
                      buttonKey: const Key('home-quick-create-hamster'),
                      icon: Icons.pets,
                      label: '新建仓鼠',
                      onTap: onCreateHamster,
                    ),
                    _QuickChip(
                      buttonKey: const Key('home-quick-enclosures'),
                      icon: Icons.grid_view,
                      label: '笼舍看板',
                      onTap: onOpenEnclosures,
                    ),
                    _QuickChip(
                      buttonKey: const Key('home-quick-litters'),
                      icon: Icons.groups_outlined,
                      label: '窝次',
                      onTap: onOpenLitters,
                    ),
                    _QuickChip(
                      buttonKey: const Key('home-quick-breeding'),
                      icon: Icons.sync_alt,
                      label: '繁育',
                      onTap: onOpenBreeding,
                    ),
                    _QuickChip(
                      buttonKey: const Key('home-quick-data-center'),
                      icon: Icons.inventory_2_outlined,
                      label: '数据中心',
                      onTap: onOpenDataCenter,
                    ),
                    _QuickChip(
                      buttonKey: const Key('home-quick-hamsters'),
                      icon: Icons.list_alt,
                      label: '仓鼠列表',
                      onTap: onOpenHamsters,
                    ),
                    if (onOpenBatchWeight != null)
                      _QuickChip(
                        buttonKey: const Key('home-quick-batch-weight'),
                        icon: Icons.monitor_weight_outlined,
                        label: '批量称重',
                        onTap: onOpenBatchWeight!,
                      ),
                    if (onOpenTasks != null)
                      _QuickChip(
                        buttonKey: const Key('home-quick-tasks'),
                        icon: Icons.task_alt,
                        label: '任务',
                        onTap: onOpenTasks!,
                      ),
                    if (onOpenCalendar != null)
                      _QuickChip(
                        buttonKey: const Key('home-quick-calendar'),
                        icon: Icons.calendar_month_outlined,
                        label: '日历',
                        onTap: onOpenCalendar!,
                      ),
                  ],
                ),
                if (metrics.lastSyncLabel != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    '最近同步：${metrics.lastSyncLabel}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff6c7774),
                    ),
                  ),
                ],
              ],
            ],
            ),
          ),
        );
      },
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.metrics, this.openTaskCount = 0});

  final HomeOverviewMetrics metrics;
  final int openTaskCount;

  @override
  Widget build(BuildContext context) {
    final attention = metrics.attentionWithTasks(openTaskCount);
    final items = [
      _StatItem('在养', '${metrics.hamsterCount}', Icons.pets_outlined),
      _StatItem('笼盒', '${metrics.enclosureCount}', Icons.grid_view_outlined),
      _StatItem('活跃窝次', '${metrics.activeLitterCount}', Icons.groups_outlined),
      _StatItem('需关注', '$attention', Icons.priority_high),
    ];
    Widget card(_StatItem item) => Expanded(
      child: Card(
        color: const Color(0xffdce5e3),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: const Color(0xffc77852), size: 22),
              const SizedBox(height: 12),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1f2928),
                ),
              ),
              Text(
                item.label,
                style: const TextStyle(color: Color(0xff6c7774)),
              ),
            ],
          ),
        ),
      ),
    );
    return Column(
      children: [
        Row(children: [card(items[0]), const SizedBox(width: 10), card(items[1])]),
        const SizedBox(height: 10),
        Row(children: [card(items[2]), const SizedBox(width: 10), card(items[3])]),
      ],
    );
  }
}

class _StatItem {
  const _StatItem(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
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
        _AttentionTile(
          title: '待办任务',
          subtitle: overdueTaskCount > 0
              ? '$openTaskCount 条待办 · $overdueTaskCount 条逾期'
              : '$openTaskCount 条待办',
          icon: Icons.task_alt,
          onTap: onOpenTasks ?? onOpenHamsters,
        ),
      );
    }
    if (metrics.pendingWeanOrSexCount > 0) {
      rows.add(
        _AttentionTile(
          title: '待断奶/分性窝次',
          subtitle: '${metrics.pendingWeanOrSexCount} 窝需跟进',
          icon: Icons.child_care_outlined,
          onTap: onOpenLitters,
        ),
      );
    }
    if (metrics.gestatingDamCount > 0) {
      rows.add(
        _AttentionTile(
          title: '孕期观察',
          subtitle: '${metrics.gestatingDamCount} 只疑似孕期个体',
          icon: Icons.favorite_outline,
          onTap: onOpenBreeding,
        ),
      );
    }
    if (metrics.dirtyEnclosureCount > 0) {
      rows.add(
        _AttentionTile(
          title: '待清洁笼盒',
          subtitle: '${metrics.dirtyEnclosureCount} 个笼盒清洁状态异常',
          icon: Icons.cleaning_services_outlined,
          onTap: onOpenEnclosures,
        ),
      );
    }
    if (metrics.draftCount > 0) {
      rows.add(
        _AttentionTile(
          title: '本地草稿',
          subtitle: '${metrics.draftCount} 条离线草稿待提交',
          icon: Icons.edit_note,
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
        _AttentionTile(
          title: '体重异常',
          subtitle: '${metrics.weightAlertCount} 只 · $sample',
          icon: Icons.monitor_weight_outlined,
          onTap: onOpenBatchWeight ?? onOpenHamsters,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '需要关注',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff1f2928),
          ),
        ),
        const SizedBox(height: 10),
        if (rows.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('暂无紧急事项'),
              subtitle: Text('窝次、孕期与笼盒状态看起来正常'),
            ),
          )
        else
          ...rows,
      ],
    );
  }
}

class _AttentionTile extends StatelessWidget {
  const _AttentionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xffc77852)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    this.buttonKey,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Key? buttonKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 4),
      child: OutlinedButton.icon(
        key: buttonKey,
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

class _HomeBanner extends StatelessWidget {
  const _HomeBanner({
    required this.icon,
    required this.text,
    required this.color,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: TextStyle(color: color, height: 1.3)),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}

