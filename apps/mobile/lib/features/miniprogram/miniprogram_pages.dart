import 'package:flutter/material.dart';

import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'miniprogram_controller.dart';
import 'miniprogram_models.dart';

/// Miniprogram light publish hub (T-P2-02 sandbox audit chain).
class MiniprogramHubPage extends StatefulWidget {
  const MiniprogramHubPage({super.key, required this.controller});

  final MiniprogramController controller;

  @override
  State<MiniprogramHubPage> createState() => _MiniprogramHubPageState();
}

class _MiniprogramHubPageState extends State<MiniprogramHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _nameCtrl = TextEditingController();
  final _appIdCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    widget.controller.refreshAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameCtrl.dispose();
    _appIdCtrl.dispose();
    _slugCtrl.dispose();
    super.dispose();
  }

  void _seed(MiniprogramConfig cfg) {
    if (_seeded) return;
    _nameCtrl.text = cfg.displayName;
    _appIdCtrl.text = cfg.appId ?? '';
    _slugCtrl.text = cfg.boundPublicSlug ?? '';
    _seeded = true;
  }

  Future<void> _snack(Future<bool> Function() action) async {
    final ok = await action();
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (ok) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final cfg = widget.controller.configState.data;
        if (cfg != null) _seed(cfg);
        return Scaffold(
          appBar: AppBar(
            title: const Text('小程序轻发布'),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(key: Key('mp-tab-config'), text: '配置'),
                Tab(key: Key('mp-tab-releases'), text: '版本'),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('mp-refresh'),
                onPressed: () {
                  _seeded = false;
                  widget.controller.refreshAll();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('mp-fab-create'),
            onPressed: _createRelease,
            icon: const Icon(Icons.add),
            label: const Text('新建版本'),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _ConfigTab(
                nameCtrl: _nameCtrl,
                appIdCtrl: _appIdCtrl,
                slugCtrl: _slugCtrl,
                pipelineNote: cfg?.pipelineNote,
                onSave: () => _snack(
                  () => widget.controller.saveConfig(
                    MiniprogramConfigDraft(
                      displayName: _nameCtrl.text,
                      appId: _appIdCtrl.text.trim().isEmpty
                          ? null
                          : _appIdCtrl.text.trim(),
                      boundPublicSlug: _slugCtrl.text.trim().isEmpty
                          ? null
                          : _slugCtrl.text.trim().toLowerCase(),
                    ),
                  ),
                ),
              ),
              _ReleasesTab(
                state: widget.controller.releasesState,
                onRetry: widget.controller.refreshReleases,
                onSubmit: (r) => _snack(() => widget.controller.submit(r)),
                onApprove: (r) => _snack(() => widget.controller.approve(r)),
                onReject: (r) => _snack(() => widget.controller.reject(r)),
                onPublish: (r) => _snack(() => widget.controller.publish(r)),
                onRollback: (r) => _snack(() => widget.controller.rollback(r)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createRelease() async {
    final labelCtrl = TextEditingController(
      text: 'v${DateTime.now().millisecondsSinceEpoch % 10000}',
    );
    final titleCtrl = TextEditingController(text: '熊舍展示版');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建版本草稿'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('mp-release-label'),
              controller: labelCtrl,
              decoration: const InputDecoration(
                labelText: '版本号',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('mp-release-title'),
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('mp-release-submit'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _snack(
      () => widget.controller.createRelease(
        MiniprogramReleaseDraft(
          versionLabel: labelCtrl.text,
          title: titleCtrl.text,
          publicSlug: _slugCtrl.text.trim().isEmpty
              ? null
              : _slugCtrl.text.trim().toLowerCase(),
        ),
      ),
    );
  }
}

class _ConfigTab extends StatelessWidget {
  const _ConfigTab({
    required this.nameCtrl,
    required this.appIdCtrl,
    required this.slugCtrl,
    required this.onSave,
    this.pipelineNote,
  });

  final TextEditingController nameCtrl;
  final TextEditingController appIdCtrl;
  final TextEditingController slugCtrl;
  final VoidCallback onSave;
  final String? pipelineNote;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (pipelineNote != null)
          Text(
            pipelineNote!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('mp-config-name'),
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: '小程序展示名',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('mp-config-appid'),
          controller: appIdCtrl,
          decoration: const InputDecoration(
            labelText: 'AppID（可选，沙箱可空）',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('mp-config-slug'),
          controller: slugCtrl,
          decoration: const InputDecoration(
            labelText: '绑定公开主页 slug',
            hintText: 'my-cattery',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('mp-config-save'),
          onPressed: onSave,
          icon: const Icon(Icons.save_outlined),
          label: const Text('保存配置'),
        ),
      ],
    );
  }
}

class _ReleasesTab extends StatelessWidget {
  const _ReleasesTab({
    required this.state,
    required this.onRetry,
    required this.onSubmit,
    required this.onApprove,
    required this.onReject,
    required this.onPublish,
    required this.onRollback,
  });

  final I2AsyncState<List<MiniprogramRelease>> state;
  final VoidCallback onRetry;
  final Future<void> Function(MiniprogramRelease item) onSubmit;
  final Future<void> Function(MiniprogramRelease item) onApprove;
  final Future<void> Function(MiniprogramRelease item) onReject;
  final Future<void> Function(MiniprogramRelease item) onPublish;
  final Future<void> Function(MiniprogramRelease item) onRollback;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<MiniprogramRelease>>(
      state: state,
      onRetry: onRetry,
      builder: (items) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      key: Key('mp-release-${item.id}'),
                      title: Text('${item.versionLabel} · ${item.title}'),
                      subtitle: Text(
                        [
                          item.statusLabel,
                          if (item.publicSlug != null) item.publicSlug!,
                          if (item.auditNote != null) item.auditNote!,
                        ].join(' · '),
                      ),
                      leading: Icon(_iconFor(item.status)),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (item.canSubmit)
                          TextButton(
                            key: Key('mp-submit-${item.id}'),
                            onPressed: () => onSubmit(item),
                            child: const Text('提交审核'),
                          ),
                        if (item.canAudit) ...[
                          TextButton(
                            key: Key('mp-approve-${item.id}'),
                            onPressed: () => onApprove(item),
                            child: const Text('沙箱通过'),
                          ),
                          TextButton(
                            key: Key('mp-reject-${item.id}'),
                            onPressed: () => onReject(item),
                            child: const Text('沙箱驳回'),
                          ),
                        ],
                        if (item.canPublish)
                          TextButton(
                            key: Key('mp-publish-${item.id}'),
                            onPressed: () => onPublish(item),
                            child: const Text('发布'),
                          ),
                        if (item.canRollback)
                          TextButton(
                            key: Key('mp-rollback-${item.id}'),
                            onPressed: () => onRollback(item),
                            child: const Text('回滚'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _iconFor(String status) => switch (status) {
    'published' => Icons.cloud_done,
    'approved' => Icons.verified_outlined,
    'rejected' => Icons.cancel_outlined,
    'submitted' || 'auditing' => Icons.hourglass_top,
    'rolled_back' => Icons.history,
    _ => Icons.description_outlined,
  };
}
