import 'package:flutter/material.dart';

import '../i2/i2.dart';

enum DataCenterTaskKind { export, backup }

enum DataCenterTaskStatus { queued, running, succeeded, failed, expired }

extension DataCenterTaskKindLabel on DataCenterTaskKind {
  String get label => switch (this) {
    DataCenterTaskKind.export => '导出任务',
    DataCenterTaskKind.backup => '备份任务',
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

  Color get color => switch (this) {
    DataCenterTaskStatus.queued => Colors.blueGrey,
    DataCenterTaskStatus.running => Colors.blue,
    DataCenterTaskStatus.succeeded => Colors.green,
    DataCenterTaskStatus.failed => Colors.redAccent,
    DataCenterTaskStatus.expired => Colors.orange,
  };
}

class DataCenterTask {
  const DataCenterTask({
    required this.id,
    required this.kind,
    required this.status,
    required this.progressPercent,
    this.detail,
    this.retryable = false,
    this.expiresAt,
  });

  final String id;
  final DataCenterTaskKind kind;
  final DataCenterTaskStatus status;
  final int progressPercent;
  final String? detail;
  final bool retryable;
  final DateTime? expiresAt;
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

class DataCenterController extends ChangeNotifier {
  DataCenterController({DataCenterLoader? loader, DataCenterSnapshot? initial})
    : _loader = loader ?? (() async => initial ?? DataCenterSnapshot.empty),
      state = initial == null
          ? const DataCenterLoadState.idle()
          : initial.isEmpty
          ? const DataCenterLoadState.empty(message: '暂无任务、备份和用量数据')
          : DataCenterLoadState.data(initial);

  final DataCenterLoader _loader;

  DataCenterLoadState state;
  String? lastActionMessage;

  Future<void> restore() async {
    state = const DataCenterLoadState.loading();
    lastActionMessage = null;
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

  void requestTask(DataCenterTaskKind kind) {
    lastActionMessage = '${kind.label}创建入口已就绪，数据接口待联调';
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
  });

  final I2Controller i2Controller;
  final DataCenterController? controller;

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
    controller = widget.controller ?? DataCenterController();
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
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            const _DataCenterHeader(),
            const SizedBox(height: 12),
            _DataCenterStatusCard(state: state, onRetry: controller.retry),
            if (controller.lastActionMessage != null)
              _DataCenterActionNotice(
                message: controller.lastActionMessage!,
                onDismiss: controller.clearActionMessage,
              ),
            const SizedBox(height: 20),
            const _SectionTitle(title: '数据操作'),
            const SizedBox(height: 8),
            _DataCenterEntryCard(
              icon: Icons.upload_file_outlined,
              title: 'CSV 导入',
              subtitle: '仓鼠、笼盒、体重 · 逐行预检与报告',
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => I2ImportPage(controller: widget.i2Controller),
                ),
              ),
            ),
            _DataCenterEntryCard(
              icon: Icons.file_download_outlined,
              title: '导出任务',
              subtitle: _taskSubtitle(
                snapshot?.exportTasks,
                'CSV / JSON 导出与短期下载',
              ),
              onTap: () => _openTaskPage(context, DataCenterTaskKind.export),
            ),
            _DataCenterEntryCard(
              icon: Icons.backup_outlined,
              title: '备份任务',
              subtitle: _taskSubtitle(snapshot?.backupTasks, '结构化数据、媒体清单与校验哈希'),
              onTap: () => _openTaskPage(context, DataCenterTaskKind.backup),
            ),
            const SizedBox(height: 20),
            const _SectionTitle(title: '最近备份'),
            const SizedBox(height: 8),
            _LatestBackupCard(backup: snapshot?.latestBackup),
            const SizedBox(height: 20),
            const _SectionTitle(title: '空间与传播'),
            const SizedBox(height: 8),
            _UsageSummaryCard(
              summary: snapshot?.usage ?? const DataCenterUsageSummary(),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => DataCenterUsagePage(controller: controller),
                ),
              ),
            ),
            _DataCenterEntryCard(
              icon: Icons.perm_media_outlined,
              title: '媒体与分享',
              subtitle: '媒体库、公开分享预览与撤销入口',
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => DataCenterMediaPage(controller: controller),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _DataCenterShellFootnote(),
          ],
        ),
      );
    },
  );

  void _openTaskPage(BuildContext context, DataCenterTaskKind kind) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DataCenterTaskPage(controller: controller, kind: kind),
      ),
    );
  }

  String _taskSubtitle(List<DataCenterTask>? tasks, String fallback) {
    if (tasks == null || tasks.isEmpty) return fallback;
    return '${tasks.length} 个任务 · $fallback';
  }
}

class DataCenterTaskPage extends StatelessWidget {
  const DataCenterTaskPage({
    super.key,
    required this.controller,
    required this.kind,
  });

  final DataCenterController controller;
  final DataCenterTaskKind kind;

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
            const SizedBox(height: 16),
            if (state.status == DataCenterLoadStatus.loading)
              const _DataCenterLoadingState()
            else if (state.status == DataCenterLoadStatus.error)
              _DataCenterErrorState(
                message: state.message ?? '任务加载失败',
                onRetry: controller.retry,
              )
            else if (tasks.isEmpty)
              _DataCenterEmptyState(
                message: kind == DataCenterTaskKind.export
                    ? '暂无导出任务'
                    : '暂无备份任务',
              )
            else
              ...tasks.map((task) => _TaskCard(task: task)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                controller.requestTask(kind);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(controller.lastActionMessage!)),
                );
              },
              icon: Icon(
                kind == DataCenterTaskKind.export
                    ? Icons.add_to_drive_outlined
                    : Icons.add_task_outlined,
              ),
              label: Text('创建${kind.label}'),
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
              icon: Icons.data_usage_outlined,
              title: '账号用量',
              detail: '保留六项计量位，后续接入只读用量摘要。',
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
                  style: const TextStyle(color: Color(0xff6c7774)),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class DataCenterMediaPage extends StatelessWidget {
  const DataCenterMediaPage({super.key, required this.controller});

  final DataCenterController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('媒体与分享')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const _DataCenterShellIntro(
          icon: Icons.perm_media_outlined,
          title: '媒体与公开分享',
          detail: '从这里进入媒体管理、分享预览和撤销流程。',
        ),
        const SizedBox(height: 16),
        _DataCenterEntryCard(
          icon: Icons.photo_library_outlined,
          title: '媒体库',
          subtitle: '图片、短视频、封面与编辑派生',
          onTap: () => _showShellMessage(context, '媒体库入口已就绪，数据接口待联调'),
        ),
        _DataCenterEntryCard(
          icon: Icons.share_outlined,
          title: '公开分享',
          subtitle: '选择字段、预览公开卡片、撤销分享',
          onTap: () => _showShellMessage(context, '公开分享入口已就绪，WEB-01 待联调'),
        ),
        const SizedBox(height: 16),
        const _DataCenterEmptyState(message: '暂无媒体或分享记录'),
      ],
    ),
  );
}

class _DataCenterHeader extends StatelessWidget {
  const _DataCenterHeader();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xffdce5e3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      children: [
        Icon(Icons.storage_outlined, size: 36, color: Color(0xff43635f)),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '数据搬家与空间概览',
                style: TextStyle(
                  color: Color(0xff43635f),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '当前为页面壳，数据接口待联调',
                style: TextStyle(color: Color(0xff5f7773)),
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

class _DataCenterActionNotice extends StatelessWidget {
  const _DataCenterActionNotice({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: MaterialBanner(
      leading: const Icon(Icons.info_outline),
      content: Text(message),
      actions: [TextButton(onPressed: onDismiss, child: const Text('知道了'))],
    ),
  );
}

class _DataCenterLoadingState extends StatelessWidget {
  const _DataCenterLoadingState();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('正在加载数据中心摘要'),
        ],
      ),
    ),
  );
}

class _DataCenterEmptyState extends StatelessWidget {
  const _DataCenterEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 40, color: Color(0xff6c7774)),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class _DataCenterErrorState extends StatelessWidget {
  const _DataCenterErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    color: const Color(0xfffff1ef),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 40,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    ),
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
  Widget build(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Icon(icon, size: 32, color: const Color(0xff43635f)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(detail),
      ),
    ),
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
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 8),
    child: ListTile(
      leading: Icon(icon, color: const Color(0xff43635f)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
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
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.data_usage_outlined, color: Color(0xff43635f)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '用量摘要',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                metrics.isEmpty ? '六项计量待接入' : '已读取 $filled/${metrics.length} 项',
                style: const TextStyle(color: Color(0xff6c7774)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _usageMetricDefinitions
                    .map(
                      (metric) => Chip(
                        label: Text(
                          _metricValue(
                            metrics.firstWhere(
                              (value) => value.key == metric.key,
                              orElse: () => metric,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
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
      return const Card(
        child: ListTile(
          leading: Icon(Icons.backup_outlined, color: Color(0xff6c7774)),
          title: Text('暂无备份记录'),
          subtitle: Text('创建备份后显示大小、校验和可恢复状态'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.backup_outlined, color: Color(0xff43635f)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '最近备份',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Chip(label: Text(current.status.label)),
              ],
            ),
            const SizedBox(height: 8),
            Text('大小 ${current.sizeLabel} · ${current.restoreReadiness}'),
            if (current.createdAt != null)
              Text(
                '创建时间：${_dateTimeLabel(current.createdAt!)}',
                style: const TextStyle(color: Color(0xff6c7774)),
              ),
            if (current.sha256 != null)
              Text(
                'SHA-256：${current.sha256}',
                style: const TextStyle(color: Color(0xff6c7774)),
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
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(
            _metricIcon(metric.key),
            color: const Color(0xff43635f),
          ),
          title: Text(metric.label),
          subtitle: Text(metric.hasValue ? _metricValue(metric) : '待接入'),
          trailing: metric.limit == null
              ? null
              : Text('上限 ${_formatNumber(metric.limit!)}'),
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
        ? Icons.file_download_outlined
        : Icons.backup_outlined,
    title: kind.label,
    detail: kind == DataCenterTaskKind.export
        ? '查看进度、下载状态、校验和失败重试位。'
        : '查看最近备份、恢复就绪状态、校验和失败重试位。',
  );
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final DataCenterTask task;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.id,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Chip(
                label: Text(task.status.label),
                labelStyle: TextStyle(color: task.status.color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: task.progressPercent / 100),
          const SizedBox(height: 8),
          Text('${task.progressPercent}% · ${task.detail ?? '等待状态更新'}'),
          if (task.expiresAt != null)
            Text(
              '过期时间：${_dateTimeLabel(task.expiresAt!)}',
              style: const TextStyle(color: Color(0xff6c7774)),
            ),
          if (task.retryable && task.status == DataCenterTaskStatus.failed)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showShellMessage(context, '重试入口已就绪，数据接口待联调'),
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ),
        ],
      ),
    ),
  );
}

class _DataCenterShellFootnote extends StatelessWidget {
  const _DataCenterShellFootnote();

  @override
  Widget build(BuildContext context) => const Text(
    '页面壳已接入现有导航与主题；导出、备份、用量、媒体和分享的真实数据接口待后续联调。',
    textAlign: TextAlign.center,
    style: TextStyle(color: Color(0xff6c7774), fontSize: 12),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 18,
      color: Color(0xff1f2928),
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
  'active_hamsters' => Icons.pets_outlined,
  'active_litters' => Icons.family_restroom_outlined,
  'enclosures' => Icons.grid_view_outlined,
  'media_bytes' => Icons.photo_library_outlined,
  'video_minutes' => Icons.videocam_outlined,
  'backup_bytes' => Icons.backup_outlined,
  _ => Icons.data_usage_outlined,
};

String _metricValue(DataCenterUsageMetric metric) => metric.hasValue
    ? '${_formatNumber(metric.value!)} ${metric.unit}'
    : '— ${metric.unit}';

String _formatNumber(num value) => value is int
    ? value.toString()
    : value.toStringAsFixed(value % 1 == 0 ? 0 : 1);

String _dateTimeLabel(DateTime value) {
  final local = value.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')} '
      '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}

void _showShellMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
