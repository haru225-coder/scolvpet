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
      ok
          ? '头像已更新'
          : widget.controller.avatarState.message ?? '重试失败，请稍后再试',
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
          ok
              ? '头像已移除'
              : widget.controller.avatarState.message ?? '头像移除失败',
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
        final dark = theme.brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: palette.groupedBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: palette.accent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            leading: IconButton(
              tooltip: '返回',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(CupertinoIcons.chevron_left, size: 28),
            ),
            title: Text(
              '仓鼠详情',
              style: TextStyle(
                color: palette.label,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            actions: [
              if (widget.onEdit != null)
                IconButton(
                  tooltip: '编辑资料',
                  onPressed: widget.controller.hasWritePermission
                      ? widget.onEdit
                      : () => showIosMessage(
                          context,
                          '当前角色没有编辑仓鼠档案的权限',
                        ),
                  icon: const Icon(CupertinoIcons.pencil, size: 23),
                ),
            ],
          ),
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.35, -0.4),
                radius: 1.25,
                colors: dark
                    ? const [Color(0xff211b12), _HamsterDetailColors.background]
                    : [palette.accentSoft, palette.groupedBackground],
                stops: const [0, 0.72],
              ),
            ),
            child: Column(
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
          ),
        );
      },
    );
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

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
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
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HamsterDetailMetric(
                  icon: CupertinoIcons.house,
                  label: '笼舍',
                  value: hamster.currentEnclosureId == null ? '—' : '1',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HamsterDetailMetric(
                  icon: CupertinoIcons.square_stack_3d_up,
                  label: '活跃窝次',
                  value: '${detail.litters.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HamsterDetailMetric(
                  icon: CupertinoIcons.star,
                  label: '需关注',
                  value: '$attentionCount',
                  danger: attentionCount > 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HamsterDetailPanel(
            key: const Key('hamster-detail-health-overview'),
            child: Column(
              children: [
                _HamsterDetailSectionTitle(
                  key: const Key('hamster-health-title'),
                  icon: CupertinoIcons.shield_lefthalf_fill,
                  title: '健康概览',
                  trailing: widget.onOpenHealth == null
                      ? null
                      : _HamsterDetailLink(
                          label: '健康记录',
                          onTap: widget.onOpenHealth!,
                        ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        constraints.maxWidth < 360 ||
                        MediaQuery.textScalerOf(context).scale(1) > 1.2;
                    final columns = compact ? 2 : 4;
                    final width =
                        (constraints.maxWidth - 8 * (columns - 1)) / columns;
                    final items = <Widget>[
                      _HamsterDetailHealthItem(
                        icon: CupertinoIcons.drop,
                        label: '健康记录',
                        value: healthRecords.isEmpty
                            ? '待记录'
                            : '${healthRecords.length} 条',
                      ),
                      _HamsterDetailHealthItem(
                        icon: CupertinoIcons.gauge,
                        label: '体重',
                        value: latestWeight == null
                            ? '待记录'
                            : (weightFlags.isEmpty ? '正常' : '需关注'),
                        danger: weightFlags.isNotEmpty,
                      ),
                      _HamsterDetailHealthItem(
                        icon: CupertinoIcons.checkmark_seal,
                        label: '护理待办',
                        value: relatedTasks.isEmpty
                            ? '正常'
                            : '${relatedTasks.length} 项',
                        danger: relatedTasks.any((task) => task.isOverdue),
                      ),
                      _HamsterDetailHealthItem(
                        icon: CupertinoIcons.heart,
                        label: '状态',
                        value: healthGood ? '良好' : '需关注',
                        danger: !healthGood,
                      ),
                    ];
                    return Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: [
                        for (final item in items)
                          SizedBox(width: width, child: item),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _HamsterDetailPanel(
            key: const Key('hamster-detail-recent'),
            child: Column(
              children: [
                _HamsterDetailSectionTitle(
                  icon: CupertinoIcons.doc_text,
                  title: '最近记录',
                  trailing: widget.onOpenHealth == null
                      ? null
                      : _HamsterDetailLink(
                          label: '全部记录',
                          onTap: widget.onOpenHealth!,
                        ),
                ),
                const SizedBox(height: 8),
                if (events.isEmpty)
                  const _HamsterDetailEmptyRow(text: '还没有健康、体重或护理记录')
                else
                  for (final event in events.take(3))
                    _HamsterDetailRecentRow(event: event),
              ],
            ),
          ),
          if (widget.onOpenPedigree != null) ...[
            const SizedBox(height: 12),
            _HamsterDetailPanel(
              key: const Key('hamster-detail-pedigree'),
              child: Column(
                children: [
                  _HamsterDetailSectionTitle(
                    icon: CupertinoIcons.arrow_branch,
                    title: '谱系',
                  ),
                  const SizedBox(height: 12),
                  _HamsterDetailPedigreeCard(
                    litterCount: detail.litters.length,
                    onTap: widget.onOpenPedigree!,
                  ),
                ],
              ),
            ),
          ],
          if (widget.taskController != null) ...[
            const SizedBox(height: 12),
            _HamsterDetailPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HamsterDetailSectionTitle(
                    icon: CupertinoIcons.checkmark_circle,
                    title: '护理待办',
                    trailing: Text(
                      '${relatedTasks.length} 项',
                      style: const TextStyle(
                        color: _HamsterDetailColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '护理与复查安排',
                    key: const Key('hamster-care-tasks-title'),
                    style: const TextStyle(
                      color: _HamsterDetailColors.muted,
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
            const SizedBox(height: 12),
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
          if (widget.onOpenHealth != null ||
              widget.onAddWeight != null ||
              widget.onOpenGenetic != null ||
              widget.onEdit != null) ...[
            const SizedBox(height: 12),
            _HamsterDetailPanel(
              key: const Key('hamster-detail-quick-actions'),
              child: Column(
                children: [
                  const _HamsterDetailSectionTitle(
                    icon: CupertinoIcons.bolt_fill,
                    title: '快捷操作',
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final count = constraints.maxWidth >= 360 ? 4 : 2;
                      final width =
                          (constraints.maxWidth - (count - 1) * 8) / count;
                      final actions = [
                        if (widget.onOpenHealth != null)
                          _HamsterDetailAction(
                            key: const Key('hamster-open-health'),
                            icon: CupertinoIcons.eye,
                            label: '记录观察',
                            onTap: widget.onOpenHealth!,
                          ),
                        if (widget.onAddWeight != null)
                          _HamsterDetailAction(
                            icon: CupertinoIcons.gauge,
                            label: '记录体重',
                            onTap: widget.controller.canWrite
                                ? widget.onAddWeight!
                                : null,
                          ),
                        if (widget.onOpenGenetic != null)
                          _HamsterDetailAction(
                            key: const Key('hamster-open-genetic'),
                            icon: CupertinoIcons.lab_flask,
                            label: '配对推算',
                            onTap: widget.onOpenGenetic!,
                          ),
                        if (widget.onEdit != null)
                          _HamsterDetailAction(
                            icon: CupertinoIcons.pencil,
                            label: '编辑资料',
                            onTap: widget.controller.hasWritePermission
                                ? widget.onEdit!
                                : null,
                          ),
                      ];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final action in actions)
                            SizedBox(width: width, child: action),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

abstract final class _HamsterDetailColors {
  static const background = Color(0xff090b0c);
  static const panel = Color(0xff151718);
  static const line = Color(0x263b3d3d);
  static const gold = Color(0xffffbd58);
  static const goldBright = Color(0xffffd889);
  static const goldSoft = Color(0x1fffbd58);
  static const text = Color(0xfff5eee2);
  static const muted = Color(0xffaaa49c);
  static const green = Color(0xff8be35f);
  static const red = Color(0xffff8176);
}
