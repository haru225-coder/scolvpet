part of 'i2_hamsters.dart';

class HamsterListPage extends StatefulWidget {
  const HamsterListPage({
    super.key,
    required this.controller,
    this.onOpenDetail,
    this.onCreate,
    this.onBatchCreate,
    this.onOpenLitters,
  });

  final I2Controller controller;
  final ValueChanged<I2Hamster>? onOpenDetail;
  final VoidCallback? onCreate;
  final VoidCallback? onBatchCreate;
  final VoidCallback? onOpenLitters;

  @override
  State<HamsterListPage> createState() => _HamsterListPageState();
}

class _HamsterListPageState extends State<HamsterListPage> {
  final TextEditingController _searchController = TextEditingController();

  /// 筛选键：all | active | breeding | retired | transferred | deceased
  /// lifecycle 键与 i2LifecycleLabel 权威枚举一致；breeding 为展示层派生（不改领域）。
  String _lifecycle = 'all';

  static const _primaryFilters = <(String, String)>[
    ('all', '全部'),
    ('active', '在养'),
    ('breeding', '繁育中'),
    ('transferred', '转出'),
  ];

  static const _moreFilters = <(String, String)>[
    ('retired', '已退役'),
    ('deceased', '已离世'),
  ];

  static bool _isBreedingActive(I2Hamster h) {
    final b = h.breedingStatus.toLowerCase();
    return b.contains('gestat') ||
        b.contains('pregnan') ||
        b.contains('pair') ||
        b.contains('nurs') ||
        b == 'expecting' ||
        b == 'post_pair' ||
        b == 'hold';
  }

  bool _matchesFilter(I2Hamster hamster) {
    if (_lifecycle == 'all') return true;
    if (_lifecycle == 'breeding') return _isBreedingActive(hamster);
    return hamster.lifecycleStatus == _lifecycle;
  }

  int _countFor(List<I2Hamster> hamsters, String key) {
    if (key == 'all') return hamsters.length;
    if (key == 'breeding') {
      return hamsters.where(_isBreedingActive).length;
    }
    return hamsters.where((h) => h.lifecycleStatus == key).length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _moreFilterLabel([List<I2Hamster>? hamsters]) {
    for (final item in _moreFilters) {
      if (item.$1 == _lifecycle) {
        if (hamsters == null) return item.$2;
        return '${item.$2} ${_countFor(hamsters, item.$1)}';
      }
    }
    return '筛选';
  }

  bool get _moreFilterSelected =>
      _moreFilters.any((item) => item.$1 == _lifecycle);

  Future<void> _openMoreFilters() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final p = ScolvPalette.of(sheetContext);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  '状态筛选',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              for (final item in _moreFilters)
                ListTile(
                  title: Text(item.$2),
                  trailing: _lifecycle == item.$1
                      ? Icon(CupertinoIcons.checkmark, color: p.accent)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(item.$1),
                ),
              if (_moreFilterSelected)
                ListTile(
                  title: const Text('清除状态筛选'),
                  onTap: () => Navigator.of(sheetContext).pop('all'),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() => _lifecycle = selected);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final state = widget.controller.snapshotState;
      final hasWritePermission = widget.controller.hasWritePermission;
      final p = ScolvPalette.of(context);
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: IosLargeTitle(
                  '仓鼠',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.onOpenLitters != null)
                        IconButton(
                          tooltip: '窝次',
                          onPressed: widget.onOpenLitters,
                          icon: Icon(
                            CupertinoIcons.square_favorites_alt,
                            color: p.secondaryLabel,
                          ),
                        ),
                      IconButton(
                        tooltip: '重试',
                        onPressed: widget.controller.retry,
                        icon: Icon(
                          CupertinoIcons.arrow_clockwise,
                          color: p.secondaryLabel,
                        ),
                      ),
                      if (hasWritePermission &&
                          (widget.onCreate != null ||
                              widget.onBatchCreate != null))
                        IconButton(
                          key: const Key('hamster-list-create'),
                          tooltip: '新建仓鼠',
                          onPressed: () async {
                            if (widget.onBatchCreate == null) {
                              widget.onCreate?.call();
                              return;
                            }
                            if (widget.onCreate == null) {
                              widget.onBatchCreate?.call();
                              return;
                            }
                            final choice =
                                await showCupertinoModalPopup<String>(
                                  context: context,
                                  builder: (ctx) => CupertinoActionSheet(
                                    actions: [
                                      CupertinoActionSheetAction(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop('single'),
                                        child: const Text('单只建档'),
                                      ),
                                      CupertinoActionSheetAction(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop('batch'),
                                        child: const Text('批量建档'),
                                      ),
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('取消'),
                                    ),
                                  ),
                                );
                            if (choice == 'single') widget.onCreate?.call();
                            if (choice == 'batch') widget.onBatchCreate?.call();
                          },
                          icon: Icon(CupertinoIcons.plus, color: p.accent),
                        ),
                    ],
                  ),
                ),
              ),
              I2OfflineBanner(
                offline: widget.controller.offline,
                lastSyncLabel: widget.controller.lastSyncLabel,
              ),
              if (!hasWritePermission && !widget.controller.offline)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看仓鼠档案，新增和编辑已设为只读。',
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(CupertinoIcons.search, size: 20),
                    // 真实搜索仅支持 internalCode / name，不写未实现字段
                    hintText: '搜索名称或编号',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: I2AsyncStateView<I2Snapshot>(
                  state: state,
                  onRetry: widget.controller.retry,
                  emptyBuilder: (context) => I2StateMessage(
                    icon: CupertinoIcons.paw,
                    message: '还没有个体档案',
                    illustration: BearAssets.emptyList,
                    mood: BearMood.sleepy,
                    actionLabel: hasWritePermission && widget.onCreate != null
                        ? '新建仓鼠'
                        : null,
                    onRetry: hasWritePermission ? widget.onCreate : null,
                  ),
                  builder: (snapshot) {
                    final allHamsters = snapshot.hamsters;
                    final query = _searchController.text.trim().toLowerCase();
                    final values = allHamsters.where((hamster) {
                      final matchesQuery =
                          query.isEmpty ||
                          hamster.internalCode.toLowerCase().contains(query) ||
                          (hamster.name ?? '').toLowerCase().contains(query);
                      return matchesQuery && _matchesFilter(hamster);
                    }).toList();
                    // chips 放在 builder 内以便带实时计数
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          child: Row(
                            children: [
                              for (final item in _primaryFilters)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _LifecycleChip(
                                    label:
                                        '${item.$2} ${_countFor(allHamsters, item.$1)}',
                                    selected: _lifecycle == item.$1,
                                    onTap: () =>
                                        setState(() => _lifecycle = item.$1),
                                  ),
                                ),
                              _LifecycleChip(
                                label: _moreFilterLabel(allHamsters),
                                selected: _moreFilterSelected,
                                onTap: _openMoreFilters,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _buildListBody(
                            values: values,
                            hasWritePermission: hasWritePermission,
                            snapshot: snapshot,
                            p: p,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _buildListBody({
    required List<I2Hamster> values,
    required bool hasWritePermission,
    required I2Snapshot snapshot,
    required ScolvPalette p,
  }) {
    if (values.isEmpty) {
      final hasFilter =
          _searchController.text.trim().isNotEmpty || _lifecycle != 'all';
      return I2StateMessage(
        icon: CupertinoIcons.paw,
        message: hasFilter ? '没有匹配的仓鼠' : '还没有个体档案',
        illustration: BearAssets.emptyList,
        mood: BearMood.sleepy,
        actionLabel: hasFilter
            ? '清除筛选'
            : (hasWritePermission && widget.onCreate != null ? '新建仓鼠' : null),
        onRetry: hasFilter
            ? () {
                _searchController.clear();
                setState(() => _lifecycle = 'all');
              }
            : hasWritePermission
            ? widget.onCreate
            : null,
      );
    }
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      itemCount: values.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: IosMetrics.hairline,
        color: p.separator,
      ),
      itemBuilder: (context, index) {
        final hamster = values[index];
        return _HamsterListRow(
          hamster: hamster,
          snapshot: snapshot,
          onTap: widget.onOpenDetail == null
              ? null
              : () => widget.onOpenDetail!(hamster),
        );
      },
    );
  }
}

class _LifecycleChip extends StatelessWidget {
  const _LifecycleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Material(
      color: selected ? p.accent.withValues(alpha: 0.12) : p.tertiaryFill,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? p.accent : p.label,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

String _enclosureLabel(I2Snapshot? snapshot, String? enclosureId) {
  if (enclosureId == null || enclosureId.trim().isEmpty) return '未分配';
  I2Enclosure? enclosure;
  for (final item in snapshot?.enclosures ?? const <I2Enclosure>[]) {
    if (item.id == enclosureId) {
      enclosure = item;
      break;
    }
  }
  if (enclosure == null) return '已分配';
  final code = enclosure.code.trim();
  return code.isEmpty ? '已分配' : code;
}

/// 由 birthDate 安全计算月龄；无日期则 null（不伪造）。
String? _ageLabel(DateTime? birthDate, DateTime now) {
  if (birthDate == null) return null;
  final birth = birthDate.toLocal();
  if (birth.isAfter(now)) return null;
  var months = (now.year - birth.year) * 12 + (now.month - birth.month);
  if (now.day < birth.day) months -= 1;
  if (months < 0) return null;
  if (months < 1) {
    final days = now.difference(birth).inDays;
    return days <= 0 ? '新生' : '$days日龄';
  }
  if (months < 12) return '$months月龄';
  final years = months ~/ 12;
  final rem = months % 12;
  return rem == 0 ? '$years岁' : '$years岁$rem月';
}

/// 父母行：仅当个体有 litterId 且快照含窝次/父母时展示（不另开 API）。
String? _parentLine(I2Snapshot snapshot, I2Hamster hamster) {
  final lid = hamster.litterId?.trim();
  if (lid == null || lid.isEmpty) return null;
  I2Litter? litter;
  for (final item in snapshot.litters) {
    if (item.id == lid) {
      litter = item;
      break;
    }
  }
  if (litter == null) return null;
  final byId = {for (final h in snapshot.hamsters) h.id: h};
  String shortOf(String id) {
    final h = byId[id];
    if (h == null) return '';
    final code = h.internalCode.trim();
    if (code.isNotEmpty) return code;
    return (h.name ?? '').trim();
  }

  final sire = shortOf(litter.sireId);
  final dam = shortOf(litter.damId);
  final parts = <String>[
    if (sire.isNotEmpty) '父 $sire',
    if (dam.isNotEmpty) '母 $dam',
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

class _HamsterListRow extends StatelessWidget {
  const _HamsterListRow({
    required this.hamster,
    required this.snapshot,
    this.onTap,
  });

  final I2Hamster hamster;
  final I2Snapshot snapshot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final weights =
        snapshot.recentWeights.where((w) => w.hamsterId == hamster.id).toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final latest = weights.isEmpty ? null : weights.first;
    final abnormal = latest != null && evaluateWeightFlags(latest).isNotEmpty;
    final phenotype = hamster.corePhenotypeLabel?.trim();
    final age = _ageLabel(hamster.birthDate, DateTime.now());
    final enclosure = _enclosureLabel(snapshot, hamster.currentEnclosureId);
    final parents = _parentLine(snapshot, hamster);
    final name = (hamster.name ?? '').trim();
    final code = hamster.internalCode.trim();
    final title = name.isEmpty ? code : name;
    final breedingLabel = i2BreedingStatusLabel(hamster.breedingStatus);
    final showBreedingPill =
        breedingLabel != '候选' &&
        breedingLabel != '—' &&
        hamster.breedingStatus.trim().isNotEmpty;

    final metaParts = <String>[
      if (phenotype != null && phenotype.isNotEmpty) phenotype,
      if (age != null) age,
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HamsterAvatar(
              label: name.isEmpty ? code : name,
              imageUrl: hamster.avatarUrl,
              imageBytes: hamster.avatarBytes,
              size: 56,
              statusColor: abnormal ? IosColors.systemOrange : null,
              preferBrandPlaceholder: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                              ),
                            ),
                            if (sexIcon != null) ...[
                              const SizedBox(width: 4),
                              Icon(sexIcon, size: 14, color: sexColor),
                            ],
                          ],
                        ),
                      ),
                      if (name.isNotEmpty && code.isNotEmpty)
                        Text(
                          code,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: p.secondaryLabel,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                    ],
                  ),
                  if (metaParts.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      metaParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: p.secondaryLabel),
                    ),
                  ],
                  if (parents != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      parents,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: p.tertiaryLabel),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _lifecycleDot(hamster.lifecycleStatus, p),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          i2LifecycleLabel(hamster.lifecycleStatus),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: p.secondaryLabel),
                        ),
                      ),
                      if (showBreedingPill) ...[
                        const SizedBox(width: 6),
                        _ListPill(label: breedingLabel, color: p.accent),
                      ],
                      if (abnormal) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          size: 14,
                          color: IosColors.systemOrange,
                        ),
                      ],
                      const Spacer(),
                      _ListPill(
                        label: '笼盒 $enclosure',
                        color: p.secondaryLabel,
                        soft: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _lifecycleDot(String status, ScolvPalette p) {
    return switch (status) {
      'active' => IosColors.systemGreen,
      'retired' => p.tertiaryLabel,
      'transferred' => p.secondaryLabel,
      'deceased' => p.tertiaryLabel,
      _ => p.secondaryLabel,
    };
  }
}

class _ListPill extends StatelessWidget {
  const _ListPill({
    required this.label,
    required this.color,
    this.soft = false,
  });

  final String label;
  final Color color;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: soft ? 0.08 : 0.12),
        borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
