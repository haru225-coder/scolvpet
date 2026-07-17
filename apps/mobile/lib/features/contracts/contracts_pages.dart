import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'contracts_controller.dart';
import 'contracts_models.dart';

/// Contract / receipt hub (T-P1-03). Text preview + clipboard share; PDF later.
class ContractsHubPage extends StatefulWidget {
  const ContractsHubPage({super.key, required this.controller});

  final ContractsController controller;

  @override
  State<ContractsHubPage> createState() => _ContractsHubPageState();
}

class _ContractsHubPageState extends State<ContractsHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    widget.controller.refreshAll();
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('合同与回执'),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabs: const [
                Tab(key: Key('doc-tab-contracts'), text: '合同'),
                Tab(key: Key('doc-tab-receipts'), text: '回执'),
                Tab(key: Key('doc-tab-c-templates'), text: '合同模板'),
                Tab(key: Key('doc-tab-r-templates'), text: '回执模板'),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('doc-refresh'),
                onPressed: widget.controller.refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
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
            icon: const Icon(Icons.add),
            label: Text(switch (_tabs.index) {
              0 => '新建合同',
              1 => '新建回执',
              2 => '新建合同模板',
              _ => '新建回执模板',
            }),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _DocumentsTab(
                state: widget.controller.contracts,
                emptyHint: '暂无合同，先建模板再生成草稿',
                onRetry: widget.controller.refreshContracts,
                onIssue: (item) =>
                    _snack(() => widget.controller.issueDocument(item)),
                onOpen: _openPreview,
              ),
              _DocumentsTab(
                state: widget.controller.receipts,
                emptyHint: '暂无回执，先建模板再生成草稿',
                onRetry: widget.controller.refreshReceipts,
                onIssue: (item) =>
                    _snack(() => widget.controller.issueDocument(item)),
                onOpen: _openPreview,
              ),
              _TemplatesTab(
                state: widget.controller.contractTemplates,
                onRetry: widget.controller.refreshContractTemplates,
              ),
              _TemplatesTab(
                state: widget.controller.receiptTemplates,
                onRetry: widget.controller.refreshReceiptTemplates,
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(kind == 'receipt' ? '新建回执模板' : '新建合同模板'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('doc-template-name'),
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('doc-template-body'),
                controller: bodyCtrl,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: '正文（可空，用默认模板）',
                  hintText:
                      '{{contact_name}} {{title}} {{amount}} {{date}} {{notes}}',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('doc-template-submit'),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先创建合同模板')));
      return;
    }
    DocTemplate selected = templates.first;
    final titleCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final hamsterCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('新建合同草稿'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    key: const Key('doc-contract-template'),
                    initialValue: selected.id,
                    items: [
                      for (final t in templates)
                        DropdownMenuItem(value: t.id, child: Text(t.name)),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      selected = templates.firstWhere((t) => t.id == value);
                      setLocal(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: '模板',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('doc-contract-title'),
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: '标题（可空）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('doc-contract-contact'),
                    controller: contactCtrl,
                    decoration: const InputDecoration(
                      labelText: '客户姓名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('doc-contract-hamster'),
                    controller: hamsterCtrl,
                    decoration: const InputDecoration(
                      labelText: '个体名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                key: const Key('doc-contract-submit'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('生成草稿'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || !mounted) return;
    await _snack(
      () => widget.controller.createContract(
        ContractDraft(
          templateId: selected.id,
          title: titleCtrl.text,
          contactName: contactCtrl.text.trim().isEmpty
              ? null
              : contactCtrl.text.trim(),
          hamsterName: hamsterCtrl.text.trim().isEmpty
              ? null
              : hamsterCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        ),
      ),
    );
  }

  Future<void> _createReceipt() async {
    final templates =
        widget.controller.receiptTemplates.data ?? const <DocTemplate>[];
    if (templates.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先创建回执模板')));
      return;
    }
    DocTemplate selected = templates.first;
    final titleCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final amountCtrl = TextEditingController(text: '100');
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('新建回执草稿'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    key: const Key('doc-receipt-template'),
                    initialValue: selected.id,
                    items: [
                      for (final t in templates)
                        DropdownMenuItem(value: t.id, child: Text(t.name)),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      selected = templates.firstWhere((t) => t.id == value);
                      setLocal(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: '模板',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('doc-receipt-title'),
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: '项目（可空）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('doc-receipt-contact'),
                    controller: contactCtrl,
                    decoration: const InputDecoration(
                      labelText: '客户姓名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('doc-receipt-amount'),
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: '金额（元）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: '备注',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                key: const Key('doc-receipt-submit'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('生成草稿'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || !mounted) return;
    final yuan = double.tryParse(amountCtrl.text.trim());
    if (yuan == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效金额')));
      return;
    }
    final cents = (yuan * 100).round();
    await _snack(
      () => widget.controller.createReceipt(
        ReceiptDraft(
          templateId: selected.id,
          title: titleCtrl.text,
          amountCents: cents,
          contactName: contactCtrl.text.trim().isEmpty
              ? null
              : contactCtrl.text.trim(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        ),
      ),
    );
  }

  void _openPreview(DocDocument item) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DocumentPreviewPage(
          document: item,
          onIssue: item.isDraft
              ? () => widget.controller.issueDocument(item)
              : null,
        ),
      ),
    );
  }
}

class _TemplatesTab extends StatelessWidget {
  const _TemplatesTab({required this.state, required this.onRetry});

  final I2AsyncState<List<DocTemplate>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<DocTemplate>>(
      state: state,
      onRetry: onRetry,
      builder: (items) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                title: Text(item.name),
                subtitle: Text(
                  item.bodyText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: Icon(
                  item.kind == 'receipt'
                      ? Icons.receipt_long_outlined
                      : Icons.description_outlined,
                ),
              ),
            );
          },
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
    required this.onIssue,
    required this.onOpen,
  });

  final I2AsyncState<List<DocDocument>> state;
  final String emptyHint;
  final VoidCallback onRetry;
  final Future<void> Function(DocDocument item) onIssue;
  final void Function(DocDocument item) onOpen;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<DocDocument>>(
      state: state,
      onRetry: onRetry,
      emptyBuilder: (_) => I2StateMessage(
        icon: Icons.inbox_outlined,
        message: emptyHint,
        onRetry: onRetry,
      ),
      builder: (items) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                key: Key('doc-item-${item.id}'),
                title: Text(item.title),
                subtitle: Text(
                  [
                    item.statusLabel,
                    if (item.contactName != null &&
                        item.contactName!.isNotEmpty)
                      item.contactName!,
                    if (item.amountLabel != null) item.amountLabel!,
                  ].join(' · '),
                ),
                leading: Icon(
                  item.kind == 'receipt'
                      ? Icons.receipt_long
                      : Icons.article_outlined,
                ),
                trailing: item.isDraft
                    ? TextButton(
                        key: Key('doc-issue-${item.id}'),
                        onPressed: () => onIssue(item),
                        child: const Text('签发'),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: () => onOpen(item),
              ),
            );
          },
        );
      },
    );
  }
}

class DocumentPreviewPage extends StatelessWidget {
  const DocumentPreviewPage({
    super.key,
    required this.document,
    this.onIssue,
  });

  final DocDocument document;
  final Future<bool> Function()? onIssue;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: document.bodyFilled));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('正文已复制，可粘贴分享')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        actions: [
          IconButton(
            key: const Key('doc-copy-share'),
            tooltip: '复制分享',
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_all_outlined),
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
              Chip(label: Text(document.kindLabel)),
              Chip(label: Text(document.statusLabel)),
              if (document.amountLabel != null)
                Chip(label: Text(document.amountLabel!)),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                document.bodyFilled,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PDF 导出后续接入；当前支持预览与复制分享。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (onIssue != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('doc-preview-issue'),
              onPressed: () async {
                final ok = await onIssue!();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? '已签发' : '签发失败'),
                  ),
                );
                if (ok) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('签发'),
            ),
          ],
        ],
      ),
    );
  }
}
