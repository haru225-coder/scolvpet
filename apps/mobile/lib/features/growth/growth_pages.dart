import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'growth_controller.dart';
import 'growth_models.dart';

/// 获客一级工作台。
class GrowthHubPage extends StatefulWidget {
  const GrowthHubPage({
    super.key,
    required this.controller,
    this.hamsters = const [],
    this.onOpenCrm,
    this.canWrite = true,
  });

  final GrowthController controller;
  final List<I2Hamster> hamsters;
  final VoidCallback? onOpenCrm;
  final bool canWrite;

  @override
  State<GrowthHubPage> createState() => _GrowthHubPageState();
}

class _GrowthHubPageState extends State<GrowthHubPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.refreshAll();
  }

  Future<bool> _snack(Future<bool> Function() action) async {
    final ok = await action();
    if (!mounted) return ok;
    final message = widget.controller.lastMessage;
    if (message != null) showIosMessage(context, message);
    if (ok) setState(() {});
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        final palette = ScolvPalette.of(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('获客'),
            actions: [
              IconButton(
                key: const Key('growth-refresh'),
                onPressed: c.refreshAll,
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: c.refreshAll,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                IosMetrics.pagePadding,
                12,
                IosMetrics.pagePadding,
                32,
              ),
              children: [
                Row(
                  children: [
                    _metric(
                      context,
                      palette,
                      'growth-metric-ready',
                      '可拍摄',
                      '${c.readyFilmingCount}',
                    ),
                    const SizedBox(width: 8),
                    _metric(
                      context,
                      palette,
                      'growth-metric-draft',
                      '草稿活动',
                      '${c.draftCampaignCount}',
                    ),
                    const SizedBox(width: 8),
                    _metric(
                      context,
                      palette,
                      'growth-metric-leads',
                      '新线索',
                      '${c.leadCount}',
                    ),
                  ],
                ),
                if (!widget.canWrite) ...[
                  const SizedBox(height: 12),
                  const IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看活动与客户线索，公开资料维护和内容生成已设为只读。',
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('growth-open-generate-video'),
                        onPressed: widget.canWrite
                            ? () => _openGenerate(type: 'video')
                            : null,
                        icon: const Icon(CupertinoIcons.videocam, size: 18),
                        label: const Text('生成短视频脚本'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        key: const Key('growth-open-generate-live'),
                        onPressed: widget.canWrite
                            ? () => _openGenerate(type: 'live')
                            : null,
                        icon: const Icon(
                          CupertinoIcons.antenna_radiowaves_left_right,
                          size: 18,
                        ),
                        label: const Text('准备直播'),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  key: const Key('growth-open-profiles'),
                  onPressed: _openProfiles,
                  icon: const Icon(CupertinoIcons.person_crop_circle, size: 18),
                  label: const Text('管理公开资料'),
                ),
                const IosSectionHeader('今日内容机会'),
                if (c.profilesState.status == I2AsyncStatus.loading)
                  const SizedBox(
                    key: Key('growth-opportunities-loading'),
                    height: 120,
                    child: IosLoading(),
                  )
                else if (c.profilesState.status == I2AsyncStatus.error)
                  _GrowthCompactState(
                    key: const Key('growth-opportunities-error'),
                    icon: CupertinoIcons.cloud,
                    message: c.profilesState.message ?? '内容机会加载失败',
                    actionLabel: '重试',
                    onRetry: c.refreshProfiles,
                    tone: IosColors.systemRed,
                  )
                else if (c.opportunities.isEmpty)
                  const _GrowthCompactState(
                    key: Key('growth-opportunities-empty'),
                    icon: CupertinoIcons.videocam,
                    message: '先准备仓鼠公开资料，就会出现可拍摄机会。',
                  )
                else
                  for (final item in c.opportunities)
                    Card(
                      key: Key('growth-opportunity-${item.hamsterId}'),
                      child: ListTile(
                        leading: _GrowthCover(
                          media: c.profileById(item.hamsterId)?.coverMedia,
                          size: 54,
                        ),
                        title: Text(item.title),
                        subtitle: Text(item.reason),
                        trailing: const Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                        ),
                        onTap: widget.canWrite
                            ? () => _openGenerate(
                                type: 'video',
                                hamsterId: item.hamsterId,
                              )
                            : null,
                      ),
                    ),
                const SizedBox(height: 16),
                const IosSectionHeader('最近活动'),
                if (c.campaignsState.status == I2AsyncStatus.loading)
                  const SizedBox(
                    key: Key('growth-campaigns-loading'),
                    height: 120,
                    child: IosLoading(),
                  )
                else if (c.campaignsState.status == I2AsyncStatus.error)
                  _GrowthCompactState(
                    key: const Key('growth-campaigns-error'),
                    icon: CupertinoIcons.cloud,
                    message: c.campaignsState.message ?? '最近活动加载失败',
                    actionLabel: '重试',
                    onRetry: c.refreshCampaigns,
                    tone: IosColors.systemRed,
                  )
                else if (c.campaignsState.status == I2AsyncStatus.empty ||
                    (c.campaignsState.data?.isEmpty ?? true))
                  const _GrowthCompactState(
                    key: Key('growth-campaigns-empty'),
                    icon: CupertinoIcons.sparkles,
                    message: '还没有活动，生成一条短视频脚本开始获客。',
                  )
                else
                  for (final item in (c.campaignsState.data ?? const []).take(
                    8,
                  ))
                    Card(
                      key: Key('growth-campaign-${item.id}'),
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(
                          '${item.typeLabel} · ${item.platformLabel} · ${item.statusLabel}',
                        ),
                        trailing: const Icon(
                          CupertinoIcons.chevron_right,
                          size: 16,
                        ),
                        onTap: () => _openCampaign(item),
                      ),
                    ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: IosSectionHeader('新客户线索')),
                    if (widget.onOpenCrm != null)
                      TextButton(
                        key: const Key('growth-open-crm'),
                        onPressed: widget.onOpenCrm,
                        child: const Text('进入 CRM'),
                      ),
                  ],
                ),
                if (c.leadsState.status == I2AsyncStatus.loading)
                  const SizedBox(
                    key: Key('growth-leads-loading'),
                    height: 120,
                    child: IosLoading(),
                  )
                else if (c.leadsState.status == I2AsyncStatus.error)
                  _GrowthCompactState(
                    key: const Key('growth-leads-error'),
                    icon: CupertinoIcons.cloud,
                    message: c.leadsState.message ?? '客户线索加载失败',
                    actionLabel: '重试',
                    onRetry: c.refreshLeads,
                    tone: IosColors.systemRed,
                  )
                else if (c.leadsState.status == I2AsyncStatus.empty ||
                    (c.leadsState.data?.isEmpty ?? true))
                  const _GrowthCompactState(
                    key: Key('growth-leads-empty'),
                    icon: CupertinoIcons.person_2,
                    message: '访客在公开页留下联系方式后，这里会显示来源活动和兴趣仓鼠。',
                  )
                else
                  for (final lead in c.leadsState.data!)
                    Card(
                      key: Key('growth-lead-${lead.id}'),
                      child: ListTile(
                        title: Text(lead.name),
                        subtitle: Text(
                          [
                            lead.contactLabel,
                            '来源：${lead.campaignTitle ?? lead.sourceChannel}',
                            if (lead.interestHamsterName != null)
                              '兴趣：${lead.interestHamsterName}',
                            if (lead.intentSummary != null) lead.intentSummary!,
                          ].join('\n'),
                        ),
                        isThreeLine: true,
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metric(
    BuildContext context,
    ScolvPalette palette,
    String key,
    String label,
    String value,
  ) {
    return Expanded(
      child: Container(
        key: Key(key),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.secondaryGroupedBackground,
          borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
          border: Border.all(
            color: palette.opaqueSeparator,
            width: IosMetrics.hairline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProfiles() async {
    await Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => GrowthProfilesPage(
          controller: widget.controller,
          hamsters: widget.hamsters,
          canWrite: widget.canWrite,
        ),
      ),
    );
    await widget.controller.refreshAll();
  }

  Future<void> _openGenerate({required String type, String? hamsterId}) async {
    final campaign = await Navigator.of(context).push<GrowthCampaign>(
      iosPageRoute(
        builder: (_) => GrowthGeneratePage(
          controller: widget.controller,
          hamsters: widget.hamsters,
          initialType: type,
          initialHamsterId: hamsterId,
        ),
      ),
    );
    if (campaign != null && mounted) await _openCampaign(campaign);
    await widget.controller.refreshAll();
  }

  Future<void> _openCampaign(GrowthCampaign campaign) async {
    await Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => GrowthCampaignResultPage(
          campaign: campaign,
          onPublish: widget.canWrite
              ? () async {
                  final ok = await _snack(
                    () => widget.controller.publish(campaign.id),
                  );
                  return ok
                      ? widget.controller.campaignById(campaign.id)
                      : null;
                }
              : null,
          onArchive: widget.canWrite
              ? () async {
                  final ok = await _snack(
                    () => widget.controller.archive(campaign.id),
                  );
                  return ok
                      ? widget.controller.campaignById(campaign.id)
                      : null;
                }
              : null,
        ),
      ),
    );
    await widget.controller.refreshCampaigns();
  }
}

class GrowthProfilesPage extends StatelessWidget {
  const GrowthProfilesPage({
    super.key,
    required this.controller,
    required this.hamsters,
    this.canWrite = true,
  });

  final GrowthController controller;
  final List<I2Hamster> hamsters;
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.profilesState.status == I2AsyncStatus.loading) {
          return Scaffold(
            appBar: AppBar(title: const Text('公开资料')),
            body: const IosLoading(),
          );
        }
        if (controller.profilesState.status == I2AsyncStatus.error) {
          return Scaffold(
            appBar: AppBar(title: const Text('公开资料')),
            body: I2StateMessage(
              icon: CupertinoIcons.cloud,
              message: controller.profilesState.message ?? '公开资料加载失败',
              actionLabel: '重试',
              onRetry: controller.refreshProfiles,
              tone: IosColors.systemRed,
            ),
          );
        }
        final profiles = {
          for (final p
              in controller.profilesState.data ?? const <GrowthPublicHamster>[])
            p.hamsterId: p,
        };
        // Prefer live hamsters; fall back to profile ids only.
        final rows = hamsters.isNotEmpty
            ? [
                for (final h in hamsters)
                  (h.id, h.name ?? h.internalCode, profiles[h.id]),
              ]
            : [for (final p in profiles.values) (p.hamsterId, p.publicName, p)];
        return Scaffold(
          appBar: AppBar(title: const Text('公开资料')),
          body: ListView(
            padding: const EdgeInsets.all(IosMetrics.pagePadding),
            children: [
              const Text('仅公开资料会提供给访客 AI。内部编码、笼盒和备注不会出现在获客页。'),
              if (!canWrite) ...[
                const SizedBox(height: 12),
                const IosBanner(
                  icon: CupertinoIcons.lock_shield,
                  color: IosColors.systemOrange,
                  text: '当前角色可查看公开状态，资料编辑已禁用。',
                ),
              ],
              const SizedBox(height: 12),
              if (rows.isEmpty)
                const I2StateMessage(
                  icon: CupertinoIcons.person_crop_circle_badge_plus,
                  message: '还没有可维护的仓鼠资料。',
                ),
              for (final row in rows)
                Card(
                  key: Key('growth-profile-card-${row.$1}'),
                  child: ListTile(
                    leading: _GrowthCover(media: row.$3?.coverMedia, size: 54),
                    title: Text(row.$3?.publicName ?? row.$2),
                    subtitle: Text(
                      row.$3 == null
                          ? '未设置公开资料'
                          : '${row.$3!.filmingLabel} · '
                                '${row.$3!.published ? '已公开' : '未公开'} · '
                                '${row.$3!.consultable ? '可咨询' : '不可咨询'}',
                    ),
                    trailing: Icon(
                      canWrite ? CupertinoIcons.pencil : CupertinoIcons.lock,
                      size: 18,
                    ),
                    onTap: canWrite
                        ? () async {
                            await Navigator.of(context).push<void>(
                              iosPageRoute(
                                builder: (_) => GrowthProfileEditorPage(
                                  controller: controller,
                                  hamsterId: row.$1,
                                  displayName: row.$2,
                                  existing: row.$3,
                                ),
                              ),
                            );
                            await controller.refreshProfiles();
                          }
                        : null,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class GrowthProfileEditorPage extends StatefulWidget {
  const GrowthProfileEditorPage({
    super.key,
    required this.controller,
    required this.hamsterId,
    required this.displayName,
    this.existing,
  });

  final GrowthController controller;
  final String hamsterId;
  final String displayName;
  final GrowthPublicHamster? existing;

  @override
  State<GrowthProfileEditorPage> createState() =>
      _GrowthProfileEditorPageState();
}

class _GrowthProfileEditorPageState extends State<GrowthProfileEditorPage> {
  late final TextEditingController _name;
  late final TextEditingController _summary;
  late final TextEditingController _traits;
  late final TextEditingController _cta;
  late final TextEditingController _price;
  late String _filming;
  late bool _published;
  late bool _consultable;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(
      text: e?.publicName.isNotEmpty == true
          ? e!.publicName
          : widget.displayName,
    );
    _summary = TextEditingController(text: e?.summary ?? '');
    _traits = TextEditingController(text: e?.traits.join('、') ?? '');
    _cta = TextEditingController(text: e?.ctaText ?? '进入主页咨询');
    _price = TextEditingController(text: e?.priceLabel ?? '');
    _filming = e?.filmingStatus ?? 'rest';
    _published = e?.published ?? false;
    _consultable = e?.consultable ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _summary.dispose();
    _traits.dispose();
    _cta.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_consultable && !_published) {
      showIosMessage(context, '接受咨询前必须先公开资料');
      return;
    }
    final ok = await widget.controller.upsertProfile(
      widget.hamsterId,
      GrowthPublicHamsterDraft(
        publicName: _name.text.trim(),
        summary: _summary.text.trim().isEmpty ? null : _summary.text.trim(),
        traits: _traits.text
            .split(RegExp(r'[、,，]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        filmingStatus: _filming,
        published: _published,
        consultable: _consultable,
        ctaText: _cta.text.trim().isEmpty ? null : _cta.text.trim(),
        priceLabel: _price.text.trim().isEmpty ? null : _price.text.trim(),
      ),
    );
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (message != null) showIosMessage(context, message);
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('公开 · ${widget.displayName}'),
        actions: [
          TextButton(
            key: const Key('growth-profile-save'),
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(IosMetrics.pagePadding),
        children: [
          TextField(
            key: const Key('growth-profile-name'),
            controller: _name,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: '公开名称'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('growth-profile-summary'),
            controller: _summary,
            maxLines: 3,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(labelText: '简介'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('growth-profile-traits'),
            controller: _traits,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '特点标签',
              hintText: '用顿号分隔，例如 亲人、活动规律',
            ),
          ),
          const SizedBox(height: 12),
          IosPickerField<String>(
            key: const Key('growth-profile-filming'),
            items: const [
              IosPickerItem(value: 'ready', label: '可拍摄'),
              IosPickerItem(value: 'rest', label: '休息中'),
              IosPickerItem(value: 'restricted', label: '不宜出镜'),
            ],
            label: '拍摄状态',
            selected: _filming,
            onSelected: (v) {
              if (v != null) setState(() => _filming = v);
            },
          ),
          SwitchListTile(
            key: const Key('growth-profile-published'),
            title: const Text('公开资料'),
            subtitle: const Text('仅公开资料会提供给访客 AI'),
            value: _published,
            onChanged: (v) => setState(() {
              _published = v;
              if (!v) _consultable = false;
            }),
          ),
          SwitchListTile(
            key: const Key('growth-profile-consultable'),
            title: const Text('接受咨询'),
            value: _consultable,
            onChanged: _published
                ? (v) => setState(() => _consultable = v)
                : null,
          ),
          TextField(
            key: const Key('growth-profile-cta'),
            controller: _cta,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'CTA'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('growth-profile-price'),
            controller: _price,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(labelText: '价格文案（可选）'),
          ),
        ],
      ),
    );
  }
}

class GrowthGeneratePage extends StatefulWidget {
  const GrowthGeneratePage({
    super.key,
    required this.controller,
    required this.hamsters,
    this.initialType = 'video',
    this.initialHamsterId,
  });

  final GrowthController controller;
  final List<I2Hamster> hamsters;
  final String initialType;
  final String? initialHamsterId;

  @override
  State<GrowthGeneratePage> createState() => _GrowthGeneratePageState();
}

class _GrowthGeneratePageState extends State<GrowthGeneratePage> {
  late String _type;
  late String _platform;
  late final TextEditingController _goal;
  late final TextEditingController _tone;
  late final TextEditingController _cta;
  late final TextEditingController _duration;
  String? _hamsterId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _platform = 'wechat_channels';
    _goal = TextEditingController(text: '成长记录');
    _tone = TextEditingController(text: '温柔自然');
    _cta = TextEditingController(text: '想了解这只仓鼠，可以进入主页咨询。');
    _duration = TextEditingController(text: _type == 'live' ? '1800' : '35');
    final published = (widget.controller.profilesState.data ?? const [])
        .where((e) => e.published)
        .toList();
    _hamsterId =
        widget.initialHamsterId ??
        (published.isNotEmpty
            ? published.first.hamsterId
            : (widget.hamsters.isNotEmpty ? widget.hamsters.first.id : null));
    if (widget.controller.profilesState.data == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller.profilesState.data == null) {
          widget.controller.refreshProfiles();
        }
      });
    }
  }

  @override
  void dispose() {
    _goal.dispose();
    _tone.dispose();
    _cta.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final hamsterId = _hamsterId;
    if (hamsterId == null || hamsterId.isEmpty) {
      showIosMessage(context, '请选择仓鼠');
      return;
    }
    setState(() => _busy = true);
    final campaign = await widget.controller.generate(
      GrowthGenerateDraft(
        campaignType: _type,
        platform: _platform,
        goal: _goal.text.trim(),
        durationSeconds: int.tryParse(_duration.text.trim()),
        tone: _tone.text.trim(),
        cta: _cta.text.trim(),
        hamsterId: hamsterId,
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    final message = widget.controller.lastMessage;
    if (message != null) showIosMessage(context, message);
    if (campaign != null) Navigator.of(context).pop(campaign);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final profiles = (widget.controller.profilesState.data ?? const [])
            .where((e) => e.published)
            .toList();
        final hamsterOptions = profiles.isNotEmpty
            ? [
                for (final e in profiles)
                  IosPickerItem(value: e.hamsterId, label: e.publicName),
              ]
            : [
                for (final e in widget.hamsters)
                  IosPickerItem(value: e.id, label: e.name ?? e.internalCode),
              ];
        return Scaffold(
          appBar: AppBar(title: Text(_type == 'live' ? '准备直播' : '生成短视频脚本')),
          body: ListView(
            padding: const EdgeInsets.all(IosMetrics.pagePadding),
            children: [
              IosPickerField<String>(
                key: const Key('growth-generate-type'),
                items: const [
                  IosPickerItem(value: 'video', label: '短视频'),
                  IosPickerItem(value: 'live', label: '直播'),
                ],
                label: '内容类型',
                selected: _type,
                enabled: !_busy,
                onSelected: (v) {
                  if (v == null) return;
                  setState(() {
                    _type = v;
                    if (_duration.text == '35' || _duration.text == '1800') {
                      _duration.text = _type == 'live' ? '1800' : '35';
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              IosPickerField<String>(
                key: const Key('growth-generate-hamster'),
                label: '仓鼠',
                items: hamsterOptions,
                selected: hamsterOptions.any((e) => e.value == _hamsterId)
                    ? _hamsterId
                    : null,
                enabled: !_busy,
                onSelected: (v) => setState(() => _hamsterId = v),
              ),
              const SizedBox(height: 12),
              IosPickerField<String>(
                key: const Key('growth-generate-platform'),
                items: const [
                  IosPickerItem(value: 'wechat_channels', label: '视频号'),
                  IosPickerItem(value: 'douyin', label: '抖音'),
                  IosPickerItem(value: 'xiaohongshu', label: '小红书'),
                  IosPickerItem(value: 'other', label: '其他'),
                ],
                label: '平台',
                selected: _platform,
                enabled: !_busy,
                onSelected: (v) {
                  if (v != null) setState(() => _platform = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('growth-generate-goal'),
                controller: _goal,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '内容目标'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('growth-generate-duration'),
                controller: _duration,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '时长（秒）'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('growth-generate-tone'),
                controller: _tone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '语气'),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('growth-generate-cta'),
                controller: _cta,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'CTA'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const Key('growth-generate-submit'),
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? '生成中…' : '生成并保存'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GrowthCampaignResultPage extends StatefulWidget {
  const GrowthCampaignResultPage({
    super.key,
    required this.campaign,
    this.onPublish,
    this.onArchive,
  });

  final GrowthCampaign campaign;
  final Future<GrowthCampaign?> Function()? onPublish;
  final Future<GrowthCampaign?> Function()? onArchive;

  @override
  State<GrowthCampaignResultPage> createState() =>
      _GrowthCampaignResultPageState();
}

class _GrowthCampaignResultPageState extends State<GrowthCampaignResultPage> {
  late GrowthCampaign _campaign;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;
  }

  Future<void> _copy(BuildContext context, String text, String ok) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) showIosMessage(context, ok);
  }

  Future<void> _share(BuildContext context) async {
    final link = _campaign.hasPublicUrl
        ? '\n\n获客链接：${_campaign.publicUrl()}'
        : '';
    final body = '${_campaign.script.fullCopyText}$link';
    try {
      await Share.share(body, subject: _campaign.title);
    } on Object {
      if (context.mounted) await _copy(context, body, '系统分享不可用，内容已复制');
    }
  }

  Future<void> _perform(Future<GrowthCampaign?> Function()? action) async {
    if (action == null || _acting) return;
    setState(() => _acting = true);
    final updated = await action();
    if (!mounted) return;
    setState(() {
      if (updated != null) _campaign = updated;
      _acting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final script = _campaign.script;
    final url = _campaign.hasPublicUrl && _campaign.status != 'archived'
        ? _campaign.publicUrl()
        : null;
    final statusColor = switch (_campaign.status) {
      'published' => IosColors.systemGreen,
      'archived' => ScolvPalette.of(context).secondaryLabel,
      _ => IosColors.systemOrange,
    };
    return Scaffold(
      appBar: AppBar(title: const Text('脚本结果')),
      body: ListView(
        padding: const EdgeInsets.all(IosMetrics.pagePadding),
        children: [
          Text(
            script.title,
            key: const Key('growth-result-title'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('钩子：${script.hook}', key: const Key('growth-result-hook')),
          Text('封面：${script.coverText}'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              IosStatusBadge(label: _campaign.statusLabel, color: statusColor),
              IosStatusBadge(
                label: '${_campaign.typeLabel} / ${_campaign.platformLabel}',
                color: IosColors.systemTeal,
              ),
            ],
          ),
          if (_campaign.createdAt != null) ...[
            const SizedBox(height: 8),
            Text('生成时间：${_campaign.createdAt!.toLocal()}'),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                key: const Key('growth-result-copy-all'),
                onPressed: _acting
                    ? null
                    : () => _copy(context, script.fullCopyText, '脚本已复制'),
                icon: const Icon(CupertinoIcons.doc_on_doc, size: 16),
                label: const Text('复制全部'),
              ),
              OutlinedButton.icon(
                key: const Key('growth-result-share'),
                onPressed: _acting ? null : () => _share(context),
                icon: const Icon(CupertinoIcons.share, size: 16),
                label: const Text('系统分享'),
              ),
              OutlinedButton.icon(
                key: const Key('growth-result-copy-link'),
                onPressed: _acting || url == null
                    ? null
                    : () => _copy(context, url, '获客链接已复制'),
                icon: const Icon(CupertinoIcons.link, size: 16),
                label: const Text('复制获客链接'),
              ),
              if (widget.onPublish != null &&
                  _campaign.status != 'published' &&
                  _campaign.status != 'archived')
                FilledButton(
                  key: const Key('growth-result-publish'),
                  onPressed: _acting ? null : () => _perform(widget.onPublish),
                  child: Text(_acting ? '处理中…' : '发布活动'),
                ),
              if (widget.onArchive != null && _campaign.status != 'archived')
                TextButton(
                  key: const Key('growth-result-archive'),
                  onPressed: _acting ? null : () => _perform(widget.onArchive),
                  child: const Text('归档'),
                ),
            ],
          ),
          if (url != null) ...[
            const SizedBox(height: 8),
            SelectableText(url, key: const Key('growth-result-url')),
          ] else ...[
            const SizedBox(height: 8),
            const IosBanner(
              icon: CupertinoIcons.link,
              color: IosColors.systemOrange,
              text: '请先保存并发布熊舍公开主页，再分享获客链接。',
            ),
          ],
          const SizedBox(height: 16),
          const IosSectionHeader('分镜 / 环节'),
          for (final section in script.sections)
            Card(
              key: Key('growth-result-section-${section.order}'),
              child: ListTile(
                title: Text(
                  '${section.order}. ${section.shot} · ${section.durationSeconds}s',
                ),
                subtitle: Text(
                  '口播：${section.voiceover}\n字幕：${section.overlay}',
                ),
                isThreeLine: true,
              ),
            ),
          const SizedBox(height: 12),
          const IosSectionHeader('发布文案'),
          Text(script.caption),
          Text(script.hashtags.join(' ')),
          Text('CTA：${script.cta}'),
          const SizedBox(height: 12),
          const IosSectionHeader('使用事实'),
          if (script.facts.isEmpty)
            const Text('这条脚本没有附带公开资料快照。')
          else
            IosGroupedSection(
              margin: EdgeInsets.zero,
              children: [
                for (final fact in script.facts)
                  IosListTile(title: fact.label, subtitle: fact.value),
              ],
            ),
        ],
      ),
    );
  }
}

class _GrowthCover extends StatelessWidget {
  const _GrowthCover({required this.media, this.size = 60});

  final GrowthMedia? media;
  final double size;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: ScolvPalette.of(context).tertiaryFill,
      child: Icon(
        CupertinoIcons.photo,
        size: size * 0.34,
        color: ScolvPalette.of(context).secondaryLabel,
      ),
    );
    final url = media?.url.trim() ?? '';
    final image = url.startsWith('assets/')
        ? Image.asset(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          )
        : url.startsWith('http://') || url.startsWith('https://')
        ? Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder,
          )
        : placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: image,
    );
  }
}

class _GrowthCompactState extends StatelessWidget {
  const _GrowthCompactState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onRetry,
    this.tone,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final color = tone ?? palette.secondaryLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(
          color: palette.opaqueSeparator,
          width: IosMetrics.hairline,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(actionLabel ?? '重试')),
        ],
      ),
    );
  }
}
