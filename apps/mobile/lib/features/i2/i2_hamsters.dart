import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/i2_repository.dart';
import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../genetic/genetic.dart';
import '../health/health_controller.dart';
import '../health/health_models.dart';
import '../tasks/task_controller.dart';
import '../tasks/task_models.dart';
import '../weight/weight_alerts.dart';
import 'i2_controller.dart';
import 'i2_models.dart';
import 'i2_widgets.dart';

String _hamsterWriteRestrictionMessage(
  I2Controller controller,
  String action,
) {
  if (controller.offline) return '当前为离线只读，联网后再$action';
  return '当前角色没有$action的权限';
}

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

class LitterListPage extends StatelessWidget {
  const LitterListPage({super.key, required this.controller});

  final I2Controller controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('窝次')),
      body: Column(
        children: [
          I2OfflineBanner(
            offline: controller.offline,
            lastSyncLabel: controller.lastSyncLabel,
          ),
          Expanded(
            child: I2AsyncStateView<I2Snapshot>(
              state: controller.snapshotState,
              onRetry: controller.retry,
              builder: (snapshot) => snapshot.litters.isEmpty
                  ? const I2StateMessage(
                      icon: CupertinoIcons.person_3,
                      message: '暂无窝次记录',
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                      children: [
                        IosGroupedSection(
                          children: [
                            for (final litter in snapshot.litters)
                              IosListTile(
                                title: i2LitterStateLabel(litter.state),
                                subtitle:
                                    '${i2DateLabel(litter.bornAt)} · '
                                    '初始 ${litter.initialAliveCount} 只 · '
                                    '当前 ${litter.currentManagedCount} 只',
                                trailing: Text(
                                  litter.state,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                showChevron: false,
                              ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

class HamsterEditorPage extends StatefulWidget {
  const HamsterEditorPage({
    super.key,
    required this.controller,
    required this.speciesRuleVersionId,
    this.existing,
    this.onSaved,
  });

  final I2Controller controller;
  final String speciesRuleVersionId;
  final I2Hamster? existing;
  final VoidCallback? onSaved;

  @override
  State<HamsterEditorPage> createState() => _HamsterEditorPageState();
}

class _HamsterEditorPageState extends State<HamsterEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _notes;
  String _sex = 'unknown';
  PhenotypeCatalog? _catalog;
  String? _seriesCode;
  String? _phenotypeLabel;
  String? _catalogError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final value = widget.existing;
    _code = TextEditingController(text: value?.internalCode);
    _name = TextEditingController(text: value?.name);
    _notes = TextEditingController(text: value?.notes);
    _sex = value?.sex ?? 'unknown';
    _seriesCode = value?.coreSeriesCode;
    _phenotypeLabel = value?.corePhenotypeLabel;
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final table = await loadBundledPhenotypeTable();
      if (!mounted) return;
      setState(() {
        _catalog = table.catalog;
        _catalogError = null;
        // Seed defaults
        if (_seriesCode == null && table.catalog.series.isNotEmpty) {
          _seriesCode = table.catalog.series.first.code;
        }
        final ser = table.catalog.seriesByCode(_seriesCode ?? '');
        if (ser != null &&
            (_phenotypeLabel == null ||
                !ser.phenotypes.contains(_phenotypeLabel))) {
          _phenotypeLabel = ser.phenotypes.isNotEmpty
              ? ser.phenotypes.first
              : null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _catalogError = '表型选项暂时不可用，可先手填');
    }
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  String? get _encodedVariety {
    final label = _phenotypeLabel?.trim();
    if (label == null || label.isEmpty) return null;
    final ser = _catalog?.seriesByCode(_seriesCode ?? '');
    // Core-table option → series|label; free text → bare label (allowed).
    if (_seriesCode != null && ser != null && ser.phenotypes.contains(label)) {
      return encodeCoreVarietyCode(_seriesCode!, label);
    }
    return label;
  }

  Future<void> _save() async {
    if (_busy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    try {
      if (!widget.controller.canWrite) {
        await widget.controller.saveDraft(
          I2Draft(
            id: 'hamster-form-${DateTime.now().microsecondsSinceEpoch}',
            kind: 'hamster',
            payload: {
              'internal_code': _code.text.trim(),
              'name': _name.text.trim(),
              'variety_code': _encodedVariety,
            },
          ),
        );
        if (mounted) showIosMessage(context, '已保存到本地草稿，联网后可提交');
        return;
      }
      if (widget.existing == null) {
        await widget.controller.createHamster(
          I2HamsterDraft(
            internalCode: _code.text.trim(),
            name: _name.text.trim().isEmpty ? null : _name.text.trim(),
            speciesRuleVersionId: widget.speciesRuleVersionId,
            sex: _sex,
            sourceType: 'introduced',
            varietyCode: _encodedVariety,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          ),
        );
      } else {
        await widget.controller.updateHamster(
          widget.existing!.id,
          widget.existing!.version,
          I2HamsterUpdate(
            internalCode: _code.text.trim(),
            name: _name.text.trim(),
            varietyCode: _encodedVariety,
            sex: _sex,
            notes: _notes.text.trim(),
          ),
        );
      }
      if (mounted &&
          widget.controller.actionState.status == I2AsyncStatus.data) {
        showIosMessage(context, '仓鼠档案已保存');
        widget.onSaved?.call();
      } else if (mounted && widget.controller.actionState.message != null) {
        showIosMessage(context, widget.controller.actionState.message!);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.existing == null ? '编辑建档' : '编辑仓鼠')),
    body: Form(
      key: _formKey,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const IosSectionHeader('基础信息'),
          IosGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextFormField(
                  controller: _code,
                  decoration: const InputDecoration(
                    labelText: '编号（方便查找） *',
                    filled: false,
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? '请填写内部编号' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: '昵称',
                    filled: false,
                  ),
                ),
              ),
              if (_catalogError != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    _catalogError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              if (_catalog != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: IosPickerField<String>(
                    key: Key('hamster-series-$_seriesCode'),
                    label: '表型系列',
                    selected: _catalog!.series.any((s) => s.code == _seriesCode)
                        ? _seriesCode
                        : (_catalog!.series.isNotEmpty
                              ? _catalog!.series.first.code
                              : null),
                    items: [
                      for (final s in _catalog!.series)
                        IosPickerItem(value: s.code, label: s.name),
                    ],
                    enabled: widget.controller.canWrite && !_busy,
                    onSelected: (value) {
                      if (value == null) return;
                      final ser = _catalog!.seriesByCode(value);
                      setState(() {
                        _seriesCode = value;
                        _phenotypeLabel =
                            ser != null && ser.phenotypes.isNotEmpty
                            ? ser.phenotypes.first
                            : null;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: OptionOrCustomField(
                    key: Key('hamster-phenotype-$_seriesCode'),
                    label: '表型（可选择或手填）',
                    options:
                        _catalog!.seriesByCode(_seriesCode ?? '')?.phenotypes ??
                        const <String>[],
                    value: _phenotypeLabel,
                    allowEmpty: true,
                    customHint: '自定义表型名称',
                    helperText: '列表外名称可以记录；需要推算时请选择列表中的名称',
                    enabled: widget.controller.canWrite && !_busy,
                    onChanged: (value) =>
                        setState(() => _phenotypeLabel = value),
                  ),
                ),
              ],
              // Catalog failed: still allow free-text phenotype.
              if (_catalog == null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextFormField(
                    initialValue: _phenotypeLabel,
                    decoration: const InputDecoration(
                      labelText: '表型（可手填）',
                      filled: false,
                      helperText: '表型选项暂时不可用，可先手填',
                    ),
                    onChanged: (v) =>
                        setState(() => _phenotypeLabel = v.trim()),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: IosPickerField<String>(
                  label: '性别',
                  selected: _sex,
                  items: const [
                    IosPickerItem(value: 'unknown', label: '待定'),
                    IosPickerItem(value: 'male', label: '公'),
                    IosPickerItem(value: 'female', label: '母'),
                  ],
                  enabled: widget.controller.canWrite && !_busy,
                  onSelected: (value) {
                    if (value != null) setState(() => _sex = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const IosSectionHeader('备注'),
          IosGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(
                    labelText: '备注',
                    filled: false,
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          I2WriteButton(
            enabled: widget.controller.canWrite && !_busy,
            label: _busy ? '保存中…' : '保存',
            icon: CupertinoIcons.checkmark_circle_fill,
            onPressed: _save,
          ),
          if (widget.controller.offline)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                '当前为离线只读，保存内容会进入本地草稿。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    ),
  );
}

class BatchHamsterEditorPage extends StatefulWidget {
  const BatchHamsterEditorPage({
    super.key,
    required this.controller,
    required this.speciesRuleVersionId,
    this.onSaved,
  });

  final I2Controller controller;
  final String speciesRuleVersionId;
  final VoidCallback? onSaved;

  @override
  State<BatchHamsterEditorPage> createState() => _BatchHamsterEditorPageState();
}

class _BatchHamsterEditorPageState extends State<BatchHamsterEditorPage> {
  final _codes = TextEditingController();
  final _namePrefix = TextEditingController();
  String _sex = 'unknown';
  bool _busy = false;

  @override
  void dispose() {
    _codes.dispose();
    _namePrefix.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final codes = _codes.text
        .split(RegExp(r'[\s,，;；]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (codes.isEmpty) return;
    setState(() => _busy = true);
    try {
      await widget.controller.createHamsters(
        codes
            .map(
              (code) => I2HamsterDraft(
                internalCode: code,
                name: _namePrefix.text.trim().isEmpty
                    ? null
                    : '${_namePrefix.text.trim()}$code',
                speciesRuleVersionId: widget.speciesRuleVersionId,
                sex: _sex,
                sourceType: 'born_here',
              ),
            )
            .toList(),
      );
      if (mounted &&
          widget.controller.actionState.status == I2AsyncStatus.data) {
        showIosMessage(context, '仓鼠档案已保存');
        widget.onSaved?.call();
      } else if (mounted && widget.controller.actionState.message != null) {
        showIosMessage(context, widget.controller.actionState.message!);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('批量建档')),
    body: ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        const IosSectionHeader('编号'),
        IosGroupedSection(
          margin: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _codes,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: '内部编号 *',
                  hintText: '可用换行、逗号或分号分隔',
                  filled: false,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const IosSectionHeader('公共属性'),
        IosGroupedSection(
          margin: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _namePrefix,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: '公共昵称前缀（可选）',
                  filled: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: IosPickerField<String>(
                label: '公共性别',
                selected: _sex,
                items: const [
                  IosPickerItem(value: 'unknown', label: '待定'),
                  IosPickerItem(value: 'male', label: '公'),
                  IosPickerItem(value: 'female', label: '母'),
                ],
                enabled: widget.controller.canWrite && !_busy,
                onSelected: (value) {
                  if (value != null) setState(() => _sex = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        I2WriteButton(
          enabled: widget.controller.canWrite && !_busy,
          label: _busy ? '保存中…' : '逐只确认并提交',
          icon: CupertinoIcons.list_bullet_below_rectangle,
          onPressed: _save,
        ),
      ],
    ),
  );
}

class WeightEntryPage extends StatefulWidget {
  const WeightEntryPage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.onSaved,
  });

  final I2Controller controller;
  final String hamsterId;
  final VoidCallback? onSaved;

  @override
  State<WeightEntryPage> createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends State<WeightEntryPage> {
  final _weight = TextEditingController();
  final _notes = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _weight.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final normalized = _weight.text.trim().replaceAll(',', '.');
    final value = num.tryParse(normalized);
    if (value == null || value <= 0) {
      showIosMessage(context, '请输入大于 0 的克值');
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.controller.createWeight(
        I2WeightDraft(
          hamsterId: widget.hamsterId,
          weightG: value,
          recordedAt: DateTime.now(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      );
      if (mounted &&
          widget.controller.actionState.status == I2AsyncStatus.data) {
        final latest = widget.controller.weightState.data;
        final alert =
            latest != null &&
            latest.isNotEmpty &&
            latest.first.alertFlags.isNotEmpty;
        showIosMessage(
          context,
          alert ? '已保存 $value g（检测到体重异常）' : '已保存 $value g',
        );
        widget.onSaved?.call();
      } else if (mounted && widget.controller.actionState.message != null) {
        showIosMessage(context, widget.controller.actionState.message!);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final busy =
          _busy ||
          widget.controller.actionState.status == I2AsyncStatus.loading;
      return Scaffold(
        appBar: AppBar(title: const Text('录入体重')),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            I2OfflineBanner(
              offline: widget.controller.offline,
              lastSyncLabel: widget.controller.lastSyncLabel,
            ),
            Text(
              '单位：克（g）。输入后点保存；服务端会快照上次体重差，客户端会标记掉重或过低。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            const IosSectionHeader('体重'),
            IosGroupedSection(
              margin: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: TextField(
                    controller: _weight,
                    enabled: widget.controller.canWrite && !busy,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '体重（g） *',
                      helperText: '必须 > 0',
                      filled: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: TextField(
                    controller: _notes,
                    enabled: widget.controller.canWrite && !busy,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            I2WriteButton(
              enabled: widget.controller.canWrite && !busy,
              label: busy ? '保存中…' : '保存体重',
              icon: CupertinoIcons.checkmark_circle_fill,
              onPressed: _save,
            ),
          ],
        ),
      );
    },
  );
}
