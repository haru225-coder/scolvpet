import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scolvpet_api/scolvpet_api.dart' as api;
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/product_surface.dart';
import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_motion.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2.dart';

enum DataCenterTaskKind { export, backup }

enum DataCenterTaskStatus { queued, running, succeeded, failed, expired }

extension DataCenterTaskKindLabel on DataCenterTaskKind {
  String get label => switch (this) {
    DataCenterTaskKind.export => '导出数据',
    DataCenterTaskKind.backup => '备份数据',
  };
}

extension DataCenterTaskStatusLabel on DataCenterTaskStatus {
  String get label => switch (this) {
    DataCenterTaskStatus.queued => '排队中',
    DataCenterTaskStatus.running => '处理中',
    DataCenterTaskStatus.succeeded => '已完成',
    DataCenterTaskStatus.failed => '失败',
    DataCenterTaskStatus.expired => '已过期',
  };

  Color color(BuildContext context) => switch (this) {
    DataCenterTaskStatus.queued => ScolvPalette.of(context).secondaryLabel,
    DataCenterTaskStatus.running => IosColors.systemBlue,
    DataCenterTaskStatus.succeeded => IosColors.systemGreen,
    DataCenterTaskStatus.failed => IosColors.systemRed,
    DataCenterTaskStatus.expired => IosColors.systemOrange,
  };
}

class DataCenterTask {
  const DataCenterTask({
    required this.id,
    required this.kind,
    required this.status,
    required this.progressPercent,
    this.version = 1,
    this.detail,
    this.retryable = false,
    this.expiresAt,
    this.fileName,
    this.sizeLabel,
    this.sha256,
    this.errorMessage,
  });

  final String id;
  final DataCenterTaskKind kind;
  final DataCenterTaskStatus status;
  final int progressPercent;
  final int version;
  final String? detail;
  final bool retryable;
  final DateTime? expiresAt;
  final String? fileName;
  final String? sizeLabel;
  final String? sha256;
  final String? errorMessage;

  bool get canDownload =>
      status == DataCenterTaskStatus.succeeded &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));
}

class DataCenterDownloadLink {
  const DataCenterDownloadLink({
    required this.url,
    required this.fileName,
    required this.sizeLabel,
    required this.sha256,
    required this.expiresAt,
  });

  final String url;
  final String fileName;
  final String sizeLabel;
  final String sha256;
  final DateTime expiresAt;
}

class DataCenterUsageMetric {
  const DataCenterUsageMetric({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    this.limit,
  });

  final String key;
  final String label;
  final num? value;
  final String unit;
  final num? limit;

  bool get hasValue => value != null;
}

class DataCenterUsageSummary {
  const DataCenterUsageSummary({
    this.metrics = const <DataCenterUsageMetric>[],
    this.measuredAt,
  });

  final List<DataCenterUsageMetric> metrics;
  final DateTime? measuredAt;

  bool get isEmpty => metrics.isEmpty;
}

class DataCenterBackupSummary {
  const DataCenterBackupSummary({
    required this.status,
    required this.sizeLabel,
    required this.restoreReadiness,
    this.createdAt,
    this.sha256,
  });

  final DataCenterTaskStatus status;
  final String sizeLabel;
  final String restoreReadiness;
  final DateTime? createdAt;
  final String? sha256;
}

class DataCenterSnapshot {
  const DataCenterSnapshot({
    this.exportTasks = const <DataCenterTask>[],
    this.backupTasks = const <DataCenterTask>[],
    this.usage = const DataCenterUsageSummary(),
    this.latestBackup,
  });

  static const empty = DataCenterSnapshot();

  final List<DataCenterTask> exportTasks;
  final List<DataCenterTask> backupTasks;
  final DataCenterUsageSummary usage;
  final DataCenterBackupSummary? latestBackup;

  bool get isEmpty =>
      exportTasks.isEmpty &&
      backupTasks.isEmpty &&
      usage.isEmpty &&
      latestBackup == null;

  List<DataCenterTask> tasksFor(DataCenterTaskKind kind) => switch (kind) {
    DataCenterTaskKind.export => exportTasks,
    DataCenterTaskKind.backup => backupTasks,
  };
}

abstract interface class DataCenterRepository {
  Future<DataCenterSnapshot> load();

  Future<void> createTask(DataCenterTaskKind kind);

  Future<void> retryTask(DataCenterTask task);

  Future<DataCenterDownloadLink> getDownloadLink(DataCenterTask task);
}

class DataCenterRepositoryException implements Exception {
  const DataCenterRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DefaultApiDataCenterRepository implements DataCenterRepository {
  DefaultApiDataCenterRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  @override
  Future<DataCenterSnapshot> load() async {
    final response = await client.api.getDataCenterSummary();
    final data = response.data?.data;
    if (data == null) {
      throw const DataCenterRepositoryException('数据中心响应为空');
    }
    final exports = data.recentExports.map(_exportTask).toList();
    final backups = data.recentBackups.map(_backupTask).toList();
    final latest = data.recentBackups.isEmpty
        ? null
        : _backupSummary(data.recentBackups.first);
    return DataCenterSnapshot(
      exportTasks: exports,
      backupTasks: backups,
      usage: DataCenterUsageSummary(
        metrics: data.usage.map(_usageMetric).toList(),
        measuredAt: data.usage.isEmpty ? null : data.usage.first.measuredAt,
      ),
      latestBackup: latest,
    );
  }

  @override
  Future<void> createTask(DataCenterTaskKind kind) async {
    if (kind == DataCenterTaskKind.export) {
      await client.api.createExportJob(
        idempotencyKey: 'export-${_uuid.v4()}',
        exportJobCreateRequest: api.ExportJobCreateRequest(
          datasets: {
            api.ExportJobCreateRequestDatasetsEnum.hamsters,
            api.ExportJobCreateRequestDatasetsEnum.enclosures,
            api.ExportJobCreateRequestDatasetsEnum.breeding,
            api.ExportJobCreateRequestDatasetsEnum.litters,
            api.ExportJobCreateRequestDatasetsEnum.weights,
            api.ExportJobCreateRequestDatasetsEnum.health,
            api.ExportJobCreateRequestDatasetsEnum.pedigree,
          },
          format: api.ExportJobCreateRequestFormatEnum.json,
          timezone: 'Asia/Shanghai',
        ),
      );
      return;
    }
    await client.api.createBackupJob(
      idempotencyKey: 'backup-${_uuid.v4()}',
      backupJobCreateRequest: api.BackupJobCreateRequest(
        includeMediaManifest:
            api.BackupJobCreateRequestIncludeMediaManifestEnum.true_,
        includeChecksums: api.BackupJobCreateRequestIncludeChecksumsEnum.true_,
        timezone: 'Asia/Shanghai',
      ),
    );
  }

  @override
  Future<void> retryTask(DataCenterTask task) async {
    final request = api.RetryJobRequest(reason: '用户在数据中心发起重试');
    final idempotencyKey = 'retry-${task.kind.name}-${_uuid.v4()}';
    final ifMatch = '"${task.version}"';
    if (task.kind == DataCenterTaskKind.export) {
      await client.api.retryExportJob(
        idempotencyKey: idempotencyKey,
        ifMatch: ifMatch,
        jobId: task.id,
        retryJobRequest: request,
      );
      return;
    }
    await client.api.retryBackupJob(
      idempotencyKey: idempotencyKey,
      ifMatch: ifMatch,
      jobId: task.id,
      retryJobRequest: request,
    );
  }

  @override
  Future<DataCenterDownloadLink> getDownloadLink(DataCenterTask task) async {
    final response = task.kind == DataCenterTaskKind.export
        ? await client.api.getExportDownload(jobId: task.id)
        : await client.api.getBackupDownload(jobId: task.id);
    final value = response.data?.data;
    if (value == null) {
      throw const DataCenterRepositoryException('下载信息为空，请刷新后重试');
    }
    return DataCenterDownloadLink(
      url: value.downloadUrl,
      fileName: value.fileName,
      sizeLabel: _bytes(value.sizeBytes),
      sha256: value.sha256,
      expiresAt: value.expiresAt,
    );
  }

  DataCenterTask _exportTask(api.ExportJob value) => DataCenterTask(
    id: value.id,
    kind: DataCenterTaskKind.export,
    status: _status(value.status.value, value.expiresAt),
    progressPercent: value.progressPercent,
    version: value.version,
    detail: value.currentStep,
    retryable: value.retryable,
    expiresAt: value.expiresAt,
    fileName: value.fileName,
    sizeLabel: value.sizeBytes == null ? null : _bytes(value.sizeBytes),
    sha256: value.sha256,
    errorMessage: value.error?.message,
  );

  DataCenterTask _backupTask(api.BackupJob value) => DataCenterTask(
    id: value.id,
    kind: DataCenterTaskKind.backup,
    status: _status(value.status.value, value.expiresAt),
    progressPercent: value.progressPercent,
    version: value.version,
    detail: value.currentStep,
    retryable: value.retryable,
    expiresAt: value.expiresAt,
    sizeLabel: value.sizeBytes == null ? null : _bytes(value.sizeBytes),
    sha256: value.sha256,
    errorMessage: value.error?.message,
  );

  DataCenterBackupSummary _backupSummary(api.BackupJob value) =>
      DataCenterBackupSummary(
        status: _status(value.status.value, value.expiresAt),
        sizeLabel: _bytes(value.sizeBytes),
        restoreReadiness: value.restoreReadiness.value,
        createdAt: value.createdAt,
        sha256: value.sha256,
      );

  DataCenterUsageMetric _usageMetric(api.UsageMetric value) {
    final key = value.metric.value;
    return DataCenterUsageMetric(
      key: key,
      label: _usageLabel(key),
      value: value.used,
      unit: _usageUnit(key, value.unit.value),
      limit: value.limit,
    );
  }

  DataCenterTaskStatus _status(String value, DateTime? expiresAt) {
    if (expiresAt != null && expiresAt.isBefore(DateTime.now())) {
      return DataCenterTaskStatus.expired;
    }
    return switch (value) {
      'queued' => DataCenterTaskStatus.queued,
      'running' => DataCenterTaskStatus.running,
      'succeeded' || 'partially_succeeded' => DataCenterTaskStatus.succeeded,
      _ => DataCenterTaskStatus.failed,
    };
  }

  String _usageLabel(String key) => switch (key) {
    'active_hamsters' => '活跃仓鼠',
    'active_litters' => '活跃窝次',
    'enclosures' => '笼盒',
    'media_bytes' => '媒体空间',
    'video_minutes' => '视频时长',
    'backup_bytes' => '备份空间',
    _ => key,
  };

  String _usageUnit(String key, String apiUnit) => switch (key) {
    'active_hamsters' => '只',
    'active_litters' => '窝',
    'enclosures' => '个',
    'video_minutes' => '分钟',
    'media_bytes' || 'backup_bytes' => 'bytes',
    _ => apiUnit,
  };

  String _bytes(int? value) {
    if (value == null) return '—';
    if (value < 1024) return '$value B';
    if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
    if (value < 1024 * 1024 * 1024) {
      return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

enum DataCenterLoadStatus { idle, loading, data, empty, error }

class DataCenterLoadState {
  const DataCenterLoadState._({required this.status, this.data, this.message});

  const DataCenterLoadState.idle() : this._(status: DataCenterLoadStatus.idle);

  const DataCenterLoadState.loading()
    : this._(status: DataCenterLoadStatus.loading);

  const DataCenterLoadState.data(DataCenterSnapshot value)
    : this._(status: DataCenterLoadStatus.data, data: value);

  const DataCenterLoadState.empty({String? message})
    : this._(status: DataCenterLoadStatus.empty, message: message);

  const DataCenterLoadState.error(String value)
    : this._(status: DataCenterLoadStatus.error, message: value);

  final DataCenterLoadStatus status;
  final DataCenterSnapshot? data;
  final String? message;
}

typedef DataCenterLoader = Future<DataCenterSnapshot> Function();
typedef DataCenterTaskAction = Future<void> Function(DataCenterTaskKind kind);
typedef DataCenterTaskRetryAction = Future<void> Function(DataCenterTask task);
typedef DataCenterDownloadAction =
    Future<DataCenterDownloadLink> Function(DataCenterTask task);

class DataCenterController extends ChangeNotifier {
  DataCenterController({
    DataCenterLoader? loader,
    DataCenterTaskAction? action,
    DataCenterTaskRetryAction? retryAction,
    DataCenterDownloadAction? downloadAction,
    DataCenterSnapshot? initial,
  }) : _loader = loader ?? (() async => initial ?? DataCenterSnapshot.empty),
       _action = action,
       _retryAction = retryAction,
       _downloadAction = downloadAction,
       state = initial == null
           ? const DataCenterLoadState.idle()
           : initial.isEmpty
           ? const DataCenterLoadState.empty(message: '暂无任务、备份和用量数据')
           : DataCenterLoadState.data(initial);

  final DataCenterLoader _loader;
  final DataCenterTaskAction? _action;
  final DataCenterTaskRetryAction? _retryAction;
  final DataCenterDownloadAction? _downloadAction;

  final Set<DataCenterTaskKind> _creatingKinds = <DataCenterTaskKind>{};
  final Set<String> _busyTaskIds = <String>{};

  DataCenterLoadState state;
  String? lastActionMessage;

  bool isCreating(DataCenterTaskKind kind) => _creatingKinds.contains(kind);

  bool isTaskBusy(DataCenterTask task) => _busyTaskIds.contains(task.id);

  Future<void> restore({bool clearActionMessage = true}) async {
    state = const DataCenterLoadState.loading();
    if (clearActionMessage) lastActionMessage = null;
    notifyListeners();
    try {
      final snapshot = await _loader();
      state = snapshot.isEmpty
          ? const DataCenterLoadState.empty(message: '暂无任务、备份和用量数据')
          : DataCenterLoadState.data(snapshot);
    } on Object {
      state = const DataCenterLoadState.error('数据中心摘要加载失败，请稍后重试');
    }
    notifyListeners();
  }

  Future<void> retry() => restore();

  Future<bool> createTask(DataCenterTaskKind kind) async {
    if (_creatingKinds.contains(kind)) return false;
    final action = _action;
    if (action == null) {
      requestTask(kind);
      return false;
    }
    _creatingKinds.add(kind);
    lastActionMessage = null;
    notifyListeners();
    try {
      await action(kind);
      await restore(clearActionMessage: false);
      lastActionMessage = '${kind.label}已提交';
      notifyListeners();
      return true;
    } on Object catch (error) {
      lastActionMessage = error.toString();
      notifyListeners();
      return false;
    } finally {
      _creatingKinds.remove(kind);
      notifyListeners();
    }
  }

  Future<bool> retryTask(DataCenterTask task) async {
    if (_busyTaskIds.contains(task.id)) return false;
    final action = _retryAction;
    if (action == null) {
      lastActionMessage = '当前数据中心未连接重试接口';
      notifyListeners();
      return false;
    }
    _busyTaskIds.add(task.id);
    lastActionMessage = null;
    notifyListeners();
    try {
      await action(task);
      await restore(clearActionMessage: false);
      lastActionMessage = '${task.kind.label}重试已提交';
      notifyListeners();
      return true;
    } on Object catch (error) {
      lastActionMessage = error.toString();
      notifyListeners();
      return false;
    } finally {
      _busyTaskIds.remove(task.id);
      notifyListeners();
    }
  }

  Future<DataCenterDownloadLink?> getDownloadLink(DataCenterTask task) async {
    if (_busyTaskIds.contains(task.id)) return null;
    final action = _downloadAction;
    if (action == null) {
      lastActionMessage = '当前数据中心未连接下载接口';
      notifyListeners();
      return null;
    }
    _busyTaskIds.add(task.id);
    lastActionMessage = null;
    notifyListeners();
    try {
      final link = await action(task);
      lastActionMessage = '下载链接已准备，可通过系统菜单保存或发送';
      notifyListeners();
      return link;
    } on Object catch (error) {
      lastActionMessage = error.toString();
      notifyListeners();
      return null;
    } finally {
      _busyTaskIds.remove(task.id);
      notifyListeners();
    }
  }

  void requestTask(DataCenterTaskKind kind) {
    lastActionMessage = '当前数据中心未连接${kind.label}接口';
    notifyListeners();
  }

  void clearActionMessage() {
    if (lastActionMessage == null) return;
    lastActionMessage = null;
    notifyListeners();
  }
}

class DataCenterPage extends StatefulWidget {
  const DataCenterPage({
    super.key,
    required this.i2Controller,
    this.controller,
    this.repository,
    this.onOpenMediaLibrary,
    this.onOpenPublicShares,
    this.canWrite = true,
  });

  final I2Controller i2Controller;
  final DataCenterController? controller;
  final DataCenterRepository? repository;
  final VoidCallback? onOpenMediaLibrary;
  final VoidCallback? onOpenPublicShares;
  final bool canWrite;

  @override
  State<DataCenterPage> createState() => _DataCenterPageState();
}

class _DataCenterPageState extends State<DataCenterPage> {
  late final DataCenterController controller;
  late final bool ownsController;

  @override
  void initState() {
    super.initState();
    ownsController = widget.controller == null;
    controller =
        widget.controller ??
        DataCenterController(
          loader: widget.repository?.load,
          action: widget.repository?.createTask,
          retryAction: widget.repository?.retryTask,
          downloadAction: widget.repository?.getDownloadLink,
        );
    if (controller.state.status == DataCenterLoadStatus.idle) {
      controller.restore();
    }
  }

  @override
  void dispose() {
    if (ownsController) controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final state = controller.state;
      final snapshot = state.data;
      return Scaffold(
        appBar: AppBar(title: const Text('数据中心')),
        body: BearPageEntrance(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              0,
              12,
              0,
              IosMetrics.bottomSafePadding,
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _DataCenterHeader(),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _DataCenterStatusCard(
                  state: state,
                  onRetry: controller.retry,
                ),
              ),
              if (controller.lastActionMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.info_circle,
                    color: IosColors.systemBlue,
                    text: controller.lastActionMessage!,
                    actionLabel: '知道了',
                    onAction: controller.clearActionMessage,
                  ),
                ),
              if (!widget.canWrite)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看用量与分享入口，数据导入已设为只读。',
                  ),
                ),
              if (!ProductSurface.exposeExportBackup)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: IosBanner(
                    key: Key('data-center-export-backup-hidden'),
                    icon: CupertinoIcons.info_circle,
                    color: IosColors.systemIndigo,
                    text:
                        '导出与备份已暂时收起：服务端尚未实现后台任务处理，避免「提交后永远排队」。',
                  ),
                ),
              const SizedBox(height: 12),
              IosGroupedSection(
                header: const IosSectionHeader('数据操作'),
                children: [
                  IosListTile(
                    leading: IosGlyph(
                      icon: CupertinoIcons.square_arrow_up,
                      color: IosColors.systemTeal,
                    ),
                    title: '批量导入',
                    subtitle: widget.canWrite
                        ? '一次导入仓鼠、笼舍或体重记录'
                        : '只读 · 仅舍主可批量导入',
                    onTap: widget.canWrite
                        ? () => Navigator.of(context).push<void>(
                            iosPageRoute(
                              builder: (_) =>
                                  I2ImportPage(controller: widget.i2Controller),
                            ),
                          )
                        : null,
                  ),
                  if (ProductSurface.exposeExportBackup) ...[
                    IosListTile(
                      leading: IosGlyph(
                        icon: CupertinoIcons.square_arrow_down,
                        color: IosColors.systemBlue,
                      ),
                      title: '导出数据',
                      subtitle: _taskSubtitle(
                        snapshot?.exportTasks,
                        '整理并下载你的记录',
                      ),
                      onTap: () =>
                          _openTaskPage(context, DataCenterTaskKind.export),
                    ),
                    IosListTile(
                      leading: IosGlyph(
                        icon: CupertinoIcons.cloud_upload,
                        color: IosColors.systemIndigo,
                      ),
                      title: '备份数据',
                      subtitle: _taskSubtitle(
                        snapshot?.backupTasks,
                        '安心保存档案与照片清单',
                      ),
                      onTap: () =>
                          _openTaskPage(context, DataCenterTaskKind.backup),
                    ),
                  ],
                ],
              ),
              if (ProductSurface.exposeExportBackup) ...[
                const SizedBox(height: 12),
                const IosSectionHeader('最近备份'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _LatestBackupCard(backup: snapshot?.latestBackup),
                ),
              ],
              const SizedBox(height: 12),
              const IosSectionHeader('空间与分享'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _UsageSummaryCard(
                  summary: snapshot?.usage ?? const DataCenterUsageSummary(),
                  onTap: () => Navigator.of(context).push<void>(
                    iosPageRoute(
                      builder: (_) =>
                          DataCenterUsagePage(controller: controller),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _DataCenterEntryCard(
                  icon: CupertinoIcons.photo_on_rectangle,
                  title: '媒体与分享',
                  subtitle: '媒体库、公开分享预览与撤销入口',
                  onTap: () => Navigator.of(context).push<void>(
                    iosPageRoute(
                      builder: (_) => DataCenterMediaPage(
                        controller: controller,
                        onOpenMediaLibrary: widget.onOpenMediaLibrary,
                        onOpenPublicShares: widget.onOpenPublicShares,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );

  void _openTaskPage(BuildContext context, DataCenterTaskKind kind) {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => DataCenterTaskPage(
          controller: controller,
          kind: kind,
          canWrite: widget.canWrite,
        ),
      ),
    );
  }

  String _taskSubtitle(List<DataCenterTask>? tasks, String fallback) {
    if (tasks == null || tasks.isEmpty) return fallback;
    return '${tasks.length} 条记录 · $fallback';
  }
}

class DataCenterTaskPage extends StatelessWidget {
  const DataCenterTaskPage({
    super.key,
    required this.controller,
    required this.kind,
    this.canWrite = true,
  });

  final DataCenterController controller;
  final DataCenterTaskKind kind;
  final bool canWrite;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final state = controller.state;
      final tasks = state.data?.tasksFor(kind) ?? const <DataCenterTask>[];
      return Scaffold(
        appBar: AppBar(title: Text(kind.label)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _TaskPageIntro(kind: kind),
            if (!canWrite) ...[
              const SizedBox(height: 12),
              const IosBanner(
                icon: CupertinoIcons.lock_shield,
                color: IosColors.systemOrange,
                text: '当前角色可查看历史任务，创建与重试操作已禁用。',
              ),
            ],
            const SizedBox(height: 16),
            if (state.status == DataCenterLoadStatus.loading)
              const _DataCenterLoadingState()
            else if (state.status == DataCenterLoadStatus.error)
              _DataCenterErrorState(
                message: state.message ?? '记录加载失败',
                onRetry: controller.retry,
              )
            else if (tasks.isEmpty)
              _DataCenterEmptyState(
                message: kind == DataCenterTaskKind.export
                    ? '暂无导出记录'
                    : '暂无备份记录',
              )
            else
              ...tasks.map(
                (task) => _TaskCard(
                  task: task,
                  busy: controller.isTaskBusy(task),
                  onRetry:
                      canWrite &&
                          task.retryable &&
                          task.status == DataCenterTaskStatus.failed &&
                          !controller.isTaskBusy(task)
                      ? () async {
                          final ok = await controller.retryTask(task);
                          if (!context.mounted) return;
                          showIosMessage(
                            context,
                            controller.lastActionMessage ??
                                (ok
                                    ? '${kind.label}重试已提交'
                                    : '${kind.label}重试未提交'),
                          );
                        }
                      : null,
                  onDownload: task.canDownload && !controller.isTaskBusy(task)
                      ? () async {
                          final link = await controller.getDownloadLink(task);
                          if (link == null || !context.mounted) return;
                          await _shareDataCenterDownload(link);
                          if (!context.mounted) return;
                          showIosMessage(
                            context,
                            controller.lastActionMessage ?? '下载链接已打开',
                          );
                        }
                      : null,
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  !canWrite ||
                      state.status == DataCenterLoadStatus.loading ||
                      controller.isCreating(kind)
                  ? null
                  : () async {
                      final ok = await controller.createTask(kind);
                      if (!context.mounted) return;
                      showIosMessage(
                        context,
                        controller.lastActionMessage ??
                            (ok ? '${kind.label}已提交' : '${kind.label}暂不可用'),
                      );
                    },
              icon: Icon(
                kind == DataCenterTaskKind.export
                    ? CupertinoIcons.arrow_down_doc
                    : CupertinoIcons.cloud_upload,
              ),
              label: Text(
                controller.isCreating(kind)
                    ? '正在提交'
                    : kind == DataCenterTaskKind.export
                    ? '开始导出'
                    : '创建备份',
              ),
            ),
          ],
        ),
      );
    },
  );
}

class DataCenterUsagePage extends StatelessWidget {
  const DataCenterUsagePage({super.key, required this.controller});

  final DataCenterController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final state = controller.state;
      final summary = state.data?.usage ?? const DataCenterUsageSummary();
      return Scaffold(
        appBar: AppBar(title: const Text('用量摘要')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            const _DataCenterShellIntro(
              icon: CupertinoIcons.chart_bar_alt_fill,
              title: '账号用量',
              detail: '查看仓鼠、窝次和媒体空间的使用情况。',
            ),
            const SizedBox(height: 16),
            if (state.status == DataCenterLoadStatus.loading)
              const _DataCenterLoadingState()
            else if (state.status == DataCenterLoadStatus.error)
              _DataCenterErrorState(
                message: state.message ?? '用量加载失败',
                onRetry: controller.retry,
              )
            else if (summary.isEmpty)
              const _DataCenterEmptyState(message: '暂无用量数据')
            else
              _UsageMetricGrid(summary: summary),
            if (summary.measuredAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '测量时间：${_dateTimeLabel(summary.measuredAt!)}',
                  style: TextStyle(
                    color: ScolvPalette.of(context).secondaryLabel,
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class DataCenterMediaPage extends StatelessWidget {
  const DataCenterMediaPage({
    super.key,
    required this.controller,
    this.onOpenMediaLibrary,
    this.onOpenPublicShares,
  });

  final DataCenterController controller;
  final VoidCallback? onOpenMediaLibrary;
  final VoidCallback? onOpenPublicShares;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('媒体与分享')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const _DataCenterShellIntro(
          icon: CupertinoIcons.photo_on_rectangle,
          title: '媒体与公开分享',
          detail: '从这里进入媒体管理、分享预览和撤销流程。',
        ),
        const SizedBox(height: 16),
        if (onOpenMediaLibrary != null)
          _DataCenterEntryCard(
            icon: CupertinoIcons.photo,
            title: '媒体库',
            subtitle: '进入仓鼠档案管理头像与封面图片',
            onTap: onOpenMediaLibrary,
          ),
        if (onOpenPublicShares != null)
          _DataCenterEntryCard(
            icon: CupertinoIcons.share,
            title: '公开分享',
            subtitle: '编辑、预览、发布或撤销公开主页',
            onTap: onOpenPublicShares,
          ),
        if (onOpenMediaLibrary == null && onOpenPublicShares == null)
          const _DataCenterEmptyState(message: '请从仓鼠档案管理图片，从公开主页管理分享内容'),
      ],
    ),
  );
}

class _DataCenterHeader extends StatelessWidget {
  const _DataCenterHeader();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: ScolvPalette.of(context).accentSoft,
      borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
    ),
    child: Row(
      children: [
        IosGlyph(
          icon: CupertinoIcons.archivebox_fill,
          color: ScolvPalette.of(context).accent,
          size: 44,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '数据与备份',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '妥善保存每一份记录，换设备也更安心',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DataCenterStatusCard extends StatelessWidget {
  const _DataCenterStatusCard({required this.state, required this.onRetry});

  final DataCenterLoadState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (state.status) {
    DataCenterLoadStatus.loading => const _DataCenterLoadingState(),
    DataCenterLoadStatus.error => _DataCenterErrorState(
      message: state.message ?? '数据中心加载失败',
      onRetry: onRetry,
    ),
    DataCenterLoadStatus.empty => _DataCenterEmptyState(
      message: state.message ?? '暂无数据中心数据',
    ),
    DataCenterLoadStatus.data => const SizedBox.shrink(),
    DataCenterLoadStatus.idle => const SizedBox.shrink(),
  };
}

class _DataCenterLoadingState extends StatelessWidget {
  const _DataCenterLoadingState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      children: [
        // Keep CircularProgressIndicator for existing widget tests.
        CircularProgressIndicator(),
        SizedBox(height: 12),
        Text('正在加载数据中心摘要'),
      ],
    ),
  );
}

class _DataCenterEmptyState extends StatelessWidget {
  const _DataCenterEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => IosGroupedSection(
    children: [
      IosListTile(
        leading: IosGlyph(
          icon: CupertinoIcons.tray,
          color: ScolvPalette.of(context).secondaryLabel,
        ),
        title: message,
        showChevron: false,
      ),
    ],
  );
}

class _DataCenterErrorState extends StatelessWidget {
  const _DataCenterErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => IosBanner(
    icon: CupertinoIcons.exclamationmark_circle,
    text: message,
    color: IosColors.systemRed,
    actionLabel: '重试',
    onAction: onRetry,
  );
}

class _DataCenterShellIntro extends StatelessWidget {
  const _DataCenterShellIntro({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => IosGroupedSection(
    children: [
      IosListTile(
        leading: IosGlyph(icon: icon, color: ScolvPalette.of(context).accent),
        title: title,
        subtitle: detail,
        showChevron: false,
      ),
    ],
  );
}

class _DataCenterEntryCard extends StatelessWidget {
  const _DataCenterEntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Material(
      color: ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      clipBehavior: Clip.antiAlias,
      child: IosListTile(
        leading: IosGlyph(icon: icon, color: ScolvPalette.of(context).accent),
        title: title,
        subtitle: subtitle,
        onTap: onTap,
      ),
    ),
  );
}

class _UsageSummaryCard extends StatelessWidget {
  const _UsageSummaryCard({required this.summary, required this.onTap});

  final DataCenterUsageSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metrics = summary.metrics;
    final filled = metrics.where((metric) => metric.hasValue).length;
    return Material(
      color: ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.chart_bar_alt_fill,
                    color: ScolvPalette.of(context).accent,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '用量摘要',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    size: 16,
                    color: ScolvPalette.of(context).tertiaryLabel,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                metrics.isEmpty ? '暂无用量记录' : '已统计 $filled 项',
                style: TextStyle(
                  color: ScolvPalette.of(context).secondaryLabel,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _usageMetricDefinitions.map((metric) {
                  final value = metrics.firstWhere(
                    (item) => item.key == metric.key,
                    orElse: () => metric,
                  );
                  return Chip(
                    label: Text('${metric.label} ${_metricValue(value)}'),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestBackupCard extends StatelessWidget {
  const _LatestBackupCard({required this.backup});

  final DataCenterBackupSummary? backup;

  @override
  Widget build(BuildContext context) {
    final current = backup;
    if (current == null) {
      return IosGroupedSection(
        children: [
          IosListTile(
            leading: IosGlyph(
              icon: CupertinoIcons.cloud_upload,
              color: ScolvPalette.of(context).secondaryLabel,
            ),
            title: '暂无备份记录',
            subtitle: '创建备份后，可在这里查看保存情况',
            showChevron: false,
          ),
        ],
      );
    }
    return Material(
      color: ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.cloud_upload,
                  color: ScolvPalette.of(context).accent,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '最近备份',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                  ),
                ),
                Chip(label: Text(current.status.label)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '大小 ${current.sizeLabel} · ${_backupReadinessLabel(current.restoreReadiness)}',
            ),
            if (current.createdAt != null)
              Text(
                '创建时间：${_dateTimeLabel(current.createdAt!)}',
                style: TextStyle(
                  color: ScolvPalette.of(context).secondaryLabel,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UsageMetricGrid extends StatelessWidget {
  const _UsageMetricGrid({required this.summary});

  final DataCenterUsageSummary summary;

  @override
  Widget build(BuildContext context) => Column(
    children: _usageMetricDefinitions.map((definition) {
      final metric = summary.metrics.firstWhere(
        (value) => value.key == definition.key,
        orElse: () => definition,
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: ScolvPalette.of(context).secondaryGroupedBackground,
          borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
          child: IosListTile(
            leading: IosGlyph(
              icon: _metricIcon(metric.key),
              color: ScolvPalette.of(context).accent,
            ),
            title: metric.label,
            subtitle: metric.hasValue ? _metricValue(metric) : '暂无数据',
            trailing: metric.limit == null
                ? null
                : Text(
                    '上限 ${_formatNumber(metric.limit!)}',
                    style: TextStyle(
                      color: ScolvPalette.of(context).secondaryLabel,
                    ),
                  ),
            showChevron: false,
          ),
        ),
      );
    }).toList(),
  );
}

class _TaskPageIntro extends StatelessWidget {
  const _TaskPageIntro({required this.kind});

  final DataCenterTaskKind kind;

  @override
  Widget build(BuildContext context) => _DataCenterShellIntro(
    icon: kind == DataCenterTaskKind.export
        ? CupertinoIcons.arrow_down_doc
        : CupertinoIcons.cloud_upload,
    title: kind.label,
    detail: kind == DataCenterTaskKind.export
        ? '查看整理进度、失败原因与下载链接。'
        : '查看备份进度、完整性校验与下载链接。',
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    this.onRetry,
    this.onDownload,
    this.busy = false,
  });

  final DataCenterTask task;
  final Future<void> Function()? onRetry;
  final Future<void> Function()? onDownload;
  final bool busy;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: ScolvPalette.of(context).secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.kind.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(
                  label: Text(task.status.label),
                  labelStyle: TextStyle(color: task.status.color(context)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: task.progressPercent / 100),
            const SizedBox(height: 8),
            Text(
              '${task.progressPercent}% · ${_taskStatusDetail(task.status)}',
            ),
            if (task.detail?.trim().isNotEmpty ?? false)
              Text(
                '当前步骤：${task.detail}',
                style: TextStyle(
                  color: ScolvPalette.of(context).secondaryLabel,
                ),
              ),
            if (task.errorMessage?.trim().isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '失败原因：${task.errorMessage}',
                  style: const TextStyle(color: IosColors.systemRed),
                ),
              ),
            if (task.fileName?.trim().isNotEmpty ?? false)
              Text(
                '文件：${task.fileName}${task.sizeLabel == null ? '' : ' · ${task.sizeLabel}'}',
                style: TextStyle(
                  color: ScolvPalette.of(context).secondaryLabel,
                ),
              ),
            if (task.sha256?.trim().isNotEmpty ?? false)
              Text(
                '校验值：${_shortHash(task.sha256!)}',
                style: TextStyle(
                  color: ScolvPalette.of(context).secondaryLabel,
                ),
              ),
            if (task.expiresAt != null)
              Text(
                '过期时间：${_dateTimeLabel(task.expiresAt!)}',
                style: TextStyle(
                  color: ScolvPalette.of(context).secondaryLabel,
                ),
              ),
            if (onRetry != null || onDownload != null || busy)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (busy)
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    if (onRetry != null)
                      TextButton.icon(
                        onPressed: busy ? null : () => onRetry!(),
                        icon: const Icon(
                          CupertinoIcons.arrow_clockwise,
                          size: 16,
                        ),
                        label: const Text('重试'),
                      ),
                    if (onDownload != null)
                      TextButton.icon(
                        onPressed: busy ? null : () => onDownload!(),
                        icon: const Icon(
                          CupertinoIcons.square_arrow_down,
                          size: 16,
                        ),
                        label: const Text('获取下载链接'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

const _usageMetricDefinitions = <DataCenterUsageMetric>[
  DataCenterUsageMetric(
    key: 'active_hamsters',
    label: '活跃仓鼠',
    value: null,
    unit: '只',
  ),
  DataCenterUsageMetric(
    key: 'active_litters',
    label: '活跃窝次',
    value: null,
    unit: '窝',
  ),
  DataCenterUsageMetric(key: 'enclosures', label: '笼舍', value: null, unit: '个'),
  DataCenterUsageMetric(
    key: 'media_bytes',
    label: '媒体空间',
    value: null,
    unit: 'B',
  ),
  DataCenterUsageMetric(
    key: 'video_minutes',
    label: '视频时长',
    value: null,
    unit: '分钟',
  ),
  DataCenterUsageMetric(
    key: 'backup_bytes',
    label: '备份空间',
    value: null,
    unit: 'B',
  ),
];

IconData _metricIcon(String key) => switch (key) {
  'active_hamsters' => CupertinoIcons.paw,
  'active_litters' => CupertinoIcons.person_3,
  'enclosures' => CupertinoIcons.square_grid_2x2,
  'media_bytes' => CupertinoIcons.photo,
  'video_minutes' => CupertinoIcons.videocam,
  'backup_bytes' => CupertinoIcons.cloud_upload,
  _ => CupertinoIcons.chart_bar_alt_fill,
};

String _metricValue(DataCenterUsageMetric metric) =>
    metric.hasValue ? '${_formatNumber(metric.value!)} ${metric.unit}' : '暂无';

String _backupReadinessLabel(String value) => switch (value.toLowerCase()) {
  'ready' || 'restorable' || 'verified' => '校验通过',
  'checking' || 'verifying' || 'pending' => '正在校验',
  'unavailable' || 'failed' => '校验未通过',
  _ => '已生成',
};

String _taskStatusDetail(DataCenterTaskStatus status) => switch (status) {
  DataCenterTaskStatus.queued => '等待处理',
  DataCenterTaskStatus.running => '正在处理',
  DataCenterTaskStatus.succeeded => '下载链接可获取',
  DataCenterTaskStatus.failed => '处理未完成',
  DataCenterTaskStatus.expired => '下载链接已失效',
};

String _shortHash(String value) {
  if (value.length <= 24) return value;
  return '${value.substring(0, 12)}…${value.substring(value.length - 8)}';
}

Future<void> _shareDataCenterDownload(DataCenterDownloadLink link) =>
    Share.share(
      '${link.fileName}\n${link.url}\n'
      '大小：${link.sizeLabel}\n'
      '链接有效至：${_dateTimeLabel(link.expiresAt)}\n'
      'SHA-256：${link.sha256}',
      subject: link.fileName,
    );

String _formatNumber(num value) => value is int
    ? value.toString()
    : value.toStringAsFixed(value % 1 == 0 ? 0 : 1);

String _dateTimeLabel(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
