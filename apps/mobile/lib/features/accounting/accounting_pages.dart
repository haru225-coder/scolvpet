import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'accounting_controller.dart';
import 'accounting_models.dart';

/// Accounting hub: ledger / categories / monthly summary (T-P1-04).
class AccountingHubPage extends StatefulWidget {
  const AccountingHubPage({
    super.key,
    required this.controller,
    this.canWrite = true,
  });

  final AccountingController controller;
  final bool canWrite;

  @override
  State<AccountingHubPage> createState() => _AccountingHubPageState();
}

class _AccountingHubPageState extends State<AccountingHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(_handleTabChanged);
    widget.controller.refreshAll(bootstrapCategories: widget.canWrite);
  }

  @override
  void dispose() {
    _tabs.removeListener(_handleTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (_selectedTab == _tabs.index || !mounted) return;
    setState(() => _selectedTab = _tabs.index);
  }

  Future<void> _refreshAll() =>
      widget.controller.refreshAll(bootstrapCategories: widget.canWrite);

  String get _fabLabel => _selectedTab == 1 ? '新建分类' : '记一笔';

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
        final saving = widget.controller.isBusy;
        final refreshing = widget.controller.isRefreshing;
        final busy = saving || refreshing;
        return Scaffold(
          appBar: AppBar(
            title: const Text('财务收支'),
            actions: [
              IconButton(
                key: const Key('acct-refresh'),
                onPressed: busy ? null : _refreshAll,
                icon: busy
                    ? const CupertinoActivityIndicator()
                    : const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          floatingActionButton: widget.canWrite
              ? FloatingActionButton.extended(
                  key: const Key('acct-fab'),
                  onPressed: busy
                      ? null
                      : () async {
                          if (_selectedTab == 1) {
                            await _createCategory();
                          } else {
                            await _createRecord();
                          }
                        },
                  backgroundColor: ScolvPalette.of(context).accent,
                  foregroundColor: ScolvPalette.of(context).groupedBackground,
                  elevation: 0,
                  icon: busy
                      ? const CupertinoActivityIndicator()
                      : const Icon(CupertinoIcons.add),
                  label: Text(
                    refreshing ? '正在载入' : (saving ? '正在保存' : _fabLabel),
                  ),
                )
              : null,
          body: Column(
            children: [
              if (widget.controller.actionState.status == I2AsyncStatus.error)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IosMetrics.pagePadding,
                    12,
                    IosMetrics.pagePadding,
                    0,
                  ),
                  child: IosBanner(
                    icon: CupertinoIcons.exclamationmark_triangle,
                    color: IosColors.systemRed,
                    text: widget.controller.actionState.message ?? '保存未完成',
                  ),
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
                    text: '当前角色可查看流水与汇总，记账和分类维护已设为只读。',
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
                      label: '流水',
                      key: Key('acct-tab-records'),
                    ),
                    IosSegmentTab(
                      value: 1,
                      label: '分类',
                      key: Key('acct-tab-categories'),
                    ),
                    IosSegmentTab(
                      value: 2,
                      label: '本月',
                      key: Key('acct-tab-summary'),
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
                    _RecordsTab(
                      state: widget.controller.recordsState,
                      onRetry: widget.controller.refreshRecords,
                      canWrite: widget.canWrite,
                    ),
                    _CategoriesTab(
                      state: widget.controller.categoriesState,
                      onRetry: () => widget.controller.refreshCategories(
                        bootstrapDefaults: widget.canWrite,
                      ),
                      canWrite: widget.canWrite,
                    ),
                    _SummaryTab(
                      state: widget.controller.summaryState,
                      onRetry: widget.controller.refreshSummary,
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

  Future<void> _createCategory() async {
    var entryType = 'expense';
    final nameCtrl = TextEditingController();
    String? nameError;
    final draft = await showCupertinoDialog<AccountingCategoryDraft>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return CupertinoAlertDialog(
            title: const Text('新建分类'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IosSegmentedControl<String>(
                  tabs: const [
                    IosSegmentTab(value: 'income', label: '收入'),
                    IosSegmentTab(value: 'expense', label: '支出'),
                  ],
                  selected: entryType,
                  onSelect: (value) {
                    entryType = value;
                    setLocal(() {});
                  },
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  key: const Key('acct-category-name'),
                  controller: nameCtrl,
                  textInputAction: TextInputAction.done,
                  placeholder: '名称',
                  onChanged: (_) {
                    if (nameError == null) return;
                    nameError = null;
                    setLocal(() {});
                  },
                ),
                if (nameError != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      nameError!,
                      key: const Key('acct-category-error'),
                      style: const TextStyle(
                        color: IosColors.systemRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              CupertinoDialogAction(
                key: const Key('acct-category-submit'),
                isDefaultAction: true,
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    nameError = '请输入分类名称';
                    setLocal(() {});
                    return;
                  }
                  Navigator.pop(
                    context,
                    AccountingCategoryDraft(entryType: entryType, name: name),
                  );
                },
                child: const Text('创建'),
              ),
            ],
          );
        },
      ),
    );
    nameCtrl.dispose();
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createCategory(draft));
  }

  Future<void> _createRecord() async {
    final draft = await showModalBottomSheet<AccountingRecordDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AccountingRecordFormSheet(controller: widget.controller),
    );
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createRecord(draft));
  }
}

class _AccountingRecordFormSheet extends StatefulWidget {
  const _AccountingRecordFormSheet({required this.controller});

  final AccountingController controller;

  @override
  State<_AccountingRecordFormSheet> createState() =>
      _AccountingRecordFormSheetState();
}

class _AccountingRecordFormSheetState
    extends State<_AccountingRecordFormSheet> {
  String _entryType = 'expense';
  String? _categoryId;
  String? _contactId;
  DateTime _occurredAt = DateTime.now();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String? _titleError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _selectDefaultCategory();
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  List<AccountingCategory> get _categories =>
      widget.controller.categoriesState.data ?? const <AccountingCategory>[];

  List<AccountingCategory> get _filteredCategories =>
      _categories.where((item) => item.entryType == _entryType).toList();

  String? get _effectiveCategoryId {
    final filtered = _filteredCategories;
    if (_categoryId != null && filtered.any((c) => c.id == _categoryId)) {
      return _categoryId;
    }
    return filtered.isEmpty ? null : filtered.first.id;
  }

  void _selectDefaultCategory() {
    final filtered = _filteredCategories;
    if (_categoryId != null && filtered.any((c) => c.id == _categoryId)) {
      return;
    }
    _categoryId = filtered.isEmpty ? null : filtered.first.id;
  }

  void _setEntryType(String value) {
    setState(() {
      _entryType = value;
      _selectDefaultCategory();
    });
  }

  Future<void> _pickOccurredAt() async {
    var picked = _occurredAt;
    final maximum = DateTime.now().add(const Duration(minutes: 1));
    if (picked.isAfter(maximum)) picked = maximum;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) {
        final palette = ScolvPalette.of(ctx);
        return Container(
          height: 330,
          color: palette.secondaryGroupedBackground,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('取消'),
                      ),
                      CupertinoButton(
                        onPressed: () {
                          setState(() => _occurredAt = picked);
                          Navigator.pop(ctx);
                        },
                        child: const Text('完成'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    key: const Key('acct-record-date-picker'),
                    mode: CupertinoDatePickerMode.dateAndTime,
                    initialDateTime: picked,
                    minimumDate: DateTime.now().subtract(
                      const Duration(days: 3650),
                    ),
                    maximumDate: maximum,
                    use24hFormat: true,
                    onDateTimeChanged: (value) => picked = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    final title = _title.text.trim();
    final yuan = double.tryParse(_amount.text.trim());
    setState(() {
      _titleError = title.isEmpty ? '请输入流水标题' : null;
      _amountError = yuan == null || yuan <= 0 ? '请输入大于 0 的有效金额' : null;
    });
    if (_titleError != null || _amountError != null || yuan == null) return;

    final contacts =
        widget.controller.contactsState.data ??
        const <AccountingContactOption>[];
    final contactId = contacts.any((item) => item.id == _contactId)
        ? _contactId
        : null;
    Navigator.of(context).pop(
      AccountingRecordDraft(
        entryType: _entryType,
        amountCents: (yuan * 100).round(),
        title: title,
        categoryId: _effectiveCategoryId,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        contactId: contactId,
        occurredAt: _occurredAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final palette = ScolvPalette.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final filtered = _filteredCategories;
        final contacts =
            widget.controller.contactsState.data ??
            const <AccountingContactOption>[];
        final selectedContact = contacts.any((item) => item.id == _contactId)
            ? _contactId
            : null;
        return KeyboardDismissOnTap(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '记一笔',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '补齐分类、客户和发生时间，后续对账会更清楚。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  IosSegmentedControl<String>(
                    key: const Key('acct-record-type'),
                    tabs: const [
                      IosSegmentTab(value: 'income', label: '收入'),
                      IosSegmentTab(value: 'expense', label: '支出'),
                    ],
                    selected: _entryType,
                    onSelect: _setEntryType,
                  ),
                  const SizedBox(height: 18),
                  const IosSectionHeader('基本信息'),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: palette.secondaryGroupedBackground,
                      borderRadius: BorderRadius.circular(
                        IosMetrics.continuousRadius,
                      ),
                      border: Border.all(
                        color: palette.separator,
                        width: IosMetrics.hairline,
                      ),
                    ),
                    child: Column(
                      children: [
                        CupertinoTextField(
                          key: const Key('acct-record-title'),
                          controller: _title,
                          textInputAction: TextInputAction.next,
                          placeholder: '标题，例如“采购垫料”',
                          onChanged: (_) {
                            if (_titleError == null) return;
                            setState(() => _titleError = null);
                          },
                        ),
                        if (_titleError != null)
                          _InlineFormError(
                            key: const Key('acct-record-title-error'),
                            message: _titleError!,
                          ),
                        const SizedBox(height: 12),
                        CupertinoTextField(
                          key: const Key('acct-record-amount'),
                          controller: _amount,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: const [_YuanInputFormatter()],
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              '¥',
                              style: TextStyle(
                                color: palette.secondaryLabel,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          placeholder: '0.00',
                          onChanged: (_) {
                            if (_amountError == null) return;
                            setState(() => _amountError = null);
                          },
                        ),
                        if (_amountError != null)
                          _InlineFormError(
                            key: const Key('acct-record-amount-error'),
                            message: _amountError!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  IosGroupedSection(
                    margin: EdgeInsets.zero,
                    children: [
                      IosListTile(
                        key: const Key('acct-record-occurred-at'),
                        leading: const IosGlyph(icon: CupertinoIcons.calendar),
                        title: '发生时间',
                        subtitle: _dateTimeLabel(_occurredAt),
                        onTap: _pickOccurredAt,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                        child: IosPickerField<String?>(
                          key: const Key('acct-record-category'),
                          label: '分类',
                          items: [
                            const IosPickerItem(value: null, label: '未分类'),
                            for (final item in filtered)
                              IosPickerItem(value: item.id, label: item.name),
                          ],
                          selected: _effectiveCategoryId,
                          hint: '未分类',
                          onSelected: (value) {
                            setState(() => _categoryId = value);
                          },
                        ),
                      ),
                      _buildContactField(selectedContact, contacts),
                    ],
                  ),
                  if (filtered.isEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '当前收支类型暂无分类，本笔会按“未分类”保存。',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 18),
                  const IosSectionHeader('备注'),
                  CupertinoTextField(
                    key: const Key('acct-record-notes'),
                    controller: _notes,
                    minLines: 2,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    placeholder: '选填，可记录付款方式、用途或票据编号',
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('acct-record-submit'),
                    onPressed: _submit,
                    icon: const Icon(CupertinoIcons.checkmark_circle_fill),
                    label: const Text('保存流水'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactField(
    String? selectedContact,
    List<AccountingContactOption> contacts,
  ) {
    final state = widget.controller.contactsState;
    if (state.status == I2AsyncStatus.loading ||
        state.status == I2AsyncStatus.idle) {
      return const IosListTile(
        key: Key('acct-record-contact-loading'),
        leading: IosGlyph(icon: CupertinoIcons.person_2),
        title: '关联客户',
        subtitle: '正在读取客户列表',
        trailing: CupertinoActivityIndicator(),
        showChevron: false,
      );
    }
    if (state.status == I2AsyncStatus.error) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: IosBanner(
          icon: CupertinoIcons.exclamationmark_circle,
          color: IosColors.systemOrange,
          text: '客户列表暂未加载，本笔仍可先不关联客户。',
          actionLabel: '重试',
          onAction: widget.controller.refreshContacts,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: IosPickerField<String?>(
        key: const Key('acct-record-contact'),
        label: '关联客户',
        items: [
          const IosPickerItem(value: null, label: '不关联客户'),
          for (final item in contacts)
            IosPickerItem(value: item.id, label: item.name),
        ],
        selected: selectedContact,
        hint: contacts.isEmpty ? '暂无客户' : '不关联客户',
        enabled: contacts.isNotEmpty,
        onSelected: (value) => setState(() => _contactId = value),
      ),
    );
  }
}

class _YuanInputFormatter extends TextInputFormatter {
  const _YuanInputFormatter();

  static final RegExp _pattern = RegExp(r'^\d{0,9}(?:\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}

class _InlineFormError extends StatelessWidget {
  const _InlineFormError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          message,
          style: const TextStyle(color: IosColors.systemRed, fontSize: 12),
        ),
      ),
    );
  }
}

class _AccountingEmptyState extends StatelessWidget {
  const _AccountingEmptyState({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IosGlyph(icon: icon, size: 46),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.secondaryLabel,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _dateTimeLabel(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

class _RecordsTab extends StatelessWidget {
  const _RecordsTab({
    required this.state,
    required this.onRetry,
    required this.canWrite,
  });

  final I2AsyncState<List<AccountingRecord>> state;
  final VoidCallback onRetry;
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<AccountingRecord>>(
      state: state,
      onRetry: onRetry,
      emptyBuilder: (context) => _AccountingEmptyState(
        icon: CupertinoIcons.doc_text,
        title: '暂无流水',
        detail: canWrite ? '点右下角“记一笔”，开始记录第一笔收支。' : '当前账本还没有收支记录。',
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
                    key: Key('acct-record-${item.id}'),
                    leading: IosGlyph(
                      icon: item.isIncome
                          ? CupertinoIcons.arrow_down_left
                          : CupertinoIcons.arrow_up_right,
                      color: item.isIncome
                          ? IosColors.systemGreen
                          : IosColors.systemRed,
                    ),
                    title: item.title,
                    subtitle: [
                      item.entryTypeLabel,
                      if (item.categoryName != null &&
                          item.categoryName!.isNotEmpty)
                        item.categoryName!,
                      if (item.contactName != null &&
                          item.contactName!.isNotEmpty)
                        '客户 ${item.contactName}',
                      item.occurredAt.toLocal().toIso8601String().substring(
                        0,
                        10,
                      ),
                    ].join(' · '),
                    trailing: Text(
                      item.amountLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: item.isIncome
                            ? IosColors.systemGreen
                            : IosColors.systemRed,
                      ),
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

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab({
    required this.state,
    required this.onRetry,
    required this.canWrite,
  });

  final I2AsyncState<List<AccountingCategory>> state;
  final VoidCallback onRetry;
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<AccountingCategory>>(
      state: state,
      onRetry: onRetry,
      emptyBuilder: (context) => _AccountingEmptyState(
        icon: CupertinoIcons.tag,
        title: '暂无分类',
        detail: canWrite ? '点右下角“新建分类”，建立自己的收支口径。' : '当前账本还没有可用分类。',
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
                    key: Key('acct-category-${item.id}'),
                    leading: IosGlyph(
                      icon: item.entryType == 'income'
                          ? CupertinoIcons.money_yen_circle_fill
                          : CupertinoIcons.bag_fill,
                      color: item.entryType == 'income'
                          ? IosColors.systemGreen
                          : IosColors.systemOrange,
                    ),
                    title: item.name,
                    subtitle: item.entryTypeLabel,
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
        final p = ScolvPalette.of(context);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          children: [
            Container(
              decoration: BoxDecoration(
                color: p.secondaryGroupedBackground,
                borderRadius: BorderRadius.circular(
                  IosMetrics.continuousRadius,
                ),
              ),
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
                      color: IosColors.systemGreen,
                    ),
                    _SummaryRow(
                      label: '支出',
                      value: summary.expenseLabel,
                      color: IosColors.systemRed,
                    ),
                    const Divider(),
                    _SummaryRow(
                      label: '净额',
                      value: summary.netLabel,
                      color: summary.netCents >= 0
                          ? IosColors.systemGreen
                          : IosColors.systemRed,
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
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              IosGroupedSection(
                margin: EdgeInsets.zero,
                children: [
                  for (final item in summary.byCategory)
                    IosListTile(
                      key: Key(
                        'acct-summary-category-${item.categoryId ?? item.categoryName}',
                      ),
                      title: item.categoryName,
                      subtitle:
                          '${item.entryType == 'income' ? '收入' : '支出'} · ${item.count} 笔',
                      trailing: Text(item.amountLabel),
                      showChevron: false,
                    ),
                ],
              ),
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
