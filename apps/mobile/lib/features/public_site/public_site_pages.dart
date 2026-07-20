import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
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
      showIosMessage(context, message);
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

  String _publicUrl(PublicSite site) {
    return site.publicUrl();
  }

  Future<void> _sharePublicSite(PublicSite site) async {
    final url = _publicUrl(site);
    try {
      await Share.share('${site.title}\n$url', subject: site.title);
    } on Object {
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) showIosMessage(context, '系统分享不可用，公开链接已复制');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final site = widget.controller.siteState.data;
        final publicSite = site;
        final publicUrl = publicSite == null ? null : _publicUrl(publicSite);
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
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
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                '公开主页用于生成一个可访问链接：发布后复制链接，再粘贴到微信、抖音或小红书。当前不会自动代发到社交平台。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (site != null)
                IosGroupedSection(
                  margin: EdgeInsets.zero,
                  children: [
                    IosListTile(
                      leading: Icon(
                        site.published
                            ? CupertinoIcons.globe
                            : CupertinoIcons.lock,
                        color: site.published ? Colors.green : null,
                      ),
                      title: site.statusLabel,
                      subtitle: site.published
                          ? _publicUrl(site)
                          : '发布后可访问 ${_publicUrl(site)}',
                      trailing: IconButton(
                        tooltip: '复制公开链接',
                        onPressed: !site.published || busy
                            ? null
                            : () async {
                                await Clipboard.setData(
                                  ClipboardData(text: publicUrl!),
                                );
                                if (!context.mounted) return;
                                showIosMessage(context, '公开链接已复制');
                              },
                        icon: const Icon(CupertinoIcons.doc_on_doc),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              const IosBanner(
                icon: CupertinoIcons.link,
                color: IosColors.systemTeal,
                text: '保存只是保存草稿；点击“发布”后，公开链接才会对外可访问。',
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('public-site-slug'),
                controller: _slugCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '公开主页地址',
                  hintText: 'my-cattery',
                  border: OutlineInputBorder(),
                  helperText: '链接格式：p.scolv.com/p/自定义地址',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9-]')),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('public-site-title'),
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '主页标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('public-site-tagline'),
                controller: _taglineCtrl,
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: '关于熊舍',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _wechatCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: '微信号',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: '联系电话',
                  border: OutlineInputBorder(),
                ),
              ),
              IosListTile(
                key: const Key('public-site-show-stats'),
                title: '公开显示统计',
                trailing: CupertinoSwitch(
                  value: _showStats,
                  onChanged: (v) => setState(() => _showStats = v),
                ),
                showChevron: false,
              ),
              IosListTile(
                key: const Key('public-site-show-contact'),
                title: '公开显示联系方式',
                trailing: CupertinoSwitch(
                  value: _showContact,
                  onChanged: (v) => setState(() => _showContact = v),
                ),
                showChevron: false,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('public-site-save'),
                onPressed: busy
                    ? null
                    : () => _snack(() => widget.controller.save(_draft())),
                icon: const Icon(CupertinoIcons.checkmark_circle_fill),
                label: const Text('保存'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('public-site-copy-link'),
                onPressed:
                    publicUrl == null || publicSite?.published != true || busy
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: publicUrl));
                        if (!context.mounted) return;
                        showIosMessage(context, '公开链接已复制');
                      },
                icon: const Icon(CupertinoIcons.doc_on_doc),
                label: const Text('复制公开链接'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('public-site-share'),
                onPressed: publicSite == null || !publicSite.published || busy
                    ? null
                    : () => _sharePublicSite(publicSite),
                icon: const Icon(CupertinoIcons.share),
                label: const Text('打开系统分享'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('public-site-publish'),
                      onPressed: busy || publicSite?.published == true
                          ? null
                          : () => _snack(() => widget.controller.publish()),
                      icon: const Icon(CupertinoIcons.arrow_up_circle_fill),
                      label: const Text('发布'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('public-site-unpublish'),
                      onPressed: busy || publicSite?.published != true
                          ? null
                          : () => _snack(() => widget.controller.unpublish()),
                      icon: const Icon(CupertinoIcons.eye_slash),
                      label: const Text('取消发布'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('public-site-preview'),
                onPressed: publicSite?.published != true || busy
                    ? null
                    : () async {
                        final slug = _slugCtrl.text.trim().toLowerCase();
                        if (slug.isEmpty) return;
                        await widget.controller.loadPublicPreview(slug);
                        if (!context.mounted) return;
                        await Navigator.of(context).push<void>(
                          iosPageRoute(
                            builder: (_) => PublicSitePreviewPage(
                              controller: widget.controller,
                            ),
                          ),
                        );
                      },
                icon: const Icon(CupertinoIcons.eye),
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
              final p = ScolvPalette.of(context);
              final theme = _parseColor(view.themeColor);
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme,
                      borderRadius: BorderRadius.circular(
                        IosMetrics.continuousRadius,
                      ),
                    ),
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
                    Container(
                      decoration: BoxDecoration(
                        color: p.secondaryGroupedBackground,
                        borderRadius: BorderRadius.circular(
                          IosMetrics.continuousRadius,
                        ),
                      ),
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
                    IosGroupedSection(
                      margin: EdgeInsets.zero,
                      children: [
                        IosListTile(
                          leading: const Icon(CupertinoIcons.phone),
                          title: [
                            if (view.contactWechat != null)
                              '微信 ${view.contactWechat}',
                            if (view.contactPhone != null)
                              '电话 ${view.contactPhone}',
                          ].join(' · '),
                        ),
                      ],
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
    if (cleaned.length != 6) return const Color(0xffD98B55);
    return Color(int.parse('ff$cleaned', radix: 16));
  }

  static String _statLabel(String key) => switch (key) {
    'active_hamsters' => '在养',
    'active_litters' => '窝次',
    'enclosures' => '笼盒',
    _ => key,
  };
}
