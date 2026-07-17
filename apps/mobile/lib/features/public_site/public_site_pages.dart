import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../i2/i2_widgets.dart';
import 'public_site_controller.dart';
import 'public_site_models.dart';

/// Lightweight public cattery homepage editor (T-P2-01).
class PublicSiteEditorPage extends StatefulWidget {
  const PublicSiteEditorPage({super.key, required this.controller});

  final PublicSiteController controller;

  @override
  State<PublicSiteEditorPage> createState() => _PublicSiteEditorPageState();
}

class _PublicSiteEditorPageState extends State<PublicSiteEditorPage> {
  final _slugCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  final _wechatCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _showStats = true;
  bool _showContact = true;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    widget.controller.refresh();
  }

  @override
  void dispose() {
    _slugCtrl.dispose();
    _titleCtrl.dispose();
    _taglineCtrl.dispose();
    _aboutCtrl.dispose();
    _wechatCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _seedFrom(PublicSite site) {
    if (_seeded) return;
    _slugCtrl.text = site.slug;
    _titleCtrl.text = site.title;
    _taglineCtrl.text = site.tagline ?? '';
    _aboutCtrl.text = site.about ?? '';
    _wechatCtrl.text = site.contactWechat ?? '';
    _phoneCtrl.text = site.contactPhone ?? '';
    _showStats = site.showStats;
    _showContact = site.showContact;
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

  PublicSiteDraft _draft() => PublicSiteDraft(
    slug: _slugCtrl.text.trim().toLowerCase(),
    title: _titleCtrl.text.trim(),
    tagline: _taglineCtrl.text.trim().isEmpty ? null : _taglineCtrl.text.trim(),
    about: _aboutCtrl.text.trim().isEmpty ? null : _aboutCtrl.text.trim(),
    contactWechat: _wechatCtrl.text.trim().isEmpty
        ? null
        : _wechatCtrl.text.trim(),
    contactPhone: _phoneCtrl.text.trim().isEmpty
        ? null
        : _phoneCtrl.text.trim(),
    showStats: _showStats,
    showContact: _showContact,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final site = widget.controller.siteState.data;
        if (site != null) _seedFrom(site);
        return Scaffold(
          appBar: AppBar(
            title: const Text('公开主页'),
            actions: [
              IconButton(
                key: const Key('public-site-refresh'),
                onPressed: () {
                  _seeded = false;
                  widget.controller.refresh();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                '轻量主页：标题、简介、联系方式与公开统计。不做可视化装修编辑器。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (site != null)
                Card(
                  child: ListTile(
                    leading: Icon(
                      site.published
                          ? Icons.public
                          : Icons.public_off_outlined,
                      color: site.published ? Colors.green : null,
                    ),
                    title: Text(site.statusLabel),
                    subtitle: Text(
                      site.publicUrlPath ?? '/v1/public/sites/${site.slug}',
                    ),
                    trailing: IconButton(
                      tooltip: '复制路径',
                      onPressed: () async {
                        final path =
                            site.publicUrlPath ??
                            '/v1/public/sites/${site.slug}';
                        await Clipboard.setData(ClipboardData(text: path));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('公开路径已复制')),
                        );
                      },
                      icon: const Icon(Icons.copy_all_outlined),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('public-site-slug'),
                controller: _slugCtrl,
                decoration: const InputDecoration(
                  labelText: '访问路径 slug',
                  hintText: 'my-cattery',
                  border: OutlineInputBorder(),
                  helperText: '小写字母、数字、连字符',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9-]')),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('public-site-title'),
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: '主页标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('public-site-tagline'),
                controller: _taglineCtrl,
                decoration: const InputDecoration(
                  labelText: '一句话介绍',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('public-site-about'),
                controller: _aboutCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '关于熊舍',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _wechatCtrl,
                decoration: const InputDecoration(
                  labelText: '微信号',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: '联系电话',
                  border: OutlineInputBorder(),
                ),
              ),
              SwitchListTile(
                key: const Key('public-site-show-stats'),
                title: const Text('公开显示统计'),
                value: _showStats,
                onChanged: (v) => setState(() => _showStats = v),
              ),
              SwitchListTile(
                key: const Key('public-site-show-contact'),
                title: const Text('公开显示联系方式'),
                value: _showContact,
                onChanged: (v) => setState(() => _showContact = v),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('public-site-save'),
                onPressed: () => _snack(() => widget.controller.save(_draft())),
                icon: const Icon(Icons.save_outlined),
                label: const Text('保存'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('public-site-publish'),
                      onPressed: () =>
                          _snack(() => widget.controller.publish()),
                      icon: const Icon(Icons.publish_outlined),
                      label: const Text('发布'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('public-site-unpublish'),
                      onPressed: () =>
                          _snack(() => widget.controller.unpublish()),
                      icon: const Icon(Icons.visibility_off_outlined),
                      label: const Text('取消发布'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('public-site-preview'),
                onPressed: () async {
                  final slug = _slugCtrl.text.trim().toLowerCase();
                  if (slug.isEmpty) return;
                  // Ensure saved state for memory/API consistency when possible.
                  await widget.controller.loadPublicPreview(slug);
                  if (!context.mounted) return;
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => PublicSitePreviewPage(
                        controller: widget.controller,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.preview_outlined),
                label: const Text('预览公开效果'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PublicSitePreviewPage extends StatelessWidget {
  const PublicSitePreviewPage({super.key, required this.controller});

  final PublicSiteController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('公开主页预览')),
          body: I2AsyncStateView<PublicSiteView>(
            state: controller.previewState,
            onRetry: () {
              final slug = controller.siteState.data?.slug;
              if (slug != null) controller.loadPublicPreview(slug);
            },
            builder: (view) {
              final theme = _parseColor(view.themeColor);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Card(
                    color: theme,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            view.title,
                            key: const Key('public-preview-title'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                          if (view.tagline != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              view.tagline!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (view.about != null && view.about!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(view.about!),
                      ),
                    ),
                  ],
                  if (view.stats.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in view.stats.entries)
                          Chip(
                            label: Text(
                              '${_statLabel(entry.key)} ${entry.value}',
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (view.contactWechat != null ||
                      view.contactPhone != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.contact_phone_outlined),
                        title: Text(
                          [
                            if (view.contactWechat != null)
                              '微信 ${view.contactWechat}',
                            if (view.contactPhone != null)
                              '电话 ${view.contactPhone}',
                          ].join(' · '),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }

  static Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return const Color(0xffc77852);
    return Color(int.parse('ff$cleaned', radix: 16));
  }

  static String _statLabel(String key) => switch (key) {
    'active_hamsters' => '在养',
    'active_litters' => '窝次',
    'enclosures' => '笼盒',
    _ => key,
  };
}
