part of 'i2_hamsters.dart';

// P0-4-R1: Professional individual record surface (no Dark HUD palette).

class _HamsterDetailOfflineBanner extends StatelessWidget {
  const _HamsterDetailOfflineBanner({this.lastSyncLabel});

  final String? lastSyncLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: IosBanner(
        icon: CupertinoIcons.cloud,
        color: IosColors.systemOrange,
        text: lastSyncLabel == null
            ? '离线只读 · 最近同步未知'
            : '离线只读 · 最近同步 $lastSyncLabel',
      ),
    );
  }
}

class _HamsterDetailPanel extends StatelessWidget {
  const _HamsterDetailPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(color: p.separator, width: IosMetrics.hairline),
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
    this.onEdit,
  });

  final I2Hamster hamster;
  final String enclosureLabel;
  final I2WeightRecord? latestWeight;
  final bool healthGood;
  final bool offline;
  final VoidCallback onCopyId;
  final VoidCallback onAvatarTap;
  final bool avatarLoading;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final name = hamster.name?.trim() ?? '';
    final code = hamster.internalCode.trim();
    final title = name.isEmpty ? code : name;
    // Domain authority: reuse existing phenotype/series display paths as-is.
    final meta = <String>[
      if (hamster.coreSeriesCode != null) _seriesLabel(hamster.coreSeriesCode!),
      if (hamster.corePhenotypeLabel != null) hamster.corePhenotypeLabel!,
      if (hamster.birthDate != null) _hamsterAgeLabel(hamster.birthDate),
    ];
    final sexIcon = switch (hamster.sex) {
      'male' => Icons.male_rounded,
      'female' => Icons.female_rounded,
      _ => null,
    };
    final sexColor = switch (hamster.sex) {
      'male' => const Color(0xff5B8DEF),
      'female' => const Color(0xffE08BB0),
      _ => p.tertiaryLabel,
    };
    return Container(
      key: const Key('hamster-detail-profile'),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HamsterDetailAvatar(
                hamster: hamster,
                onTap: onAvatarTap,
                loading: avatarLoading,
                size: 88,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                          ),
                        ),
                        if (sexIcon != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, top: 4),
                            child: Icon(sexIcon, size: 18, color: sexColor),
                          ),
                      ],
                    ),
                    if (name.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: p.secondaryLabel,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        meta.join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: p.secondaryLabel,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (offline
                                        ? IosColors.systemOrange
                                        : (healthGood
                                              ? IosColors.systemGreen
                                              : IosColors.systemOrange))
                                    .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(
                              IosMetrics.pillRadius,
                            ),
                          ),
                          child: Text(
                            offline
                                ? '离线'
                                : i2LifecycleLabel(hamster.lifecycleStatus),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: offline
                                      ? IosColors.systemOrange
                                      : (healthGood
                                            ? IosColors.systemGreen
                                            : IosColors.systemOrange),
                                ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.house,
                              size: 14,
                              color: p.secondaryLabel,
                            ),
                            const SizedBox(width: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                '笼盒 $enclosureLabel',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: p.secondaryLabel),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: '复制编号',
                          onPressed: onCopyId,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          icon: Icon(
                            CupertinoIcons.doc_on_doc,
                            size: 16,
                            color: p.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.tonal(
                          key: const Key('hamster-detail-edit-profile'),
                          onPressed: onEdit,
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('编辑档案'),
                        ),
                      ),
                    ],
                  ],
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
    this.size = 72,
  });

  final I2Hamster hamster;
  final VoidCallback onTap;
  final bool loading;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('hamster-avatar-manage'),
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          HamsterAvatar(
            label: hamster.name ?? hamster.internalCode,
            imageUrl: hamster.avatarUrl,
            imageBytes: hamster.avatarBytes,
            size: size,
            preferBrandPlaceholder: true,
          ),
          if (loading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: ScolvPalette.of(context).secondaryGroupedBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.camera_fill,
                size: 12,
                color: ScolvPalette.of(context).secondaryLabel,
              ),
            ),
        ],
      ),
    );
  }
}

class _HamsterDetailArchiveSection extends StatelessWidget {
  const _HamsterDetailArchiveSection({
    super.key,
    required this.hamster,
    required this.enclosureLabel,
    required this.latestWeight,
  });

  final I2Hamster hamster;
  final String enclosureLabel;
  final I2WeightRecord? latestWeight;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('出生日期', i2DateLabel(hamster.birthDate)),
      ('性别', i2SexLabel(hamster.sex)),
      ('当前状态', i2LifecycleLabel(hamster.lifecycleStatus)),
      ('笼盒', enclosureLabel),
      ('体重', latestWeight == null ? '暂无' : '${latestWeight!.weightG} g'),
      if (hamster.coreSeriesCode != null)
        ('系列', _seriesLabel(hamster.coreSeriesCode!)),
      if (hamster.corePhenotypeLabel != null)
        ('表型', hamster.corePhenotypeLabel!),
      if (hamster.breedingStatus.trim().isNotEmpty)
        ('繁育状态', i2BreedingStatusLabel(hamster.breedingStatus)),
    ];
    return _HamsterDetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HamsterDetailSectionTitle(
            icon: CupertinoIcons.doc_person,
            title: '基础资料',
          ),
          const SizedBox(height: 8),
          _HamsterDetailFieldTable(rows: rows),
        ],
      ),
    );
  }
}

class _HamsterDetailBreedingSection extends StatelessWidget {
  const _HamsterDetailBreedingSection({
    super.key,
    required this.litterCount,
    required this.breedingStatus,
    this.onOpenPedigree,
    this.onOpenGenetic,
  });

  final int litterCount;
  final String breedingStatus;
  final VoidCallback? onOpenPedigree;
  final VoidCallback? onOpenGenetic;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return _HamsterDetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HamsterDetailSectionTitle(icon: CupertinoIcons.heart, title: '繁育价值'),
          const SizedBox(height: 8),
          _HamsterDetailFieldTable(
            rows: [
              ('当前繁育状态', i2BreedingStatusLabel(breedingStatus)),
              ('关联窝次', '$litterCount'),
            ],
          ),
          if (onOpenPedigree != null || onOpenGenetic != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onOpenPedigree != null)
                  TextButton(
                    key: const Key('hamster-detail-open-pedigree'),
                    onPressed: onOpenPedigree,
                    child: const Text('查看血统'),
                  ),
                if (onOpenGenetic != null)
                  TextButton(
                    key: const Key('hamster-open-genetic'),
                    onPressed: onOpenGenetic,
                    child: Text('配对推算', style: TextStyle(color: p.accent)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HamsterDetailFieldTable extends StatelessWidget {
  const _HamsterDetailFieldTable({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: IosMetrics.hairline,
              color: p.separator,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(
                    rows[i].$1,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: p.secondaryLabel),
                  ),
                ),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
    final p = ScolvPalette.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: p.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
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
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(label),
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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: ScolvPalette.of(context).secondaryLabel,
        ),
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
    this.color,
  });

  final IconData icon;
  final String title;
  final DateTime at;
  final String? subtitle;
  final Color? color;
}

class _HamsterDetailRecentRow extends StatelessWidget {
  const _HamsterDetailRecentRow({required this.event});

  final _HamsterDetailEvent event;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(event.icon, size: 18, color: event.color ?? p.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (event.subtitle != null && event.subtitle!.isNotEmpty)
                  Text(
                    event.subtitle!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: p.secondaryLabel),
                  ),
              ],
            ),
          ),
          Text(
            _relativeDetailTime(event.at),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: p.secondaryLabel),
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
    final p = ScolvPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            task.isOverdue
                ? CupertinoIcons.exclamationmark_circle
                : CupertinoIcons.clock,
            size: 18,
            color: task.isOverdue ? IosColors.systemOrange : p.secondaryLabel,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.displayTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  taskTypeLabel(task.taskType),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: p.secondaryLabel),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: enabled ? onComplete : null,
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
    final p = ScolvPalette.of(context);
    final flags = evaluateWeightFlags(weight);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${weight.weightG} g',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: flags.isEmpty ? p.label : IosColors.systemOrange,
              ),
            ),
          ),
          Text(
            i2DateTimeLabel(weight.recordedAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: p.secondaryLabel),
          ),
        ],
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
        color: IosColors.systemGreen,
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
