import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'accounting_controller.dart';
import 'accounting_models.dart';

/// Accounting hub: ledger / categories / monthly summary (T-P1-04).
class AccountingHubPage extends StatefulWidget {
  const AccountingHubPage({super.key, required this.controller});

  final AccountingController controller;

  @override
  State<AccountingHubPage> createState() => _AccountingHubPageState();
}

class _AccountingHubPageState extends State<AccountingHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
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
            title: const Text('财务收支'),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(key: Key('acct-tab-records'), text: '流水'),
                Tab(key: Key('acct-tab-categories'), text: '分类'),
                Tab(key: Key('acct-tab-summary'), text: '本月'),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('acct-refresh'),
                onPressed: widget.controller.refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('acct-fab'),
            onPressed: () async {
              if (_tabs.index == 1) {
                await _createCategory();
              } else {
                await _createRecord();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(_tabs.index == 1 ? '新建分类' : '记一笔'),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _RecordsTab(
                state: widget.controller.recordsState,
                onRetry: widget.controller.refreshRecords,
              ),
              _CategoriesTab(
                state: widget.controller.categoriesState,
                onRetry: widget.controller.refreshCategories,
              ),
              _SummaryTab(
                state: widget.controller.summaryState,
                onRetry: widget.controller.refreshSummary,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createCategory() async {
    var entryType = 'expense';
    final nameCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('新建分类'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'income', label: Text('收入')),
                    ButtonSegment(value: 'expense', label: Text('支出')),
                  ],
                  selected: {entryType},
                  onSelectionChanged: (value) {
                    entryType = value.first;
                    setLocal(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('acct-category-name'),
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '名称',
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
                key: const Key('acct-category-submit'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('创建'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || !mounted) return;
    await _snack(
      () => widget.controller.createCategory(
        AccountingCategoryDraft(
          entryType: entryType,
          name: nameCtrl.text,
        ),
      ),
    );
  }

  Future<void> _createRecord() async {
    final categories =
        widget.controller.categoriesState.data ?? const <AccountingCategory>[];
    var entryType = 'expense';
    String? categoryId;
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          final filtered = categories
              .where((c) => c.entryType == entryType)
              .toList();
          if (categoryId != null &&
              !filtered.any((c) => c.id == categoryId)) {
            categoryId = null;
          }
          return AlertDialog(
            title: const Text('记一笔'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<String>(
                    key: const Key('acct-record-type'),
                    segments: const [
                      ButtonSegment(value: 'income', label: Text('收入')),
                      ButtonSegment(value: 'expense', label: Text('支出')),
                    ],
                    selected: {entryType},
                    onSelectionChanged: (value) {
                      entryType = value.first;
                      setLocal(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('acct-record-title'),
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: '标题',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('acct-record-amount'),
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
                  DropdownButtonFormField<String?>(
                    key: const Key('acct-record-category'),
                    initialValue: categoryId,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('未分类'),
                      ),
                      for (final c in filtered)
                        DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (value) {
                      categoryId = value;
                      setLocal(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: '分类',
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
                key: const Key('acct-record-submit'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || !mounted) return;
    final yuan = double.tryParse(amountCtrl.text.trim());
    if (yuan == null || yuan <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效金额')));
      return;
    }
    await _snack(
      () => widget.controller.createRecord(
        AccountingRecordDraft(
          entryType: entryType,
          amountCents: (yuan * 100).round(),
          title: titleCtrl.text,
          categoryId: categoryId,
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        ),
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({required this.state, required this.onRetry});

  final I2AsyncState<List<AccountingRecord>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<AccountingRecord>>(
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
                key: Key('acct-record-${item.id}'),
                leading: Icon(
                  item.isIncome
                      ? Icons.south_west
                      : Icons.north_east,
                  color: item.isIncome ? Colors.green : Colors.redAccent,
                ),
                title: Text(item.title),
                subtitle: Text(
                  [
                    item.entryTypeLabel,
                    if (item.categoryName != null &&
                        item.categoryName!.isNotEmpty)
                      item.categoryName!,
                    item.occurredAt.toLocal().toIso8601String().substring(0, 10),
                  ].join(' · '),
                ),
                trailing: Text(
                  item.amountLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: item.isIncome ? Colors.green : Colors.redAccent,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({required this.state, required this.onRetry});

  final I2AsyncState<List<AccountingCategory>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<AccountingCategory>>(
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
                key: Key('acct-category-${item.id}'),
                leading: Icon(
                  item.entryType == 'income'
                      ? Icons.savings_outlined
                      : Icons.shopping_bag_outlined,
                ),
                title: Text(item.name),
                subtitle: Text(item.entryTypeLabel),
              ),
            );
          },
        );
      },
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.state, required this.onRetry});

  final I2AsyncState<AccountingSummary> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<AccountingSummary>(
      state: state,
      onRetry: onRetry,
      builder: (summary) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本月汇总',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: '收入',
                      value: summary.incomeLabel,
                      color: Colors.green,
                    ),
                    _SummaryRow(
                      label: '支出',
                      value: summary.expenseLabel,
                      color: Colors.redAccent,
                    ),
                    const Divider(),
                    _SummaryRow(
                      label: '净额',
                      value: summary.netLabel,
                      color: summary.netCents >= 0
                          ? Colors.green
                          : Colors.redAccent,
                      bold: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '共 ${summary.recordCount} 笔',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            if (summary.byCategory.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '分类明细',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final item in summary.byCategory) ...[
                Card(
                  child: ListTile(
                    title: Text(item.categoryName),
                    subtitle: Text(
                      '${item.entryType == 'income' ? '收入' : '支出'} · ${item.count} 笔',
                    ),
                    trailing: Text(item.amountLabel),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
