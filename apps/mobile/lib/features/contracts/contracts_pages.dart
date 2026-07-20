import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../crm/crm_controller.dart';
import '../crm/crm_models.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'contracts_controller.dart';
import 'contracts_models.dart';
import 'document_pdf.dart';

/// Contract / receipt hub (T-P1-03). Text preview + clipboard share; PDF later.
class ContractsHubPage extends StatefulWidget {
  const ContractsHubPage({
    super.key,
    required this.controller,
    this.crmController,
    this.hamsters = const <I2Hamster>[],
    this.launchContext,
    this.canWrite = true,
  });

  final ContractsController controller;
  final CrmController? crmController;
  final List<I2Hamster> hamsters;
  final ContractsLaunchContext? launchContext;
  final bool canWrite;

  @override
  State<ContractsHubPage> createState() => _ContractsHubPageState();
}

class _ContractsHubPageState extends State<ContractsHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.launchContext?.kind == 'receipt' ? 1 : 0,
    );
    widget.controller.refreshAll(installStarterTemplates: widget.canWrite);
    widget.crmController?.refreshAll();
    // 从预订/交付跳转时自动打开生成表单，避免再猜 Hub 入口。
    if (widget.launchContext != null && widget.canWrite) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await widget.controller.refreshAll(
          installStarterTemplates: widget.canWrite,
        );
        if (!mounted) return;
        if (widget.launchContext?.kind == 'receipt') {
          await _createReceipt();
        } else {
          await _createContract();
        }
      });
    }
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
      animation: Listenable.merge([
        widget.controller,
        if (widget.crmController != null) widget.crmController!,
      ]),
      builder: (context, _) {
        final contracts =
            widget.controller.contracts.data ?? const <DocDocument>[];
        final receipts =
            widget.controller.receipts.data ?? const <DocDocument>[];
        final draftCount = [
          ...contracts,
          ...receipts,
        ].where((item) => item.isDraft).length;
        final issuedCount = [
          ...contracts,
          ...receipts,
        ].where((item) => item.status == 'issued').length;
        return Scaffold(
          appBar: AppBar(
            title: const Text('合同与回执'),
            actions: [
              IconButton(
                key: const Key('doc-refresh'),
                onPressed: () => widget.controller.refreshAll(
                  installStarterTemplates: widget.canWrite,
                ),
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          floatingActionButton: widget.canWrite
              ? FloatingActionButton.extended(
                  key: const Key('doc-fab'),
                  onPressed: () async {
                    switch (_tabs.index) {
                      case 0:
                        await _createContract();
                      case 1:
                        await _createReceipt();
                      case 2:
                        await _createTemplate('contract');
                      default:
                        await _createTemplate('receipt');
                    }
                  },
                  backgroundColor: ScolvPalette.of(context).accent,
                  foregroundColor: ScolvPalette.of(context).groupedBackground,
                  elevation: 0,
                  icon: const Icon(CupertinoIcons.add),
                  label: Text(switch (_tabs.index) {
                    0 => '新建合同',
                    1 => '新建回执',
                    2 => '新建合同模板',
                    _ => '新建回执模板',
                  }),
                )
              : null,
          body: Column(
            children: [
              IosModuleIntro(
                icon: CupertinoIcons.doc_text_fill,
                title: '合同与交接凭证',
                description: '使用内置模板关联客户和交付记录，签发后可直接分享、打印或保存 PDF。',
                metrics: [
                  IosModuleMetric(label: '合同', value: '${contracts.length}'),
                  IosModuleMetric(
                    label: '回执',
                    value: '${receipts.length}',
                    color: IosColors.systemTeal,
                  ),
                  IosModuleMetric(
                    label: '待签发 / 已签发',
                    value: '$draftCount / $issuedCount',
                    color: IosColors.systemGreen,
                  ),
                ],
              ),
              if (!widget.canWrite)
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    IosMetrics.pagePadding,
                    12,
                    IosMetrics.pagePadding,
                    0,
                  ),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看、复制和输出单据，新建模板、生成草稿与签发已设为只读。',
                  ),
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
                    IosSegmentTab(
                      value: 0,
                      label: '合同',
                      key: Key('doc-tab-contracts'),
                    ),
                    IosSegmentTab(
                      value: 1,
                      label: '回执',
                      key: Key('doc-tab-receipts'),
                    ),
                    IosSegmentTab(
                      value: 2,
                      label: '合同模板',
                      key: Key('doc-tab-c-templates'),
                    ),
                    IosSegmentTab(
                      value: 3,
                      label: '回执模板',
                      key: Key('doc-tab-r-templates'),
                    ),
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
                    _DocumentsTab(
                      state: widget.controller.contracts,
                      emptyHint: '暂无合同，先建模板再生成草稿',
                      onRetry: widget.controller.refreshContracts,
                      onOpen: _openPreview,
                    ),
                    _DocumentsTab(
                      state: widget.controller.receipts,
                      emptyHint: '暂无回执，先建模板再生成草稿',
                      onRetry: widget.controller.refreshReceipts,
                      onOpen: _openPreview,
                    ),
                    _TemplatesTab(
                      state: widget.controller.contractTemplates,
                      onRetry: widget.controller.refreshContractTemplates,
                      illustration: BearAssets.emptyList,
                    ),
                    _TemplatesTab(
                      state: widget.controller.receiptTemplates,
                      onRetry: widget.controller.refreshReceiptTemplates,
                      illustration: BearAssets.emptyList,
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

  Future<void> _createTemplate(String kind) async {
    final nameCtrl = TextEditingController(
      text: kind == 'receipt' ? '订金回执' : '交接协议',
    );
    final bodyCtrl = TextEditingController();
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(kind == 'receipt' ? '新建回执模板' : '新建合同模板'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoTextField(
                key: const Key('doc-template-name'),
                controller: nameCtrl,
                textInputAction: TextInputAction.next,
                placeholder: '名称',
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                key: const Key('doc-template-body'),
                controller: bodyCtrl,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                placeholder: '正文（可空，用默认模板）',
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            key: const Key('doc-template-submit'),
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _snack(
      () => widget.controller.createTemplate(
        kind,
        DocTemplateDraft(name: nameCtrl.text, bodyText: bodyCtrl.text),
      ),
    );
  }

  Future<void> _createContract() async {
    final templates =
        widget.controller.contractTemplates.data ?? const <DocTemplate>[];
    if (templates.isEmpty) {
      showIosMessage(context, '合同模板仍在准备，请刷新后重试');
      return;
    }
    final draft = await showModalBottomSheet<ContractDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ContractFormSheet(
        templates: templates,
        contacts:
            widget.crmController?.contactsState.data ?? const <CrmContact>[],
        handovers:
            widget.crmController?.handoversState.data ?? const <CrmHandover>[],
        hamsters: widget.hamsters,
        initial: widget.launchContext,
      ),
    );
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createContract(draft));
  }

  Future<void> _createReceipt() async {
    final templates =
        widget.controller.receiptTemplates.data ?? const <DocTemplate>[];
    if (templates.isEmpty) {
      showIosMessage(context, '回执模板仍在准备，请刷新后重试');
      return;
    }
    final draft = await showModalBottomSheet<ReceiptDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReceiptFormSheet(
        templates: templates,
        contacts:
            widget.crmController?.contactsState.data ?? const <CrmContact>[],
        handovers:
            widget.crmController?.handoversState.data ?? const <CrmHandover>[],
        hamsters: widget.hamsters,
        initial: widget.launchContext,
      ),
    );
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createReceipt(draft));
  }

  void _openPreview(DocDocument item) {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => DocumentPreviewPage(
          document: item,
          onIssue: item.isDraft && widget.canWrite
              ? () => widget.controller.issueDocument(item)
              : null,
        ),
      ),
    );
  }
}

class _ContractFormSheet extends StatefulWidget {
  const _ContractFormSheet({
    required this.templates,
    required this.contacts,
    required this.handovers,
    required this.hamsters,
    this.initial,
  });

  final List<DocTemplate> templates;
  final List<CrmContact> contacts;
  final List<CrmHandover> handovers;
  final List<I2Hamster> hamsters;
  final ContractsLaunchContext? initial;

  @override
  State<_ContractFormSheet> createState() => _ContractFormSheetState();
}

class _ContractFormSheetState extends State<_ContractFormSheet> {
  late String _templateId;
  String? _contactId;
  String? _handoverId;
  String? _hamsterId;
  late final TextEditingController _title;
  late final TextEditingController _contactName;
  late final TextEditingController _hamsterName;
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _templateId = widget.templates.first.id;
    _contactId = widget.initial?.contactId;
    _handoverId = widget.initial?.handoverId;
    _hamsterId = widget.initial?.hamsterId;
    final seedHamster = widget.initial?.hamsterName?.trim() ?? '';
    _title = TextEditingController(
      text: seedHamster.isEmpty ? '' : '交接协议 · $seedHamster',
    );
    _contactName = TextEditingController(
      text: widget.initial?.contactName ?? '',
    );
    _hamsterName = TextEditingController(
      text: widget.initial?.hamsterName ?? '',
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _contactName.dispose();
    _hamsterName.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _selectHandover(String? value) {
    setState(() {
      _handoverId = value;
      if (value == null) return;
      final handover = _docHandoverById(widget.handovers, value);
      if (handover == null) return;
      _contactId = handover.contactId;
      _hamsterId = handover.hamsterId;
      _contactName.text = handover.contactName ?? _contactName.text;
      _hamsterName.text =
          _docHamsterById(widget.hamsters, handover.hamsterId)?.displayName ??
          handover.hamsterName ??
          _hamsterName.text;
    });
  }

  void _submit() {
    final selectedContact = _docContactById(widget.contacts, _contactId);
    final selectedHamster = _docHamsterById(widget.hamsters, _hamsterId);
    final contactName = selectedContact?.name ?? _contactName.text.trim();
    final hamsterName =
        selectedHamster?.displayName ?? _hamsterName.text.trim();
    if (contactName.isEmpty) {
      showIosMessage(context, '请选择客户或填写客户姓名');
      return;
    }
    Navigator.pop(
      context,
      ContractDraft(
        templateId: _templateId,
        contactId: _contactId,
        handoverId: _handoverId,
        reservationId: widget.initial?.reservationId,
        title: _title.text.trim(),
        contactName: contactName,
        hamsterName: hamsterName.isEmpty ? null : hamsterName,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(16, 18, 16, 18 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '生成合同草稿',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '模板会自动填入客户、仓鼠和交付信息，生成后可预览再签发。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ScolvPalette.of(context).secondaryLabel,
              ),
            ),
            const SizedBox(height: 16),
            IosPickerField<String>(
              key: const Key('doc-contract-template'),
              label: '合同模板',
              selected: _templateId,
              items: [
                for (final item in widget.templates)
                  IosPickerItem(value: item.id, label: item.name),
              ],
              onSelected: (value) {
                if (value != null) setState(() => _templateId = value);
              },
            ),
            const SizedBox(height: 10),
            IosPickerField<String?>(
              key: const Key('doc-contract-handover'),
              label: '关联交付',
              selected: _handoverId,
              items: [
                const IosPickerItem(value: null, label: '不关联交付单'),
                for (final item in widget.handovers)
                  IosPickerItem(
                    value: item.id,
                    label:
                        '${item.contactName ?? '客户'} · ${item.scheduledLabel}',
                  ),
              ],
              onSelected: _selectHandover,
            ),
            const SizedBox(height: 10),
            if (widget.contacts.isNotEmpty)
              IosPickerField<String?>(
                key: const Key('doc-contract-contact'),
                label: '客户',
                selected: _contactId,
                items: [
                  const IosPickerItem(value: null, label: '手动填写'),
                  for (final item in widget.contacts)
                    IosPickerItem(value: item.id, label: item.name),
                ],
                onSelected: (value) => setState(() => _contactId = value),
              ),
            if (widget.contacts.isEmpty || _contactId == null) ...[
              if (widget.contacts.isNotEmpty) const SizedBox(height: 10),
              TextField(
                key: const Key('doc-contract-contact-name'),
                controller: _contactName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '客户姓名 *'),
              ),
            ],
            const SizedBox(height: 10),
            if (widget.hamsters.isNotEmpty)
              IosPickerField<String?>(
                key: const Key('doc-contract-hamster'),
                label: '交接仓鼠',
                selected: _hamsterId,
                items: [
                  const IosPickerItem(value: null, label: '手动填写或不关联'),
                  for (final item in widget.hamsters)
                    IosPickerItem(value: item.id, label: item.displayName),
                ],
                onSelected: (value) => setState(() => _hamsterId = value),
              ),
            if (widget.hamsters.isEmpty || _hamsterId == null) ...[
              if (widget.hamsters.isNotEmpty) const SizedBox(height: 10),
              TextField(
                key: const Key('doc-contract-hamster-name'),
                controller: _hamsterName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '个体名称（可选）'),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              key: const Key('doc-contract-title'),
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: '合同标题（可选）'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: '补充约定（可选）'),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('doc-contract-submit'),
              onPressed: _submit,
              icon: const Icon(CupertinoIcons.doc_append),
              label: const Text('生成合同草稿'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptFormSheet extends StatefulWidget {
  const _ReceiptFormSheet({
    required this.templates,
    required this.contacts,
    required this.handovers,
    required this.hamsters,
    this.initial,
  });

  final List<DocTemplate> templates;
  final List<CrmContact> contacts;
  final List<CrmHandover> handovers;
  final List<I2Hamster> hamsters;
  final ContractsLaunchContext? initial;

  @override
  State<_ReceiptFormSheet> createState() => _ReceiptFormSheetState();
}

class _ReceiptFormSheetState extends State<_ReceiptFormSheet> {
  late String _templateId;
  String? _contactId;
  String? _handoverId;
  String? _hamsterId;
  late final TextEditingController _contactName;
  late final TextEditingController _hamsterName;
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _templateId = widget.templates.first.id;
    _contactId = widget.initial?.contactId;
    _handoverId = widget.initial?.handoverId;
    _hamsterId = widget.initial?.hamsterId;
    _contactName = TextEditingController(
      text: widget.initial?.contactName ?? '',
    );
    _hamsterName = TextEditingController(
      text: widget.initial?.hamsterName ?? '',
    );
  }

  @override
  void dispose() {
    _contactName.dispose();
    _hamsterName.dispose();
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _selectHandover(String? value) {
    setState(() {
      _handoverId = value;
      if (value == null) return;
      final handover = _docHandoverById(widget.handovers, value);
      if (handover == null) return;
      _contactId = handover.contactId;
      _hamsterId = handover.hamsterId;
      _contactName.text = handover.contactName ?? _contactName.text;
      _hamsterName.text =
          _docHamsterById(widget.hamsters, handover.hamsterId)?.displayName ??
          handover.hamsterName ??
          _hamsterName.text;
    });
  }

  void _submit() {
    final yuan = double.tryParse(_amount.text.trim());
    if (yuan == null || yuan < 0) {
      showIosMessage(context, '请输入有效金额');
      return;
    }
    final selectedContact = _docContactById(widget.contacts, _contactId);
    final selectedHamster = _docHamsterById(widget.hamsters, _hamsterId);
    final contactName = selectedContact?.name ?? _contactName.text.trim();
    final hamsterName =
        selectedHamster?.displayName ?? _hamsterName.text.trim();
    if (contactName.isEmpty) {
      showIosMessage(context, '请选择客户或填写客户姓名');
      return;
    }
    Navigator.pop(
      context,
      ReceiptDraft(
        templateId: _templateId,
        contactId: _contactId,
        handoverId: _handoverId,
        title: _title.text.trim(),
        amountCents: (yuan * 100).round(),
        contactName: contactName,
        hamsterName: hamsterName.isEmpty ? null : hamsterName,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(16, 18, 16, 18 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '生成收款回执',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '回执会关联客户与交付记录，签发后可分享 PDF 或直接打印。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ScolvPalette.of(context).secondaryLabel,
              ),
            ),
            const SizedBox(height: 16),
            IosPickerField<String>(
              key: const Key('doc-receipt-template'),
              label: '回执模板',
              selected: _templateId,
              items: [
                for (final item in widget.templates)
                  IosPickerItem(value: item.id, label: item.name),
              ],
              onSelected: (value) {
                if (value != null) setState(() => _templateId = value);
              },
            ),
            const SizedBox(height: 10),
            IosPickerField<String?>(
              key: const Key('doc-receipt-handover'),
              label: '关联交付',
              selected: _handoverId,
              items: [
                const IosPickerItem(value: null, label: '不关联交付单'),
                for (final item in widget.handovers)
                  IosPickerItem(
                    value: item.id,
                    label:
                        '${item.contactName ?? '客户'} · ${item.scheduledLabel}',
                  ),
              ],
              onSelected: _selectHandover,
            ),
            const SizedBox(height: 10),
            if (widget.contacts.isNotEmpty)
              IosPickerField<String?>(
                key: const Key('doc-receipt-contact'),
                label: '客户',
                selected: _contactId,
                items: [
                  const IosPickerItem(value: null, label: '手动填写'),
                  for (final item in widget.contacts)
                    IosPickerItem(value: item.id, label: item.name),
                ],
                onSelected: (value) => setState(() => _contactId = value),
              ),
            if (widget.contacts.isEmpty || _contactId == null) ...[
              if (widget.contacts.isNotEmpty) const SizedBox(height: 10),
              TextField(
                key: const Key('doc-receipt-contact-name'),
                controller: _contactName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '客户姓名 *'),
              ),
            ],
            const SizedBox(height: 10),
            if (widget.hamsters.isNotEmpty)
              IosPickerField<String?>(
                label: '关联仓鼠',
                selected: _hamsterId,
                items: [
                  const IosPickerItem(value: null, label: '手动填写或不关联'),
                  for (final item in widget.hamsters)
                    IosPickerItem(value: item.id, label: item.displayName),
                ],
                onSelected: (value) => setState(() => _hamsterId = value),
              ),
            if (widget.hamsters.isEmpty || _hamsterId == null) ...[
              if (widget.hamsters.isNotEmpty) const SizedBox(height: 10),
              TextField(
                controller: _hamsterName,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: '个体名称（可选）'),
              ),
            ],
            const SizedBox(height: 10),
            TextField(
              key: const Key('doc-receipt-title'),
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: '收款项目（可选）'),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const Key('doc-receipt-amount'),
              controller: _amount,
              textInputAction: TextInputAction.next,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              decoration: const InputDecoration(
                labelText: '金额（元） *',
                prefixText: '¥ ',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: '备注（可选）'),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              key: const Key('doc-receipt-submit'),
              onPressed: _submit,
              icon: const Icon(CupertinoIcons.doc_append),
              label: const Text('生成回执草稿'),
            ),
          ],
        ),
      ),
    );
  }
}

CrmContact? _docContactById(List<CrmContact> contacts, String? id) {
  if (id == null) return null;
  for (final contact in contacts) {
    if (contact.id == id) return contact;
  }
  return null;
}

CrmHandover? _docHandoverById(List<CrmHandover> handovers, String id) {
  for (final handover in handovers) {
    if (handover.id == id) return handover;
  }
  return null;
}

I2Hamster? _docHamsterById(List<I2Hamster> hamsters, String? id) {
  if (id == null) return null;
  for (final hamster in hamsters) {
    if (hamster.id == id) return hamster;
  }
  return null;
}

class _TemplatesTab extends StatelessWidget {
  const _TemplatesTab({
    required this.state,
    required this.onRetry,
    required this.illustration,
  });

  final I2AsyncState<List<DocTemplate>> state;
  final VoidCallback onRetry;
  final String illustration;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<DocTemplate>>(
      state: state,
      onRetry: onRetry,
      emptyBuilder: (context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: BearEmptyCard(
            title: '模板正在准备',
            subtitle: '熊舍管家会安装交接协议、预订确认和收款回执起步模板。',
            illustration: illustration,
            actionLabel: '刷新',
            onAction: onRetry,
          ),
        ),
      ),
      builder: (items) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
          children: [
            IosGroupedSection(
              children: [
                for (final item in items)
                  IosListTile(
                    title: item.name,
                    subtitle: item.bodyText,
                    leading: IosGlyph(
                      icon: item.kind == 'receipt'
                          ? CupertinoIcons.doc_plaintext
                          : CupertinoIcons.doc_text_fill,
                      color: item.kind == 'receipt'
                          ? IosColors.systemTeal
                          : IosColors.systemIndigo,
                    ),
                    showChevron: false,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab({
    required this.state,
    required this.emptyHint,
    required this.onRetry,
    required this.onOpen,
  });

  final I2AsyncState<List<DocDocument>> state;
  final String emptyHint;
  final VoidCallback onRetry;
  final void Function(DocDocument item) onOpen;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<DocDocument>>(
      state: state,
      onRetry: onRetry,
      emptyBuilder: (_) => I2StateMessage(
        icon: CupertinoIcons.tray,
        message: emptyHint,
        onRetry: onRetry,
        illustration: BearAssets.emptyList,
      ),
      builder: (items) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
          children: [
            IosGroupedSection(
              children: [
                for (final item in items)
                  IosListTile(
                    key: Key('doc-item-${item.id}'),
                    title: item.title,
                    subtitle: [
                      item.statusLabel,
                      if (item.contactName != null &&
                          item.contactName!.isNotEmpty)
                        item.contactName!,
                      if (item.amountLabel != null) item.amountLabel!,
                    ].join(' · '),
                    leading: IosGlyph(
                      icon: item.kind == 'receipt'
                          ? CupertinoIcons.doc_plaintext
                          : CupertinoIcons.doc_text_fill,
                      color: item.kind == 'receipt'
                          ? IosColors.systemTeal
                          : IosColors.systemIndigo,
                    ),
                    trailing: IosStatusBadge(
                      label: item.statusLabel,
                      color: item.isDraft
                          ? IosColors.systemOrange
                          : IosColors.systemGreen,
                    ),
                    onTap: () => onOpen(item),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class DocumentPreviewPage extends StatefulWidget {
  const DocumentPreviewPage({super.key, required this.document, this.onIssue});

  final DocDocument document;
  final Future<bool> Function()? onIssue;

  @override
  State<DocumentPreviewPage> createState() => _DocumentPreviewPageState();
}

class _DocumentPreviewPageState extends State<DocumentPreviewPage> {
  late final Future<Uint8List> _pdfBytes = buildDocumentPdf(widget.document);

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.document.bodyFilled));
    if (!context.mounted) return;
    showIosMessage(context, '正文已复制');
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final bytes = await _pdfBytes;
      await Printing.sharePdf(
        bytes: bytes,
        filename: documentPdfFileName(widget.document),
      );
    } on Object {
      if (!context.mounted) return;
      showIosMessage(context, 'PDF 分享未完成，请稍后重试');
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        name: widget.document.title,
        onLayout: (_) => _pdfBytes,
      );
    } on Object {
      if (!context.mounted) return;
      showIosMessage(context, '打印未完成，请检查系统打印服务');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.title),
        actions: [
          IconButton(
            key: const Key('doc-copy-share'),
            tooltip: '复制正文',
            onPressed: () => _copy(context),
            icon: const Icon(CupertinoIcons.doc_on_doc),
          ),
          PopupMenuButton<String>(
            tooltip: '输出单据',
            onSelected: (value) {
              if (value == 'share') _sharePdf(context);
              if (value == 'print') _printPdf(context);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'share', child: Text('分享 PDF')),
              PopupMenuItem(value: 'print', child: Text('打印 / 保存 PDF')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              IosStatusBadge(
                label: widget.document.kindLabel,
                color: widget.document.kind == 'receipt'
                    ? IosColors.systemTeal
                    : IosColors.systemIndigo,
              ),
              IosStatusBadge(
                label: widget.document.statusLabel,
                color: widget.document.isDraft
                    ? IosColors.systemOrange
                    : IosColors.systemGreen,
              ),
              if (widget.document.amountLabel != null)
                IosStatusBadge(
                  label: widget.document.amountLabel!,
                  color: ScolvPalette.of(context).accent,
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.58,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
              child: PdfPreview(
                build: (_) => _pdfBytes,
                pdfFileName: documentPdfFileName(widget.document),
                initialPageFormat: PdfPageFormat.a4,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                allowPrinting: false,
                allowSharing: false,
                useActions: false,
                loadingWidget: const IosLoading(),
                onError: (context, error) => Center(
                  child: IosBanner(
                    icon: CupertinoIcons.exclamationmark_triangle,
                    text: 'PDF 预览生成失败，请复制正文或稍后重试',
                    color: IosColors.systemRed,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('查看可复制正文'),
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ScolvPalette.of(context).secondaryGroupedBackground,
                  borderRadius: BorderRadius.circular(
                    IosMetrics.continuousRadius,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  widget.document.bodyFilled,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
          if (widget.onIssue != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('doc-preview-issue'),
              onPressed: () async {
                final ok = await widget.onIssue!();
                if (!context.mounted) return;
                showIosMessage(context, ok ? '已签发' : '签发失败');
                if (ok) Navigator.of(context).pop();
              },
              icon: const Icon(CupertinoIcons.checkmark_circle),
              label: const Text('签发'),
            ),
          ],
        ],
      ),
    );
  }
}
