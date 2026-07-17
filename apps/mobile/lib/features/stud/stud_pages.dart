import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'stud_controller.dart';
import 'stud_models.dart';

/// Cross-cattery stud network hub (T-P2-05).
class StudHubPage extends StatefulWidget {
  const StudHubPage({super.key, required this.controller});

  final StudController controller;

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
            title: const Text('跨舍借配'),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(key: Key('stud-tab-listings'), text: '挂牌市场'),
                Tab(key: Key('stud-tab-deals'), text: '我的履约'),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('stud-refresh'),
                onPressed: widget.controller.refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            key: const Key('stud-fab'),
            onPressed: () async {
              if (_tabs.index == 0) {
                await _createListing();
              } else {
                await _createDeal();
              }
            },
            icon: const Icon(Icons.add),
            label: Text(_tabs.index == 0 ? '发布挂牌' : '新建借配单'),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _ListingsTab(
                state: widget.controller.listingsState,
                onRetry: widget.controller.refreshListings,
                onUnpublish: (item) =>
                    _snack(() => widget.controller.unpublishListing(item)),
                onRequest: (item) => _createDeal(fromListing: item),
              ),
              _DealsTab(
                state: widget.controller.dealsState,
                onRetry: widget.controller.refreshDeals,
                onConfirm: (d) => _snack(() => widget.controller.confirm(d)),
                onStart: (d) => _snack(() => widget.controller.start(d)),
                onComplete: (d) => _snack(() => widget.controller.complete(d)),
                onCancel: (d) => _snack(() => widget.controller.cancel(d)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createListing() async {
    final sireCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final feeCtrl = TextEditingController(text: '0');
    final notesCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发布种公挂牌'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('stud-listing-sire'),
                controller: sireCtrl,
                decoration: const InputDecoration(
                  labelText: '种公名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('stud-listing-title'),
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: '标题（可空）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('stud-listing-fee'),
                controller: feeCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: '费用（元）',
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
            key: const Key('stud-listing-submit'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('发布'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final yuan = double.tryParse(feeCtrl.text.trim()) ?? 0;
    await _snack(
      () => widget.controller.createListing(
        StudListingDraft(
          sireLabel: sireCtrl.text,
          title: titleCtrl.text,
          feeCents: (yuan * 100).round(),
          notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        ),
      ),
    );
  }

  Future<void> _createDeal({StudListing? fromListing}) async {
    var side = fromListing == null ? 'requester' : 'requester';
    final partnerCtrl = TextEditingController(
      text: fromListing?.catteryName ?? '',
    );
    final mineCtrl = TextEditingController();
    final animalCtrl = TextEditingController(text: fromListing?.sireLabel ?? '');
    final feeCtrl = TextEditingController(
      text: fromListing == null
          ? '0'
          : (fromListing.feeCents / 100).toStringAsFixed(2),
    );
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: Text(fromListing == null ? '新建借配单' : '向挂牌申请借配'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (fromListing == null)
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'requester', label: Text('借入')),
                        ButtonSegment(value: 'provider', label: Text('出借')),
                      ],
                      selected: {side},
                      onSelectionChanged: (v) {
                        side = v.first;
                        setLocal(() {});
                      },
                    ),
                  if (fromListing == null) const SizedBox(height: 12),
                  TextField(
                    key: const Key('stud-deal-partner'),
                    controller: partnerCtrl,
                    decoration: const InputDecoration(
                      labelText: '对方熊舍',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('stud-deal-mine'),
                    controller: mineCtrl,
                    decoration: InputDecoration(
                      labelText: side == 'provider' ? '我的种公' : '我的母本',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: animalCtrl,
                    decoration: const InputDecoration(
                      labelText: '对方个体（可空）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: feeCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: '费用（元）',
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
                key: const Key('stud-deal-submit'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('创建'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || !mounted) return;
    final yuan = double.tryParse(feeCtrl.text.trim()) ?? 0;
    await _snack(
      () => widget.controller.createDeal(
        StudDealDraft(
          listingId: fromListing?.id,
          side: side,
          partnerCatteryName: partnerCtrl.text,
          myHamsterLabel: mineCtrl.text.trim().isEmpty
              ? null
              : mineCtrl.text.trim(),
          partnerAnimalLabel: animalCtrl.text.trim().isEmpty
              ? null
              : animalCtrl.text.trim(),
          feeCents: (yuan * 100).round(),
        ),
      ),
    );
  }
}

class _ListingsTab extends StatelessWidget {
  const _ListingsTab({
    required this.state,
    required this.onRetry,
    required this.onUnpublish,
    required this.onRequest,
  });

  final I2AsyncState<List<StudListing>> state;
  final VoidCallback onRetry;
  final Future<void> Function(StudListing item) onUnpublish;
  final Future<void> Function(StudListing item) onRequest;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<StudListing>>(
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
              child: ListTile(
                key: Key('stud-listing-${item.id}'),
                leading: Icon(
                  item.isMine ? Icons.home_outlined : Icons.storefront_outlined,
                ),
                title: Text(item.title),
                subtitle: Text(
                  [
                    item.sireLabel,
                    if (item.catteryName != null && item.catteryName!.isNotEmpty)
                      item.catteryName!,
                    item.feeLabel,
                    if (item.isMine) (item.published ? '已公开' : '已下架'),
                  ].join(' · '),
                ),
                trailing: item.isMine
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
              ),
            );
          },
        );
      },
    );
  }
}

class _DealsTab extends StatelessWidget {
  const _DealsTab({
    required this.state,
    required this.onRetry,
    required this.onConfirm,
    required this.onStart,
    required this.onComplete,
    required this.onCancel,
  });

  final I2AsyncState<List<StudDeal>> state;
  final VoidCallback onRetry;
  final Future<void> Function(StudDeal item) onConfirm;
  final Future<void> Function(StudDeal item) onStart;
  final Future<void> Function(StudDeal item) onComplete;
  final Future<void> Function(StudDeal item) onCancel;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<StudDeal>>(
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
                      key: Key('stud-deal-${item.id}'),
                      title: Text(
                        '${item.sideLabel} · ${item.partnerCatteryName}',
                      ),
                      subtitle: Text(
                        [
                          item.statusLabel,
                          item.feeLabel,
                          if (item.myHamsterLabel != null) item.myHamsterLabel!,
                          if (item.partnerAnimalLabel != null)
                            item.partnerAnimalLabel!,
                        ].join(' · '),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (item.canConfirm)
                          TextButton(
                            key: Key('stud-confirm-${item.id}'),
                            onPressed: () => onConfirm(item),
                            child: const Text('确认'),
                          ),
                        if (item.canStart)
                          TextButton(
                            key: Key('stud-start-${item.id}'),
                            onPressed: () => onStart(item),
                            child: const Text('开始'),
                          ),
                        if (item.canComplete)
                          TextButton(
                            key: Key('stud-complete-${item.id}'),
                            onPressed: () => onComplete(item),
                            child: const Text('完成'),
                          ),
                        if (item.canCancel)
                          TextButton(
                            key: Key('stud-cancel-${item.id}'),
                            onPressed: () => onCancel(item),
                            child: const Text('取消'),
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
}
