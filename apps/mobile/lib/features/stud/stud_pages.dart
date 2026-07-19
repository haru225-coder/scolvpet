import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'stud_controller.dart';
import 'stud_models.dart';

/// Cross-cattery stud network hub (T-P2-05).
class StudHubPage extends StatefulWidget {
  const StudHubPage({
    super.key,
    required this.controller,
    this.hamsters = const <I2Hamster>[],
    this.canWrite = true,
  });

  final StudController controller;
  final List<I2Hamster> hamsters;
  final bool canWrite;

  @override
  State<StudHubPage> createState() => _StudHubPageState();
}

class _StudHubPageState extends State<StudHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.refreshAll();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('跨舍借配'),
            actions: [
              IconButton(
                key: const Key('stud-refresh'),
                tooltip: '刷新借配数据',
                onPressed: busy ? null : widget.controller.refreshAll,
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          floatingActionButton: widget.canWrite
              ? FloatingActionButton.extended(
                  key: const Key('stud-fab'),
                  onPressed: busy
                      ? null
                      : () async {
                          if (_tabs.index == 0) {
                            await _createListing();
                          } else {
                            await _createDeal();
                          }
                        },
                  backgroundColor: ScolvPalette.of(context).accent,
                  foregroundColor: ScolvPalette.of(
                    context,
                  ).groupedBackground,
                  elevation: 0,
                  icon: const Icon(CupertinoIcons.add),
                  label: Text(_tabs.index == 0 ? '发布挂牌' : '新建借配单'),
                )
              : null,
          body: Column(
            children: [
              if (!widget.canWrite)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看借配挂牌与履约记录，发布和状态操作已设为只读。',
                  ),
                ),
              if (busy)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: ScolvPalette.of(context).accent,
                  backgroundColor: Colors.transparent,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  IosMetrics.pagePadding,
                  12,
                  IosMetrics.pagePadding,
                  0,
                ),
                child: IosSegmentedControl<int>(
                  tabs: const [
                    IosSegmentTab(value: 0, label: '挂牌市场'),
                    IosSegmentTab(value: 1, label: '我的履约'),
                  ],
                  selected: _tabs.index,
                  onSelect: (i) => _tabs.animateTo(i),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _ListingsTab(
                      state: widget.controller.listingsState,
                      onRetry: widget.controller.refreshListings,
                      canWrite: widget.canWrite && !busy,
                      onCreate: _createListing,
                      onUnpublish: (item) => _confirmUnpublish(item),
                      onRequest: (item) => _createDeal(fromListing: item),
                    ),
                    _DealsTab(
                      state: widget.controller.dealsState,
                      onRetry: widget.controller.refreshDeals,
                      canWrite: widget.canWrite && !busy,
                      onCreate: () => _createDeal(),
                      onConfirm: (d) =>
                          _snack(() => widget.controller.confirm(d)),
                      onStart: (d) => _snack(() => widget.controller.start(d)),
                      onComplete: _confirmComplete,
                      onCancel: _confirmCancel,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<I2Hamster> get _eligibleHamsters => widget.hamsters.where((hamster) {
    return hamster.lifecycleStatus == 'active' &&
        hamster.breedingStatus != 'retired';
  }).toList();

  Future<void> _createListing() async {
    final males = _eligibleHamsters
        .where((hamster) => hamster.sex == 'male')
        .toList();
    if (males.isEmpty) {
      _showMessage('暂无可挂牌种公，请先在仓鼠档案中添加或调整繁育状态');
      return;
    }
    final draft = await Navigator.of(context).push<StudListingDraft>(
      iosPageRoute(builder: (_) => _StudListingEditorPage(males: males)),
    );
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createListing(draft));
  }

  Future<void> _createDeal({StudListing? fromListing}) async {
    final draft = await Navigator.of(context).push<StudDealDraft>(
      iosPageRoute(
        builder: (_) => _StudDealEditorPage(
          hamsters: _eligibleHamsters,
          fromListing: fromListing,
        ),
      ),
    );
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createDeal(draft));
  }

  Future<void> _confirmUnpublish(StudListing item) async {
    final confirmed = await showIosAlert(
      context: context,
      title: '下架挂牌',
      message: '“${item.title}”下架后将不再出现在公开挂牌市场。',
      confirmLabel: '确认下架',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    await _snack(() => widget.controller.unpublishListing(item));
  }

  Future<void> _confirmComplete(StudDeal item) async {
    final confirmed = await showIosAlert(
      context: context,
      title: '完成借配履约',
      message: '确认双方交接、费用与合作结果都已记录后，再完成这份履约单。',
      confirmLabel: '确认完成',
    );
    if (confirmed != true || !mounted) return;
    await _snack(() => widget.controller.complete(item));
  }

  Future<void> _confirmCancel(StudDeal item) async {
    final confirmed = await showIosAlert(
      context: context,
      title: '取消借配履约',
      message: '取消后这份履约单将停止推进，历史记录仍会保留。',
      confirmLabel: '确认取消',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    await _snack(() => widget.controller.cancel(item));
  }

  void _showMessage(String message) {
    showIosMessage(context, message);
  }
}

class _StudListingEditorPage extends StatefulWidget {
  const _StudListingEditorPage({required this.males});

  final List<I2Hamster> males;

  @override
  State<_StudListingEditorPage> createState() =>
      _StudListingEditorPageState();
}

class _StudListingEditorPageState extends State<_StudListingEditorPage> {
  final _titleCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  String? _sireId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sireId = widget.males.firstOrNull?.id;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _feeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final sire = widget.males.cast<I2Hamster?>().firstWhere(
      (hamster) => hamster?.id == _sireId,
      orElse: () => null,
    );
    if (sire == null) {
      setState(() => _error = '请选择一只可繁育种公');
      return;
    }
    final fee = _studFeeCents(_feeCtrl.text);
    if (fee == null) {
      setState(() => _error = '费用请输入不超过两位小数的非负金额');
      return;
    }
    final title = _titleCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    Navigator.pop(
      context,
      StudListingDraft(
        sireLabel: sire.displayName,
        title: title,
        feeCents: fee,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('发布种公挂牌')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  const IosBanner(
                    icon: CupertinoIcons.info_circle,
                    color: IosColors.systemBlue,
                    text: '挂牌会引用仓鼠档案中的真实种公，公开内容只展示名称、编号、标题、费用与备注。',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    IosBanner(
                      icon: CupertinoIcons.exclamationmark_triangle,
                      color: IosColors.systemRed,
                      text: _error!,
                    ),
                  ],
                  const SizedBox(height: 14),
                  IosPickerField<String>(
                    key: const Key('stud-listing-sire'),
                    label: '选择种公',
                    items: [
                      for (final hamster in widget.males)
                        IosPickerItem(
                          value: hamster.id,
                          label:
                              '${hamster.displayName} · ${hamster.corePhenotypeLabel ?? '表型未记录'}',
                        ),
                    ],
                    selected: _sireId,
                    onSelected: (value) {
                      setState(() {
                        _sireId = value;
                        _error = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  const _StudFieldLabel('挂牌标题（可选）'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    key: const Key('stud-listing-title'),
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                    placeholder: '留空时自动使用“种公名称 借配”',
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 16),
                  const _StudFieldLabel('服务费用（元）'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    key: const Key('stud-listing-fee'),
                    controller: _feeCtrl,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 16),
                  const _StudFieldLabel('说明（可选）'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    key: const Key('stud-listing-notes'),
                    controller: _notesCtrl,
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    placeholder: '可填写健康条件、时间安排或合作要求',
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: IosPrimaryButton(
                  key: const Key('stud-listing-submit'),
                  label: '发布挂牌',
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudDealEditorPage extends StatefulWidget {
  const _StudDealEditorPage({required this.hamsters, this.fromListing});

  final List<I2Hamster> hamsters;
  final StudListing? fromListing;

  @override
  State<_StudDealEditorPage> createState() => _StudDealEditorPageState();
}

class _StudDealEditorPageState extends State<_StudDealEditorPage> {
  late String _side;
  final _partnerCtrl = TextEditingController();
  final _partnerContactCtrl = TextEditingController();
  final _partnerAnimalCtrl = TextEditingController();
  final _feeCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  String? _myHamsterId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _side = 'requester';
    final listing = widget.fromListing;
    if (listing != null) {
      _partnerCtrl.text = listing.catteryName ?? '';
      _partnerAnimalCtrl.text = listing.sireLabel;
      _feeCtrl.text = (listing.feeCents / 100).toStringAsFixed(2);
    }
    _selectFirstEligible();
  }

  List<I2Hamster> get _eligibleForSide {
    final sex = _side == 'provider' ? 'male' : 'female';
    return widget.hamsters.where((hamster) => hamster.sex == sex).toList();
  }

  void _selectFirstEligible() {
    final eligible = _eligibleForSide;
    _myHamsterId = eligible.firstOrNull?.id;
  }

  @override
  void dispose() {
    _partnerCtrl.dispose();
    _partnerContactCtrl.dispose();
    _partnerAnimalCtrl.dispose();
    _feeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final partner = _partnerCtrl.text.trim();
    if (partner.isEmpty) {
      setState(() => _error = '请输入对方熊舍名称');
      return;
    }
    if (partner.runes.length > 160) {
      setState(() => _error = '对方熊舍名称不能超过 160 个字符');
      return;
    }
    final mine = _eligibleForSide.cast<I2Hamster?>().firstWhere(
      (hamster) => hamster?.id == _myHamsterId,
      orElse: () => null,
    );
    if (mine == null) {
      setState(
        () => _error = _side == 'provider'
            ? '请选择本舍出借的种公'
            : '请选择本舍参与配对的母鼠',
      );
      return;
    }
    final fee = _studFeeCents(_feeCtrl.text);
    if (fee == null) {
      setState(() => _error = '费用请输入不超过两位小数的非负金额');
      return;
    }
    final contact = _partnerContactCtrl.text.trim();
    final partnerAnimal = _partnerAnimalCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    Navigator.pop(
      context,
      StudDealDraft(
        listingId: widget.fromListing?.id,
        side: _side,
        partnerCatteryName: partner,
        myHamsterLabel: mine.displayName,
        partnerContact: contact.isEmpty ? null : contact,
        partnerAnimalLabel: partnerAnimal.isEmpty ? null : partnerAnimal,
        feeCents: fee,
        notes: notes.isEmpty ? null : notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eligible = _eligibleForSide;
    final fromListing = widget.fromListing != null;
    return Scaffold(
      appBar: AppBar(title: Text(fromListing ? '申请借配' : '新建借配单')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  IosBanner(
                    icon: CupertinoIcons.info_circle,
                    color: IosColors.systemBlue,
                    text: fromListing
                        ? '这份申请会关联所选挂牌，并从本舍真实仓鼠档案选择参与配对的母鼠。'
                        : '借入时选择本舍母鼠，出借时选择本舍种公。对方个体可按合作信息填写。',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    IosBanner(
                      icon: CupertinoIcons.exclamationmark_triangle,
                      color: IosColors.systemRed,
                      text: _error!,
                    ),
                  ],
                  if (eligible.isEmpty) ...[
                    const SizedBox(height: 10),
                    IosBanner(
                      icon: CupertinoIcons.paw,
                      color: IosColors.systemOrange,
                      text: _side == 'provider'
                          ? '本舍暂无可出借种公，请先完善仓鼠档案与繁育状态。'
                          : '本舍暂无可参与借配的母鼠，请先完善仓鼠档案与繁育状态。',
                    ),
                  ],
                  if (!fromListing) ...[
                    const SizedBox(height: 14),
                    IosSegmentedControl<String>(
                      tabs: const [
                        IosSegmentTab(value: 'requester', label: '借入种公'),
                        IosSegmentTab(value: 'provider', label: '出借种公'),
                      ],
                      selected: _side,
                      onSelect: (value) {
                        setState(() {
                          _side = value;
                          _selectFirstEligible();
                          _error = null;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  IosPickerField<String>(
                    key: const Key('stud-deal-mine'),
                    label: _side == 'provider' ? '本舍出借种公' : '本舍参与母鼠',
                    items: [
                      for (final hamster in eligible)
                        IosPickerItem(
                          value: hamster.id,
                          label:
                              '${hamster.displayName} · ${hamster.corePhenotypeLabel ?? '表型未记录'}',
                        ),
                    ],
                    selected: _myHamsterId,
                    onSelected: (value) {
                      setState(() {
                        _myHamsterId = value;
                        _error = null;
                      });
                    },
                    hint: eligible.isEmpty ? '暂无符合条件的仓鼠' : '请选择',
                    enabled: eligible.isNotEmpty,
                  ),
                  const SizedBox(height: 16),
                  const _StudFieldLabel('对方熊舍'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    key: const Key('stud-deal-partner'),
                    controller: _partnerCtrl,
                    readOnly: fromListing,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 16),
                  const _StudFieldLabel('对方个体（可选）'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    key: const Key('stud-deal-partner-animal'),
                    controller: _partnerAnimalCtrl,
                    readOnly: fromListing,
                    textInputAction: TextInputAction.next,
                    placeholder: '对方提供的仓鼠名称或编号',
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 16),
                  const _StudFieldLabel('对方联系方式（可选）'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    key: const Key('stud-deal-contact'),
                    controller: _partnerContactCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    placeholder: '手机号、微信或其他联系信息',
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 16),
                  const _StudFieldLabel('约定费用（元）'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    key: const Key('stud-deal-fee'),
                    controller: _feeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() => _error = null),
                  ),
                  const SizedBox(height: 16),
                  const _StudFieldLabel('履约备注（可选）'),
                  const SizedBox(height: 6),
                  CupertinoTextField(
                    key: const Key('stud-deal-notes'),
                    controller: _notesCtrl,
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    placeholder: '可记录时间、交接、健康检查或费用说明',
                    onChanged: (_) => setState(() => _error = null),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: IosPrimaryButton(
                  key: const Key('stud-deal-submit'),
                  label: fromListing ? '提交申请' : '创建借配单',
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudFieldLabel extends StatelessWidget {
  const _StudFieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

int? _studFeeCents(String raw) {
  final value = raw.trim();
  if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) return null;
  final yuan = double.tryParse(value);
  if (yuan == null || !yuan.isFinite || yuan < 0) return null;
  return (yuan * 100).round();
}

class _ListingsTab extends StatelessWidget {
  const _ListingsTab({
    required this.state,
    required this.onRetry,
    required this.canWrite,
    required this.onCreate,
    required this.onUnpublish,
    required this.onRequest,
  });

  final I2AsyncState<List<StudListing>> state;
  final VoidCallback onRetry;
  final bool canWrite;
  final Future<void> Function() onCreate;
  final Future<void> Function(StudListing item) onUnpublish;
  final Future<void> Function(StudListing item) onRequest;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<StudListing>>(
      state: state,
      onRetry: onRetry,
      emptyBuilder: (context) => I2StateMessage(
        icon: CupertinoIcons.person_2,
        message: '暂无公开借配挂牌',
        actionLabel: canWrite ? '发布挂牌' : null,
        onRetry: canWrite ? () => onCreate() : null,
      ),
      builder: (items) {
        return RefreshIndicator.adaptive(
          onRefresh: () async => onRetry(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 100),
            children: [
              IosGroupedSection(
                children: [
                  for (final item in items)
                    IosListTile(
                      key: Key('stud-listing-${item.id}'),
                      leading: IosGlyph(
                        icon: item.isMine
                            ? CupertinoIcons.house_fill
                            : CupertinoIcons.building_2_fill,
                        color: item.isMine
                            ? ScolvPalette.of(context).accent
                            : IosColors.systemBlue,
                      ),
                      title: item.title,
                      subtitle: [
                        item.sireLabel,
                        if (item.catteryName != null &&
                            item.catteryName!.isNotEmpty)
                          item.catteryName!,
                        item.feeLabel,
                        if (item.isMine) (item.published ? '已公开' : '已下架'),
                      ].join(' · '),
                      trailing: !canWrite
                          ? null
                          : item.isMine
                          ? (item.published
                                ? TextButton(
                                    key: Key('stud-unpublish-${item.id}'),
                                    onPressed: () => onUnpublish(item),
                                    child: const Text('下架'),
                                  )
                                : null)
                          : TextButton(
                              key: Key('stud-request-${item.id}'),
                              onPressed: () => onRequest(item),
                              child: const Text('申请'),
                            ),
                      showChevron: false,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DealsTab extends StatelessWidget {
  const _DealsTab({
    required this.state,
    required this.onRetry,
    required this.canWrite,
    required this.onCreate,
    required this.onConfirm,
    required this.onStart,
    required this.onComplete,
    required this.onCancel,
  });

  final I2AsyncState<List<StudDeal>> state;
  final VoidCallback onRetry;
  final bool canWrite;
  final Future<void> Function() onCreate;
  final Future<void> Function(StudDeal item) onConfirm;
  final Future<void> Function(StudDeal item) onStart;
  final Future<void> Function(StudDeal item) onComplete;
  final Future<void> Function(StudDeal item) onCancel;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<StudDeal>>(
      state: state,
      onRetry: onRetry,
      emptyBuilder: (context) => I2StateMessage(
        icon: CupertinoIcons.doc_text,
        message: '暂无借配履约单',
        actionLabel: canWrite ? '新建借配单' : null,
        onRetry: canWrite ? () => onCreate() : null,
      ),
      builder: (items) {
        return RefreshIndicator.adaptive(
          onRefresh: () async => onRetry(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == items.length - 1 ? 0 : 10,
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ScolvPalette.of(context).secondaryGroupedBackground,
                    borderRadius: BorderRadius.circular(
                      IosMetrics.continuousRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      IosListTile(
                        key: Key('stud-deal-${item.id}'),
                        title: '${item.sideLabel} · ${item.partnerCatteryName}',
                        subtitle: [
                          item.feeLabel,
                          if (item.myHamsterLabel != null)
                            '本舍 ${item.myHamsterLabel!}',
                          if (item.partnerAnimalLabel != null)
                            '对方 ${item.partnerAnimalLabel!}',
                        ].join(' · '),
                        trailing: IosStatusBadge(
                          label: item.statusLabel,
                          color: _studStatusColor(context, item.status),
                        ),
                        showChevron: false,
                      ),
                      if (canWrite && item.nextActionLabel != null) ...[
                        const SizedBox(height: 8),
                        FilledButton(
                          key: Key('stud-primary-${item.id}'),
                          onPressed: () => _runPrimary(item),
                          child: Text(item.nextActionLabel!),
                        ),
                      ],
                      if (canWrite && item.canCancel)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            key: Key('stud-cancel-${item.id}'),
                            onPressed: () => onCancel(item),
                            child: const Text('取消履约单'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _runPrimary(StudDeal item) {
    if (item.canConfirm) return onConfirm(item);
    if (item.canStart) return onStart(item);
    return onComplete(item);
  }
}

Color _studStatusColor(BuildContext context, String status) => switch (status) {
  'completed' => IosColors.systemGreen,
  'cancelled' => IosColors.systemRed,
  'in_progress' => ScolvPalette.of(context).accent,
  'confirmed' => IosColors.systemBlue,
  _ => IosColors.systemOrange,
};
