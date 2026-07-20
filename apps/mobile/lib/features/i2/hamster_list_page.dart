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
  String _lifecycle = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final state = widget.controller.snapshotState;
      final hasWritePermission = widget.controller.hasWritePermission;
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
                      const BearMascot(size: 36, mood: BearMood.happy),
                      if (widget.onOpenLitters != null)
                        IconButton(
                          tooltip: '窝次',
                          onPressed: widget.onOpenLitters,
                          icon: const BearNavIcon(
                            asset: BearAssets.icLitter,
                            size: 24,
                          ),
                        ),
                      IconButton(
                        tooltip: '重试',
                        onPressed: widget.controller.retry,
                        icon: const Icon(CupertinoIcons.arrow_clockwise),
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
                    hintText: '搜索档案编号或昵称',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  children: [
                    for (final item in const [
                      ('all', '全部'),
                      ('active', '在养'),
                      ('retired', '已退役'),
                      ('transferred', '已转出'),
                      ('deceased', '已离世'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(item.$2),
                          selected: _lifecycle == item.$1,
                          selectedColor: ScolvPalette.of(context).accentSoft,
                          labelStyle: TextStyle(
                            color: _lifecycle == item.$1
                                ? ScolvPalette.of(context).accent
                                : ScolvPalette.of(context).label,
                            fontWeight: _lifecycle == item.$1
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: _lifecycle == item.$1
                                ? ScolvPalette.of(
                                    context,
                                  ).accent.withValues(alpha: 0.35)
                                : ScolvPalette.of(context).opaqueSeparator,
                            width: IosMetrics.hairline,
                          ),
                          onSelected: (_) =>
                              setState(() => _lifecycle = item.$1),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: I2AsyncStateView<I2Snapshot>(
                  state: state,
                  onRetry: widget.controller.retry,
                  emptyBuilder: (context) => I2StateMessage(
                    icon: CupertinoIcons.paw,
                    message: '暂无仓鼠档案',
                    illustration: BearAssets.emptyList,
                    mood: BearMood.sleepy,
                    actionLabel: hasWritePermission && widget.onCreate != null
                        ? '新建仓鼠'
                        : null,
                    onRetry: hasWritePermission ? widget.onCreate : null,
                  ),
                  builder: (snapshot) {
                    final query = _searchController.text.trim().toLowerCase();
                    final values = snapshot.hamsters.where((hamster) {
                      final matchesQuery =
                          query.isEmpty ||
                          hamster.internalCode.toLowerCase().contains(query) ||
                          (hamster.name ?? '').toLowerCase().contains(query);
                      final matchesLifecycle =
                          _lifecycle == 'all' ||
                          hamster.lifecycleStatus == _lifecycle;
                      return matchesQuery && matchesLifecycle;
                    }).toList();
                    if (values.isEmpty) {
                      final hasFilter =
                          _searchController.text.trim().isNotEmpty ||
                          _lifecycle != 'all';
                      return I2StateMessage(
                        icon: CupertinoIcons.paw,
                        message: hasFilter ? '没有匹配的仓鼠' : '暂无仓鼠档案',
                        illustration: BearAssets.emptyList,
                        mood: BearMood.sleepy,
                        actionLabel: hasFilter ? '清除筛选' : '新建仓鼠',
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
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 88),
                      children: [
                        IosGroupedSection(
                          children: [
                            for (final hamster in values)
                              _HamsterListRow(
                                hamster: hamster,
                                snapshot: snapshot,
                                onTap: widget.onOpenDetail == null
                                    ? null
                                    : () => widget.onOpenDetail!(hamster),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton:
            !hasWritePermission ||
                (widget.onCreate == null && widget.onBatchCreate == null)
            ? null
            : PopupMenuButton<String>(
                tooltip: '建档',
                icon: const Icon(CupertinoIcons.add),
                onSelected: (value) {
                  if (value == 'single') widget.onCreate?.call();
                  if (value == 'batch') widget.onBatchCreate?.call();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'single', child: Text('单只建档')),
                  PopupMenuItem(value: 'batch', child: Text('批量建档')),
                ],
              ),
      );
    },
  );
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
    final weights =
        snapshot.recentWeights.where((w) => w.hamsterId == hamster.id).toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    final latest = weights.isEmpty ? null : weights.first;
    final abnormal = latest != null && evaluateWeightFlags(latest).isNotEmpty;
    return IosListTile(
      onTap: onTap,
      leading: HamsterAvatar(
        label: hamster.name ?? hamster.internalCode,
        imageUrl: hamster.avatarUrl,
        imageBytes: hamster.avatarBytes,
        size: 42,
        statusColor: abnormal ? IosColors.systemRed : null,
      ),
      title: hamster.displayName,
      subtitle:
          '${hamster.corePhenotypeLabel ?? '未填表型'} · '
          '${i2LifecycleLabel(hamster.lifecycleStatus)} · '
          '笼盒 ${_enclosureLabel(snapshot, hamster.currentEnclosureId)}'
          '${latest == null ? '' : ' · ${latest.weightG} g'}'
          '${abnormal ? ' · 体重异常' : ''}',
      trailing: abnormal
          ? const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 16,
              color: IosColors.systemRed,
            )
          : null,
    );
  }
}
