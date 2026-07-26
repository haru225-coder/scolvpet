part of 'i2_hamsters.dart';

class HamsterDetailPage extends StatefulWidget {
  const HamsterDetailPage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.onEdit,
    this.onAddWeight,
    this.onOpenPedigree,
    this.onOpenHealth,
    this.onOpenGenetic,
    this.taskController,
    this.healthController,
  });

  final I2Controller controller;
  final String hamsterId;
  final VoidCallback? onEdit;
  final VoidCallback? onAddWeight;
  final VoidCallback? onOpenPedigree;
  final VoidCallback? onOpenHealth;

  /// Opens genetic hub with this hamster prefilled as sire/dam.
  final VoidCallback? onOpenGenetic;
  final TaskController? taskController;
  final HealthController? healthController;

  @override
  State<HamsterDetailPage> createState() => _HamsterDetailPageState();
}

class _HamsterDetailPageState extends State<HamsterDetailPage> {
  final ImagePicker _imagePicker = ImagePicker();

  /// V0.0.5：身份 / 血统 / 繁育价值 / 健康记录 / 成长记录。
  /// 仅调整表现层顺序，不改变领域模型或数据来源。
  int _section = 0;

  static const _sections = <(String, String)>[
    ('overview', '身份'),
    ('pedigree', '血统'),
    ('breeding', '繁育价值'),
    ('health', '健康记录'),
    ('records', '成长记录'),
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.loadHamsterDetail(widget.hamsterId);
    widget.taskController?.refresh();
    widget.healthController?.loadForHamster(widget.hamsterId);
  }

  Future<void> _completeTask(CareTaskItem task) async {
    final tc = widget.taskController;
    if (tc == null) return;
    final ok = await tc.complete(task);
    if (!mounted) return;
    final message = tc.lastMessage;
    if (message != null) {
      showIosMessage(context, message);
    }
    if (ok) setState(() {});
  }

  Future<void> _chooseAvatar(I2Hamster hamster) async {
    XFile? image;
    try {
      image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );
    } on PlatformException {
      if (mounted) {
        showIosMessage(context, '无法读取相册，请在系统设置中允许访问照片');
      }
      return;
    } on Object {
      if (mounted) showIosMessage(context, '照片选择未完成，请稍后再试');
      return;
    }
    if (image == null || !mounted) return;
    final extension = image.name.contains('.')
        ? image.name.toLowerCase().split('.').last
        : '';
    if (!const {'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      showIosMessage(context, '请选择 JPG、PNG 或 WebP 图片');
      return;
    }
    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    Uint8List bytes;
    try {
      bytes = await image.readAsBytes();
    } on Object {
      if (mounted) showIosMessage(context, '照片读取失败，请重新选择');
      return;
    }
    if (bytes.isEmpty) {
      if (mounted) showIosMessage(context, '所选照片为空，请重新选择');
      return;
    }
    if (bytes.length > 20 * 1024 * 1024) {
      if (mounted) showIosMessage(context, '头像文件需小于 20 MB');
      return;
    }
    final ok = await widget.controller.uploadAvatar(
      hamster,
      I2AvatarUpload(
        bytes: bytes,
        fileName: image.name,
        contentType: contentType,
      ),
    );
    if (!mounted) return;
    if (ok) {
      showIosMessage(context, '头像已更新');
    } else {
      await _showAvatarFailure();
    }
  }

  Future<void> _showAvatarFailure() async {
    final message = widget.controller.avatarState.message ?? '头像上传失败';
    final retry = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('头像未更新'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('稍后处理'),
          ),
          if (widget.controller.canRetryAvatarUpload)
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('重试'),
            ),
        ],
      ),
    );
    if (retry != true || !mounted) return;
    final ok = await widget.controller.retryAvatarUpload();
    if (!mounted) return;
    showIosMessage(
      context,
      ok ? '头像已更新' : widget.controller.avatarState.message ?? '重试失败，请稍后再试',
    );
  }

  Future<void> _manageAvatar(I2Hamster hamster) async {
    if (!widget.controller.canWrite) {
      showIosMessage(
        context,
        _hamsterWriteRestrictionMessage(widget.controller, '修改头像'),
      );
      return;
    }
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('仓鼠头像'),
        message: const Text('图片会裁切为正方形缩略图，原图仍保留在媒体库。'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, 'pick'),
            child: Text(hamster.coverMediaId == null ? '从相册选择' : '更换头像'),
          ),
          if (hamster.coverMediaId != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context, 'remove'),
              child: const Text('移除头像'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
    if (action == 'pick') await _chooseAvatar(hamster);
    if (action == 'remove') {
      final ok = await widget.controller.removeAvatar(hamster);
      if (mounted) {
        showIosMessage(
          context,
          ok ? '头像已移除' : widget.controller.avatarState.message ?? '头像移除失败',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[widget.controller];
    if (widget.taskController != null) {
      listenables.add(widget.taskController!);
    }
    if (widget.healthController != null) {
      listenables.add(widget.healthController!);
    }
    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) {
        final theme = Theme.of(context);
        final palette = ScolvPalette.of(context);
        return Scaffold(
          backgroundColor: palette.groupedBackground,
          appBar: AppBar(
            backgroundColor: palette.groupedBackground,
            foregroundColor: palette.label,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            leading: IconButton(
              tooltip: '返回',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(CupertinoIcons.chevron_left, size: 26),
            ),
            title: Text(
              '个体档案',
              style: theme.textTheme.titleMedium?.copyWith(
                color: palette.label,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (widget.onEdit != null)
                IconButton(
                  tooltip: '更多',
                  onPressed: () => _openMoreActions(context),
                  icon: Icon(
                    CupertinoIcons.ellipsis_circle,
                    color: palette.secondaryLabel,
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              if (widget.controller.offline)
                _HamsterDetailOfflineBanner(
                  lastSyncLabel: widget.controller.lastSyncLabel,
                ),
              if (!widget.controller.hasWritePermission &&
                  !widget.controller.offline)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看仓鼠档案，编辑、头像和体重操作已设为只读。',
                  ),
                ),
              Expanded(
                child: I2AsyncStateView<I2HamsterDetail>(
                  state: widget.controller.hamsterDetailState,
                  onRetry: () =>
                      widget.controller.loadHamsterDetail(widget.hamsterId),
                  builder: _buildDetailCanvas,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openMoreActions(BuildContext context) async {
    final choice = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          if (widget.onEdit != null)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, 'edit'),
              child: const Text('编辑资料'),
            ),
          if (widget.onAddWeight != null)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, 'weight'),
              child: const Text('记录体重'),
            ),
          if (widget.onOpenHealth != null)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, 'health'),
              child: const Text('健康记录'),
            ),
          if (widget.onOpenGenetic != null)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, 'genetic'),
              child: const Text('配对推算'),
            ),
          if (widget.onOpenPedigree != null)
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx, 'pedigree'),
              child: const Text('查看血统'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
    if (!context.mounted || choice == null) return;
    switch (choice) {
      case 'edit':
        if (widget.controller.hasWritePermission) {
          widget.onEdit?.call();
        } else {
          showIosMessage(context, '当前角色没有编辑仓鼠档案的权限');
        }
      case 'weight':
        if (widget.controller.canWrite) {
          widget.onAddWeight?.call();
        } else {
          showIosMessage(
            context,
            _hamsterWriteRestrictionMessage(widget.controller, '记录体重'),
          );
        }
      case 'health':
        widget.onOpenHealth?.call();
      case 'genetic':
        widget.onOpenGenetic?.call();
      case 'pedigree':
        widget.onOpenPedigree?.call();
    }
  }

  Widget _buildDetailCanvas(I2HamsterDetail detail) {
    final snapshot = widget.controller.snapshotState.data;
    final hamster = detail.hamster;
    final enclosureLabel = _enclosureLabel(
      snapshot,
      hamster.currentEnclosureId,
    );
    final relatedTasks = CareTaskItem.openForHamster(
      widget.taskController?.listState.data ?? const <CareTaskItem>[],
      widget.hamsterId,
    );
    final healthRecords =
        widget.healthController?.listState.data ?? const <HealthRecordItem>[];
    final latestWeight = _latestWeight(detail.weights);
    final weightFlags = latestWeight == null
        ? const <String>[]
        : evaluateWeightFlags(latestWeight);
    final healthConcern = healthRecords.any(
      (record) => record.severity == 'high' || record.severity == 'critical',
    );
    final attentionCount =
        relatedTasks.where((task) => task.isOverdue).length +
        (weightFlags.isEmpty ? 0 : 1) +
        (healthConcern ? 1 : 0);
    final healthGood = attentionCount == 0;
    final events = _recentDetailEvents(
      healthRecords: healthRecords,
      weights: detail.weights,
    );

    final sectionKey = _sections[_section].$1;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HamsterDetailProfileCard(
            hamster: hamster,
            enclosureLabel: enclosureLabel,
            latestWeight: latestWeight,
            healthGood: healthGood,
            offline: widget.controller.offline,
            onCopyId: () async {
              await Clipboard.setData(
                ClipboardData(text: hamster.internalCode),
              );
              if (mounted) showIosMessage(context, '档案编号已复制');
            },
            onAvatarTap: () => _manageAvatar(hamster),
            avatarLoading:
                widget.controller.avatarState.status == I2AsyncStatus.loading,
            onEdit: widget.onEdit == null
                ? null
                : () {
                    if (widget.controller.hasWritePermission) {
                      widget.onEdit!();
                    } else {
                      showIosMessage(context, '当前角色没有编辑仓鼠档案的权限');
                    }
                  },
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _sections.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      right: i == _sections.length - 1 ? 0 : 8,
                    ),
                    child: _DetailSectionChip(
                      key: Key('hamster-detail-section-${_sections[i].$1}'),
                      label: _sections[i].$2,
                      selected: _section == i,
                      onTap: () => setState(() => _section = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (sectionKey == 'overview') ...[
            _HamsterDetailArchiveSection(
              key: const Key('hamster-detail-archive'),
              hamster: hamster,
              enclosureLabel: enclosureLabel,
              latestWeight: latestWeight,
            ),
            const SizedBox(height: 16),
            _HamsterDetailPanel(
              child: Column(
                children: [
                  const _HamsterDetailSectionTitle(
                    icon: CupertinoIcons.heart,
                    title: '繁育价值',
                  ),
                  const SizedBox(height: 12),
                  _HamsterDetailFieldTable(
                    rows: [
                      ('当前状态', i2BreedingStatusLabel(hamster.breedingStatus)),
                      ('关联窝次', '${detail.litters.length}'),
                    ],
                  ),
                ],
              ),
            ),
          ] else if (sectionKey == 'breeding') ...[
            _HamsterDetailBreedingSection(
              key: const Key('hamster-detail-breeding'),
              litterCount: detail.litters.length,
              breedingStatus: hamster.breedingStatus,
              onOpenPedigree: widget.onOpenPedigree,
              onOpenGenetic: widget.onOpenGenetic,
            ),
          ] else if (sectionKey == 'health') ...[
            _HamsterDetailPanel(
              key: const Key('hamster-detail-health-overview'),
              child: Column(
                children: [
                  _HamsterDetailSectionTitle(
                    key: const Key('hamster-health-title'),
                    icon: CupertinoIcons.heart,
                    title: '健康记录',
                    trailing: widget.onOpenHealth == null
                        ? null
                        : _HamsterDetailLink(
                            label: '健康记录',
                            onTap: widget.onOpenHealth!,
                          ),
                  ),
                  const SizedBox(height: 12),
                  _HamsterDetailFieldTable(
                    rows: [
                      (
                        '健康记录',
                        healthRecords.isEmpty
                            ? '暂无'
                            : '${healthRecords.length} 条',
                      ),
                      (
                        '体重状态',
                        latestWeight == null
                            ? '暂无'
                            : (weightFlags.isEmpty ? '正常' : '需关注'),
                      ),
                      (
                        '护理待办',
                        relatedTasks.isEmpty ? '无' : '${relatedTasks.length} 项',
                      ),
                      ('综合', healthGood ? '良好' : '需关注'),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.taskController != null) ...[
              const SizedBox(height: 16),
              _HamsterDetailPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HamsterDetailSectionTitle(
                      icon: CupertinoIcons.checkmark_circle,
                      title: '护理待办',
                      trailing: Text(
                        '${relatedTasks.length} 项',
                        style: TextStyle(
                          color: ScolvPalette.of(context).secondaryLabel,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '护理与复查安排',
                      key: const Key('hamster-care-tasks-title'),
                      style: TextStyle(
                        color: ScolvPalette.of(context).secondaryLabel,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (relatedTasks.isEmpty)
                      const _HamsterDetailEmptyRow(text: '暂无与此个体相关的待办')
                    else
                      for (final task in relatedTasks)
                        _HamsterDetailTaskRow(
                          task: task,
                          enabled: widget.controller.canWrite,
                          onComplete: () => _completeTask(task),
                        ),
                  ],
                ),
              ),
            ],
            if (widget.onAddWeight != null || detail.weights.isNotEmpty) ...[
              const SizedBox(height: 16),
              _HamsterDetailPanel(
                child: Column(
                  children: [
                    _HamsterDetailSectionTitle(
                      icon: CupertinoIcons.gauge,
                      title: '体重历史',
                      trailing: widget.onAddWeight == null
                          ? null
                          : _HamsterDetailLink(
                              label: '录入',
                              onTap: widget.controller.canWrite
                                  ? widget.onAddWeight!
                                  : null,
                            ),
                    ),
                    const SizedBox(height: 8),
                    if (detail.weights.isEmpty)
                      const _HamsterDetailEmptyRow(text: '暂无体重记录')
                    else
                      for (final weight in detail.weights.take(4))
                        _HamsterDetailWeightRow(weight: weight),
                  ],
                ),
              ),
            ],
            if (widget.onAddWeight != null || widget.onOpenHealth != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (widget.onAddWeight != null)
                    Expanded(
                      child: FilledButton.tonal(
                        key: const Key('hamster-detail-primary-weight'),
                        onPressed: widget.controller.canWrite
                            ? widget.onAddWeight
                            : null,
                        child: const Text('记录体重'),
                      ),
                    ),
                  if (widget.onAddWeight != null && widget.onOpenHealth != null)
                    const SizedBox(width: 10),
                  if (widget.onOpenHealth != null)
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('hamster-open-health'),
                        onPressed: widget.onOpenHealth,
                        child: const Text('记录观察'),
                      ),
                    ),
                ],
              ),
            ],
          ] else if (sectionKey == 'pedigree') ...[
            _HamsterDetailPanel(
              key: const Key('hamster-detail-pedigree'),
              child: Column(
                children: [
                  const _HamsterDetailSectionTitle(
                    icon: CupertinoIcons.arrow_branch,
                    title: '血统档案',
                  ),
                  const SizedBox(height: 8),
                  const _HamsterDetailEmptyRow(
                    text: '父母与祖代关系在血统档案页查看；确认父母并完成个体化后会自动展开。',
                  ),
                  if (widget.onOpenPedigree != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const Key('hamster-detail-open-pedigree-tab'),
                        onPressed: widget.onOpenPedigree,
                        child: const Text('打开血统档案'),
                      ),
                    ),
                  ],
                  if (widget.onOpenGenetic != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: widget.onOpenGenetic,
                        child: const Text('繁育模拟'),
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            _HamsterDetailPanel(
              key: const Key('hamster-detail-recent'),
              child: Column(
                children: [
                  _HamsterDetailSectionTitle(
                    icon: CupertinoIcons.doc_text,
                    title: '成长记录',
                    trailing: widget.onOpenHealth == null
                        ? null
                        : _HamsterDetailLink(
                            label: '全部',
                            onTap: widget.onOpenHealth!,
                          ),
                  ),
                  const SizedBox(height: 8),
                  if (events.isEmpty)
                    const _HamsterDetailEmptyRow(text: '还没有健康、体重或护理记录')
                  else
                    for (final event in events.take(8))
                      _HamsterDetailRecentRow(event: event),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 详情顶部分段 chip（草稿：概览/繁育/健康/血统/记录）
class _DetailSectionChip extends StatelessWidget {
  const _DetailSectionChip({
    super.key,
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
      color: selected ? p.accent.withValues(alpha: 0.14) : p.tertiaryFill,
      borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? p.accent : p.secondaryLabel,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
