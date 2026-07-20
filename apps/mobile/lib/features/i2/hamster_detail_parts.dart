part of 'i2_hamsters.dart';

class _HamsterDetailOfflineBanner extends StatelessWidget {
  const _HamsterDetailOfflineBanner({this.lastSyncLabel});

  final String? lastSyncLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: _HamsterDetailPanel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        color: const Color(0xff211b12),
        borderColor: _HamsterDetailColors.gold.withValues(alpha: 0.08),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.cloud,
              color: _HamsterDetailColors.gold,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lastSyncLabel == null
                    ? '离线只读 · 最近同步未知'
                    : '离线只读 · 最近同步 $lastSyncLabel',
                style: const TextStyle(
                  color: _HamsterDetailColors.goldBright,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HamsterDetailPanel extends StatelessWidget {
  const _HamsterDetailPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.color = _HamsterDetailColors.panel,
    this.borderColor = _HamsterDetailColors.line,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HamsterDetailProfileCard extends StatelessWidget {
  const _HamsterDetailProfileCard({
    required this.hamster,
    required this.enclosureLabel,
    required this.latestWeight,
    required this.healthGood,
    required this.offline,
    required this.onCopyId,
    required this.onAvatarTap,
    required this.avatarLoading,
  });

  final I2Hamster hamster;
  final String enclosureLabel;
  final I2WeightRecord? latestWeight;
  final bool healthGood;
  final bool offline;
  final VoidCallback onCopyId;
  final VoidCallback onAvatarTap;
  final bool avatarLoading;

  @override
  Widget build(BuildContext context) {
    final tags = <String>{
      '金丝熊',
      if (hamster.coreSeriesCode != null) _seriesLabel(hamster.coreSeriesCode!),
      if (hamster.corePhenotypeLabel != null) hamster.corePhenotypeLabel!,
    }.toList();
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              hamster.name?.trim().isNotEmpty == true
                  ? hamster.name!.trim()
                  : hamster.internalCode,
              style: const TextStyle(
                color: _HamsterDetailColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            _HamsterDetailChip(
              label: offline ? '离线' : i2LifecycleLabel(hamster.lifecycleStatus),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Flexible(
              child: Text(
                'ID ${hamster.internalCode}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _HamsterDetailColors.muted,
                  fontSize: 15,
                ),
              ),
            ),
            IconButton(
              tooltip: '复制编号',
              onPressed: onCopyId,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              icon: const Icon(
                CupertinoIcons.doc_on_doc,
                color: _HamsterDetailColors.muted,
                size: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [for (final tag in tags) _HamsterDetailTag(label: tag)],
        ),
      ],
    );
    return _HamsterDetailPanel(
      key: const Key('hamster-detail-profile'),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      color: const Color(0xff181a1a),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact =
                  constraints.maxWidth < 350 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.2;
              final avatar = _HamsterDetailAvatar(
                hamster: hamster,
                onTap: onAvatarTap,
                loading: avatarLoading,
                size: compact ? 84 : 104,
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        avatar,
                        const SizedBox(width: 12),
                        Expanded(child: identity),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _HamsterDetailHealthBadge(good: healthGood),
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(width: 14),
                  Expanded(child: identity),
                  const SizedBox(width: 8),
                  _HamsterDetailHealthBadge(good: healthGood),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: _HamsterDetailColors.line),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HamsterDetailInfo(
                  icon: hamster.sex == 'female'
                      ? CupertinoIcons.person
                      : CupertinoIcons.person_fill,
                  label: '性别',
                  value: i2SexLabel(hamster.sex),
                ),
              ),
              Expanded(
                child: _HamsterDetailInfo(
                  icon: CupertinoIcons.gauge,
                  label: '体重',
                  value: latestWeight == null
                      ? '待记录'
                      : '${latestWeight!.weightG} g',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HamsterDetailInfo(
                  icon: CupertinoIcons.calendar,
                  label: '年龄',
                  value: _hamsterAgeLabel(hamster.birthDate),
                ),
              ),
              Expanded(
                child: _HamsterDetailInfo(
                  icon: CupertinoIcons.house,
                  label: '当前笼舍',
                  value: enclosureLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HamsterDetailAvatar extends StatelessWidget {
  const _HamsterDetailAvatar({
    required this.hamster,
    required this.onTap,
    required this.loading,
    this.size = 104,
  });

  final I2Hamster hamster;
  final VoidCallback onTap;
  final bool loading;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IosPressable(
      key: const Key('hamster-avatar-manage'),
      enabled: !loading,
      onTap: onTap,
      haptic: false,
      borderRadius: BorderRadius.circular(size / 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          HamsterAvatar(
            label: hamster.name ?? hamster.internalCode,
            imageUrl: hamster.avatarUrl,
            imageBytes: hamster.avatarBytes,
            size: size,
            statusColor: _HamsterDetailColors.gold,
          ),
          if (loading)
            const CircularProgressIndicator(
              color: _HamsterDetailColors.goldBright,
            ),
          if (!loading)
            const Positioned(
              right: 2,
              bottom: 2,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: _HamsterDetailColors.gold,
                child: Icon(CupertinoIcons.camera_fill, size: 15),
              ),
            ),
        ],
      ),
    );
  }
}

class _HamsterDetailChip extends StatelessWidget {
  const _HamsterDetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _HamsterDetailColors.goldSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _HamsterDetailColors.gold.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _HamsterDetailColors.goldBright,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HamsterDetailTag extends StatelessWidget {
  const _HamsterDetailTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1ff5eee2),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0x1ff5eee2)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: _HamsterDetailColors.text, fontSize: 12),
      ),
    );
  }
}

class _HamsterDetailHealthBadge extends StatelessWidget {
  const _HamsterDetailHealthBadge({required this.good});

  final bool good;

  @override
  Widget build(BuildContext context) {
    final color = good ? _HamsterDetailColors.green : _HamsterDetailColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            good
                ? CupertinoIcons.heart_fill
                : CupertinoIcons.exclamationmark_triangle_fill,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            good ? '健康良好' : '需关注',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _HamsterDetailInfo extends StatelessWidget {
  const _HamsterDetailInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _HamsterDetailColors.gold, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _HamsterDetailColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _HamsterDetailColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HamsterDetailMetric extends StatelessWidget {
  const _HamsterDetailMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? _HamsterDetailColors.red : _HamsterDetailColors.gold;
    return _HamsterDetailPanel(
      padding: const EdgeInsets.fromLTRB(10, 13, 10, 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _HamsterDetailColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: danger ? color : _HamsterDetailColors.text,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HamsterDetailSectionTitle extends StatelessWidget {
  const _HamsterDetailSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _HamsterDetailColors.gold, size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _HamsterDetailColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _HamsterDetailLink extends StatelessWidget {
  const _HamsterDetailLink({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _HamsterDetailColors.gold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            CupertinoIcons.chevron_right,
            color: _HamsterDetailColors.gold,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _HamsterDetailHealthItem extends StatelessWidget {
  const _HamsterDetailHealthItem({
    required this.icon,
    required this.label,
    required this.value,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? _HamsterDetailColors.red
        : _HamsterDetailColors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: _HamsterDetailColors.line)),
      ),
      child: Column(
        children: [
          Icon(icon, color: _HamsterDetailColors.gold, size: 20),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _HamsterDetailColors.text,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HamsterDetailEmptyRow extends StatelessWidget {
  const _HamsterDetailEmptyRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(color: _HamsterDetailColors.muted, fontSize: 13),
      ),
    );
  }
}

class _HamsterDetailEvent {
  const _HamsterDetailEvent({
    required this.icon,
    required this.title,
    required this.at,
    this.subtitle,
    this.color = _HamsterDetailColors.gold,
  });

  final IconData icon;
  final String title;
  final DateTime at;
  final String? subtitle;
  final Color color;
}

class _HamsterDetailRecentRow extends StatelessWidget {
  const _HamsterDetailRecentRow({required this.event});

  final _HamsterDetailEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _HamsterDetailColors.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: event.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(event.icon, color: event.color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _HamsterDetailColors.text,
                    fontSize: 14,
                  ),
                ),
                if (event.subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    event.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _HamsterDetailColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _relativeDetailTime(event.at),
            style: const TextStyle(
              color: _HamsterDetailColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            CupertinoIcons.chevron_right,
            color: _HamsterDetailColors.muted,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _HamsterDetailTaskRow extends StatelessWidget {
  const _HamsterDetailTaskRow({
    required this.task,
    required this.enabled,
    required this.onComplete,
  });

  final CareTaskItem task;
  final bool enabled;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('hamster-care-task-${task.id}'),
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _HamsterDetailColors.line)),
      ),
      child: Row(
        children: [
          Icon(
            task.isOverdue
                ? CupertinoIcons.exclamationmark_triangle_fill
                : CupertinoIcons.circle,
            color: task.isOverdue
                ? _HamsterDetailColors.red
                : _HamsterDetailColors.gold,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.displayTitle,
                  style: const TextStyle(
                    color: _HamsterDetailColors.text,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${taskTypeLabel(task.taskType)} · ${task.isOverdue ? '已逾期 · ' : ''}${i2DateTimeLabel(task.scheduledAt)}',
                  style: const TextStyle(
                    color: _HamsterDetailColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (enabled)
            TextButton(
              key: Key('hamster-complete-task-${task.id}'),
              onPressed: onComplete,
              style: TextButton.styleFrom(
                foregroundColor: _HamsterDetailColors.gold,
              ),
              child: const Text('完成'),
            ),
        ],
      ),
    );
  }
}

class _HamsterDetailWeightRow extends StatelessWidget {
  const _HamsterDetailWeightRow({required this.weight});

  final I2WeightRecord weight;

  @override
  Widget build(BuildContext context) {
    final flags = evaluateWeightFlags(weight);
    final abnormal = flags.isNotEmpty;
    final delta = weight.changeFromPreviousG;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _HamsterDetailColors.line)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.gauge,
            color: abnormal
                ? _HamsterDetailColors.red
                : _HamsterDetailColors.gold,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weight.weightG} g${abnormal ? ' · 异常' : ''}',
                  style: const TextStyle(
                    color: _HamsterDetailColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${i2DateTimeLabel(weight.recordedAt)} · ${weight.source}${flags.isEmpty ? '' : ' · ${flags.join(', ')}'}',
                  style: const TextStyle(
                    color: _HamsterDetailColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (delta != null)
            Text(
              '${delta >= 0 ? '+' : ''}$delta g',
              style: TextStyle(
                color: delta < 0
                    ? _HamsterDetailColors.red
                    : _HamsterDetailColors.muted,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _HamsterDetailPedigreeCard extends StatelessWidget {
  const _HamsterDetailPedigreeCard({
    required this.litterCount,
    required this.onTap,
  });

  final int litterCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IosPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x1b8bb55a),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x1f8bb55a)),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.tree,
              color: _HamsterDetailColors.green,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    litterCount == 0 ? '谱系资料待补充' : '已关联 $litterCount 个窝次',
                    style: const TextStyle(
                      color: _HamsterDetailColors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '查看父母、后代与繁育记录',
                    style: TextStyle(
                      color: _HamsterDetailColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0x4dbb8435),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '查看谱系',
                    style: TextStyle(
                      color: _HamsterDetailColors.goldBright,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: _HamsterDetailColors.goldBright,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HamsterDetailAction extends StatelessWidget {
  const _HamsterDetailAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IosPressable(
      onTap: onTap,
      enabled: onTap != null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0x0ff5eee2)
              : const Color(0x14f5eee2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x14f5eee2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onTap == null
                  ? _HamsterDetailColors.muted
                  : _HamsterDetailColors.gold,
              size: 20,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: onTap == null
                    ? _HamsterDetailColors.muted
                    : _HamsterDetailColors.text,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

I2WeightRecord? _latestWeight(List<I2WeightRecord> weights) {
  if (weights.isEmpty) return null;
  return weights.reduce((a, b) => a.recordedAt.isAfter(b.recordedAt) ? a : b);
}

List<_HamsterDetailEvent> _recentDetailEvents({
  required List<HealthRecordItem> healthRecords,
  required List<I2WeightRecord> weights,
}) {
  final events = <_HamsterDetailEvent>[
    for (final record in healthRecords)
      _HamsterDetailEvent(
        icon: CupertinoIcons.heart_fill,
        title: record.typeLabel,
        at: record.observedAt,
        subtitle: record.notes?.trim().isEmpty == true
            ? null
            : record.notes?.trim(),
        color: _HamsterDetailColors.green,
      ),
    for (final weight in weights)
      _HamsterDetailEvent(
        icon: CupertinoIcons.gauge,
        title: '体重 ${weight.weightG} g',
        at: weight.recordedAt,
      ),
  ];
  events.sort((a, b) => b.at.compareTo(a.at));
  return events;
}

String _relativeDetailTime(DateTime value) {
  final local = value.toLocal();
  final now = DateTime.now();
  final sameDay =
      local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;
  final time =
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  return sameDay ? '今天 $time' : i2DateLabel(local);
}

String _hamsterAgeLabel(DateTime? birthDate) {
  if (birthDate == null) return '—';
  final now = DateTime.now();
  var months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
  if (now.day < birthDate.day) months -= 1;
  if (months < 1) return '不足 1 个月';
  return '$months 个月';
}

String _seriesLabel(String code) => switch (code) {
  'poly' => '波利系列',
  'chocolate' => '巧克力色系',
  _ => code,
};
