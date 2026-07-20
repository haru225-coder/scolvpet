import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'crm_controller.dart';
import 'crm_models.dart';

/// CRM hub: contacts / reservations / handovers (T-P1-02).
class CrmHubPage extends StatefulWidget {
  const CrmHubPage({
    super.key,
    required this.controller,
    this.hamsters = const <I2Hamster>[],
    this.onOpenDocuments,
    this.canWrite = true,
  });

  final CrmController controller;
  final List<I2Hamster> hamsters;
  final void Function(
    CrmHandover handover,
    CrmContact? contact,
    I2Hamster? hamster,
  )?
  onOpenDocuments;
  final bool canWrite;

  @override
  State<CrmHubPage> createState() => _CrmHubPageState();
}

class _CrmHubPageState extends State<CrmHubPage>
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
      showIosMessage(context, message);
    }
    if (ok) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final contacts =
            widget.controller.contactsState.data ?? const <CrmContact>[];
        final reservations =
            widget.controller.reservationsState.data ??
            const <CrmReservation>[];
        final handovers =
            widget.controller.handoversState.data ?? const <CrmHandover>[];
        final openReservations = reservations
            .where((item) => item.isOpen)
            .length;
        final pendingHandovers = handovers.where((item) => item.isOpen).length;
        return Scaffold(
          appBar: AppBar(
            title: const Text('客户与交付'),
            actions: [
              IconButton(
                key: const Key('crm-refresh'),
                onPressed: widget.controller.refreshAll,
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          floatingActionButton: widget.canWrite
              ? FloatingActionButton.extended(
                  key: const Key('crm-fab'),
                  onPressed: () async {
                    switch (_tabs.index) {
                      case 0:
                        await _createContact();
                      case 1:
                        await _createReservation();
                      default:
                        await _createHandover();
                    }
                  },
                  backgroundColor: ScolvPalette.of(context).accent,
                  foregroundColor: ScolvPalette.of(context).groupedBackground,
                  elevation: 0,
                  icon: const Icon(CupertinoIcons.add),
                  label: Text(switch (_tabs.index) {
                    0 => '新建客户',
                    1 => '新建预订',
                    _ => '新建交付',
                  }),
                )
              : null,
          body: Column(
            children: [
              IosModuleIntro(
                icon: CupertinoIcons.person_2_square_stack_fill,
                title: '客户成交与交付',
                description:
                    '公开主页客户预订会进入本列表；也可后台登记。确认后可继续交付与合同。',
                metrics: [
                  IosModuleMetric(label: '客户', value: '${contacts.length}'),
                  IosModuleMetric(
                    label: '进行中预订',
                    value: '$openReservations',
                    color: IosColors.systemOrange,
                  ),
                  IosModuleMetric(
                    label: '待交付',
                    value: '$pendingHandovers',
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
                    text: '当前角色可查看客户、预订与交付记录，新建和状态推进已设为只读。',
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
                    IosSegmentTab(value: 0, label: '客户'),
                    IosSegmentTab(value: 1, label: '预订'),
                    IosSegmentTab(value: 2, label: '交付'),
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
                    _ContactsTab(controller: widget.controller),
                    _ReservationsTab(
                      controller: widget.controller,
                      hamsters: widget.hamsters,
                      onConfirm: (item) => _snack(
                        () => widget.controller.confirmReservation(item),
                      ),
                      onCancel: (item) => _snack(
                        () => widget.controller.cancelReservation(item),
                      ),
                      canWrite: widget.canWrite,
                    ),
                    _HandoversTab(
                      controller: widget.controller,
                      hamsters: widget.hamsters,
                      onComplete: (item) => _snack(
                        () => widget.controller.completeHandover(item),
                      ),
                      onOpenDocuments: widget.onOpenDocuments,
                      canWrite: widget.canWrite,
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

  Future<void> _createContact() async {
    final draft = await showModalBottomSheet<CrmContactDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ContactFormSheet(),
    );
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createContact(draft));
  }

  Future<void> _createReservation() async {
    final contacts =
        widget.controller.contactsState.data ?? const <CrmContact>[];
    if (contacts.isEmpty) {
      showIosMessage(context, '请先创建客户');
      return;
    }
    final draft = await showModalBottomSheet<CrmReservationDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _ReservationFormSheet(contacts: contacts, hamsters: widget.hamsters),
    );
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createReservation(draft));
  }

  Future<void> _createHandover() async {
    final contacts =
        widget.controller.contactsState.data ?? const <CrmContact>[];
    if (contacts.isEmpty) {
      showIosMessage(context, '请先创建客户');
      return;
    }
    final reservations =
        (widget.controller.reservationsState.data ?? const <CrmReservation>[])
            .where((r) => r.isOpen)
            .toList();
    final draft = await showModalBottomSheet<CrmHandoverDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HandoverFormSheet(
        contacts: contacts,
        reservations: reservations,
        hamsters: widget.hamsters,
      ),
    );
    if (draft == null || !mounted) return;
    await _snack(() => widget.controller.createHandover(draft));
  }
}

class _ContactsTab extends StatelessWidget {
  const _ContactsTab({required this.controller});
  final CrmController controller;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<CrmContact>>(
      state: controller.contactsState,
      onRetry: controller.refreshContacts,
      emptyBuilder: (context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const BearEmptyCard(
            title: '还没有客户记录',
            subtitle: '先记录称呼与联系方式，后续预订、交付和回执都会自动关联。',
            illustration: BearAssets.emptyList,
            mood: BearMood.sleepy,
          ),
        ),
      ),
      builder: (items) => ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
        children: [
          IosGroupedSection(
            children: [
              for (final c in items)
                IosListTile(
                  key: Key('crm-contact-${c.id}'),
                  leading: IosGlyph(
                    icon: CupertinoIcons.person_fill,
                    color: ScolvPalette.of(context).accent,
                  ),
                  title: c.name,
                  subtitle: [
                    if (c.phone != null && c.phone!.isNotEmpty) c.phone!,
                    if (c.wechat != null && c.wechat!.isNotEmpty)
                      '微信 ${c.wechat}',
                    if (c.notes != null && c.notes!.isNotEmpty) c.notes!,
                  ].join(' · '),
                  trailing: IosStatusBadge(
                    label: c.statusLabel,
                    color: _crmContactStatusColor(c.status),
                  ),
                  onTap: () => _showContactDetails(context, c),
                  showChevron: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReservationsTab extends StatelessWidget {
  const _ReservationsTab({
    required this.controller,
    required this.hamsters,
    required this.onConfirm,
    required this.onCancel,
    required this.canWrite,
  });

  final CrmController controller;
  final List<I2Hamster> hamsters;
  final ValueChanged<CrmReservation> onConfirm;
  final ValueChanged<CrmReservation> onCancel;
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<CrmReservation>>(
      state: controller.reservationsState,
      onRetry: controller.refreshReservations,
      emptyBuilder: (context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const BearEmptyCard(
            title: '还没有预订',
            subtitle: '客户可在公开主页提交预订；你也可在此为客户登记意向。',
            illustration: BearAssets.emptyList,
            mood: BearMood.sleepy,
          ),
        ),
      ),
      builder: (items) => ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
        children: [
          IosGroupedSection(
            children: [
              for (final r in items)
                IosListTile(
                  key: Key('crm-reservation-${r.id}'),
                  leading: const IosGlyph(
                    icon: CupertinoIcons.calendar,
                    color: IosColors.systemOrange,
                  ),
                  title: r.title,
                  subtitle:
                      [
                            r.contactName ?? '客户',
                            _hamsterName(hamsters, r.hamsterId) ??
                                r.hamsterName,
                            r.reservedLabel,
                            r.notes,
                          ]
                          .whereType<String>()
                          .where((value) => value.isNotEmpty)
                          .join(' · '),
                  trailing: r.isOpen && canWrite
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IosStatusBadge(
                              label: r.statusLabel,
                              color: _crmReservationStatusColor(r.status),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'confirm') onConfirm(r);
                                if (value == 'cancel') onCancel(r);
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'confirm',
                                  child: Text('确认预订'),
                                ),
                                PopupMenuItem(
                                  value: 'cancel',
                                  child: Text('取消预订'),
                                ),
                              ],
                            ),
                          ],
                        )
                      : IosStatusBadge(
                          label: r.statusLabel,
                          color: _crmReservationStatusColor(r.status),
                        ),
                  onTap: () => _showReservationDetails(
                    context,
                    r,
                    hamsterName:
                        _hamsterName(hamsters, r.hamsterId) ?? r.hamsterName,
                    onConfirm: onConfirm,
                    onCancel: onCancel,
                    canWrite: canWrite,
                  ),
                  showChevron: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HandoversTab extends StatelessWidget {
  const _HandoversTab({
    required this.controller,
    required this.hamsters,
    required this.onComplete,
    this.onOpenDocuments,
    required this.canWrite,
  });

  final CrmController controller;
  final List<I2Hamster> hamsters;
  final ValueChanged<CrmHandover> onComplete;
  final void Function(
    CrmHandover handover,
    CrmContact? contact,
    I2Hamster? hamster,
  )?
  onOpenDocuments;
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<CrmHandover>>(
      state: controller.handoversState,
      onRetry: controller.refreshHandovers,
      emptyBuilder: (context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const BearEmptyCard(
            title: '还没有交付安排',
            subtitle: '确认预订后安排交接时间，完成时可继续生成合同和收款回执。',
            illustration: BearAssets.emptyCare,
            mood: BearMood.happy,
          ),
        ),
      ),
      builder: (items) => ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
        children: [
          IosGroupedSection(
            children: [
              for (final h in items)
                IosListTile(
                  key: Key('crm-handover-${h.id}'),
                  leading: const IosGlyph(
                    icon: CupertinoIcons.cube_box_fill,
                    color: IosColors.systemGreen,
                  ),
                  title: h.contactName ?? '客户交付',
                  subtitle:
                      [
                            _hamsterName(hamsters, h.hamsterId) ??
                                h.hamsterName,
                            h.scheduledLabel,
                            h.notes,
                          ]
                          .whereType<String>()
                          .where((value) => value.isNotEmpty)
                          .join(' · '),
                  trailing: h.isOpen
                      ? IosStatusBadge(
                          label: h.statusLabel,
                          color: IosColors.systemOrange,
                        )
                      : IosStatusBadge(
                          label: h.statusLabel,
                          color: IosColors.systemGreen,
                        ),
                  onTap: () {
                    final contacts =
                        controller.contactsState.data ?? const <CrmContact>[];
                    final contact = _contactById(contacts, h.contactId);
                    final hamster = _hamsterById(hamsters, h.hamsterId);
                    _showHandoverDetails(
                      context,
                      h,
                      contact: contact,
                      hamster: hamster,
                      onComplete: onComplete,
                      onOpenDocuments: onOpenDocuments,
                      canWrite: canWrite,
                    );
                  },
                  showChevron: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactFormSheet extends StatefulWidget {
  const _ContactFormSheet();

  @override
  State<_ContactFormSheet> createState() => _ContactFormSheetState();
}

class _ContactFormSheetState extends State<_ContactFormSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _wechat = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _wechat.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '新建客户',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('crm-contact-name'),
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '姓名 *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('crm-contact-phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '手机',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _wechat,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '微信',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('crm-contact-submit'),
              onPressed: () {
                if (_name.text.trim().isEmpty) {
                  showIosMessage(context, '请填写客户姓名');
                  return;
                }
                if (_phone.text.trim().isEmpty && _wechat.text.trim().isEmpty) {
                  showIosMessage(context, '手机或微信至少填写一项');
                  return;
                }
                Navigator.pop(
                  context,
                  CrmContactDraft(
                    name: _name.text.trim(),
                    phone: _phone.text.trim().isEmpty
                        ? null
                        : _phone.text.trim(),
                    wechat: _wechat.text.trim().isEmpty
                        ? null
                        : _wechat.text.trim(),
                    notes: _notes.text.trim().isEmpty
                        ? null
                        : _notes.text.trim(),
                  ),
                );
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationFormSheet extends StatefulWidget {
  const _ReservationFormSheet({required this.contacts, required this.hamsters});
  final List<CrmContact> contacts;
  final List<I2Hamster> hamsters;

  @override
  State<_ReservationFormSheet> createState() => _ReservationFormSheetState();
}

class _ReservationFormSheetState extends State<_ReservationFormSheet> {
  late String _contactId;
  final _title = TextEditingController(text: '仓鼠预订');
  final _notes = TextEditingController();
  String? _hamsterId;

  @override
  void initState() {
    super.initState();
    _contactId = widget.contacts.first.id;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '新建预订',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            IosPickerField<String>(
              key: const Key('crm-reservation-contact'),
              label: '客户',
              selected: _contactId,
              items: [
                for (final c in widget.contacts)
                  IosPickerItem(value: c.id, label: c.name),
              ],
              onSelected: (v) {
                if (v != null) setState(() => _contactId = v);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('crm-reservation-title'),
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            IosPickerField<String?>(
              key: const Key('crm-reservation-hamster'),
              label: '意向仓鼠',
              selected: _hamsterId,
              items: [
                const IosPickerItem(value: null, label: '暂未确定'),
                for (final hamster in widget.hamsters)
                  IosPickerItem(value: hamster.id, label: hamster.displayName),
              ],
              onSelected: (value) => setState(() => _hamsterId = value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '客户偏好与约定（可选）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('crm-reservation-submit'),
              onPressed: () {
                Navigator.pop(
                  context,
                  CrmReservationDraft(
                    contactId: _contactId,
                    title: _title.text.trim().isEmpty
                        ? '仓鼠预订'
                        : _title.text.trim(),
                    hamsterId: _hamsterId,
                    notes: _notes.text.trim().isEmpty
                        ? null
                        : _notes.text.trim(),
                  ),
                );
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HandoverFormSheet extends StatefulWidget {
  const _HandoverFormSheet({
    required this.contacts,
    required this.reservations,
    required this.hamsters,
  });

  final List<CrmContact> contacts;
  final List<CrmReservation> reservations;
  final List<I2Hamster> hamsters;

  @override
  State<_HandoverFormSheet> createState() => _HandoverFormSheetState();
}

class _HandoverFormSheetState extends State<_HandoverFormSheet> {
  late String _contactId;
  String? _reservationId;
  String? _hamsterId;
  final _notes = TextEditingController();
  late DateTime _scheduledAt;

  @override
  void initState() {
    super.initState();
    _contactId = widget.contacts.first.id;
    final now = DateTime.now();
    _scheduledAt = DateTime(now.year, now.month, now.day + 1, 10);
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickSchedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final related = widget.reservations
        .where((r) => r.contactId == _contactId)
        .toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '新建交付',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            IosPickerField<String>(
              key: const Key('crm-handover-contact'),
              label: '客户',
              selected: _contactId,
              items: [
                for (final c in widget.contacts)
                  IosPickerItem(value: c.id, label: c.name),
              ],
              onSelected: (v) {
                if (v != null) {
                  setState(() {
                    _contactId = v;
                    _reservationId = null;
                    _hamsterId = null;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            IosPickerField<String?>(
              key: const Key('crm-handover-reservation'),
              label: '关联预订（可选）',
              selected: _reservationId,
              items: [
                const IosPickerItem(value: null, label: '无'),
                for (final r in related)
                  IosPickerItem(value: r.id, label: r.title),
              ],
              onSelected: (v) {
                setState(() {
                  _reservationId = v;
                  if (v != null) {
                    _hamsterId = related
                        .firstWhere((item) => item.id == v)
                        .hamsterId;
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            IosPickerField<String?>(
              key: const Key('crm-handover-hamster'),
              label: '交付仓鼠',
              selected: _hamsterId,
              items: [
                const IosPickerItem(value: null, label: '不关联具体仓鼠'),
                for (final hamster in widget.hamsters)
                  IosPickerItem(value: hamster.id, label: hamster.displayName),
              ],
              onSelected: (value) => setState(() => _hamsterId = value),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('crm-handover-schedule'),
              onPressed: _pickSchedule,
              icon: const Icon(CupertinoIcons.calendar_badge_plus),
              label: Text('交付时间  ${_localDateTimeLabel(_scheduledAt)}'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: '交接地点、用品和注意事项（可选）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('crm-handover-submit'),
              onPressed: () {
                Navigator.pop(
                  context,
                  CrmHandoverDraft(
                    contactId: _contactId,
                    reservationId: _reservationId,
                    hamsterId: _hamsterId,
                    scheduledAt: _scheduledAt,
                    notes: _notes.text.trim().isEmpty
                        ? null
                        : _notes.text.trim(),
                  ),
                );
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showContactDetails(
  BuildContext context,
  CrmContact contact,
) async {
  final palette = ScolvPalette.of(context);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const IosGlyph(
                  icon: CupertinoIcons.person_fill,
                  color: IosColors.systemBlue,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    contact.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IosStatusBadge(
                  label: contact.statusLabel,
                  color: _crmContactStatusColor(contact.status),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _CrmDetailLine(
              label: '手机',
              value: contact.phone?.trim().isNotEmpty == true
                  ? contact.phone!
                  : '未填写',
            ),
            _CrmDetailLine(
              label: '微信',
              value: contact.wechat?.trim().isNotEmpty == true
                  ? contact.wechat!
                  : '未填写',
            ),
            if (contact.notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(
                '客户备注',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: palette.secondaryLabel),
              ),
              const SizedBox(height: 4),
              Text(
                contact.notes!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Future<void> _showReservationDetails(
  BuildContext context,
  CrmReservation reservation, {
  String? hamsterName,
  required ValueChanged<CrmReservation> onConfirm,
  required ValueChanged<CrmReservation> onCancel,
  required bool canWrite,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const IosGlyph(
                  icon: CupertinoIcons.calendar,
                  color: IosColors.systemOrange,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reservation.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IosStatusBadge(
                  label: reservation.statusLabel,
                  color: _crmReservationStatusColor(reservation.status),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _CrmDetailLine(
              label: '客户',
              value: reservation.contactName ?? '未命名客户',
            ),
            _CrmDetailLine(label: '仓鼠', value: hamsterName ?? '暂未确定'),
            _CrmDetailLine(
              label: '登记时间',
              value: _localDateTimeLabel(reservation.reservedAt),
            ),
            if (reservation.notes?.trim().isNotEmpty == true)
              _CrmDetailLine(label: '约定', value: reservation.notes!),
            if (reservation.isOpen && canWrite) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm(reservation);
                },
                icon: const Icon(CupertinoIcons.checkmark_circle),
                label: const Text('确认预订'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onCancel(reservation);
                },
                style: TextButton.styleFrom(
                  foregroundColor: IosColors.systemRed,
                ),
                child: const Text('取消预订'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Future<void> _showHandoverDetails(
  BuildContext context,
  CrmHandover handover, {
  CrmContact? contact,
  I2Hamster? hamster,
  required ValueChanged<CrmHandover> onComplete,
  void Function(CrmHandover handover, CrmContact? contact, I2Hamster? hamster)?
  onOpenDocuments,
  required bool canWrite,
}) async {
  const checks = <String>[
    '核对仓鼠身份与档案',
    '说明健康观察和近期记录',
    '确认饮食、垫料与用品',
    '核对客户联系方式与交接信息',
  ];
  final completed = <int>{};
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocal) {
        final allChecked = completed.length == checks.length;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const IosGlyph(
                      icon: CupertinoIcons.cube_box_fill,
                      color: IosColors.systemGreen,
                      size: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            handover.contactName ?? contact?.name ?? '客户交付',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            hamster?.displayName ??
                                handover.hamsterName ??
                                '未关联具体仓鼠',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: ScolvPalette.of(
                                    context,
                                  ).secondaryLabel,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IosStatusBadge(
                      label: handover.statusLabel,
                      color: handover.isOpen
                          ? IosColors.systemOrange
                          : IosColors.systemGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _CrmDetailLine(label: '计划时间', value: handover.scheduledLabel),
                if (handover.completedLabel != null)
                  _CrmDetailLine(
                    label: '完成时间',
                    value: handover.completedLabel!,
                  ),
                if (handover.notes?.trim().isNotEmpty == true)
                  _CrmDetailLine(label: '交接说明', value: handover.notes!),
                const SizedBox(height: 18),
                Text(
                  '交接检查',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                for (var index = 0; index < checks.length; index++)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: handover.isOpen ? completed.contains(index) : true,
                    onChanged: handover.isOpen && canWrite
                        ? (value) {
                            setLocal(() {
                              if (value == true) {
                                completed.add(index);
                              } else {
                                completed.remove(index);
                              }
                            });
                          }
                        : null,
                    title: Text(checks[index]),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                if (handover.isOpen && canWrite) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    key: Key('crm-handover-complete-${handover.id}'),
                    onPressed: allChecked
                        ? () {
                            Navigator.pop(context);
                            onComplete(handover);
                          }
                        : null,
                    icon: const Icon(CupertinoIcons.checkmark_seal_fill),
                    label: Text(allChecked ? '确认完成交付' : '完成全部检查后确认'),
                  ),
                ],
                if (onOpenDocuments != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onOpenDocuments(handover, contact, hamster);
                    },
                    icon: const Icon(CupertinoIcons.doc_text_fill),
                    label: const Text('合同与回执'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _CrmDetailLine extends StatelessWidget {
  const _CrmDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.secondaryLabel),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

CrmContact? _contactById(List<CrmContact> contacts, String id) {
  for (final contact in contacts) {
    if (contact.id == id) return contact;
  }
  return null;
}

I2Hamster? _hamsterById(List<I2Hamster> hamsters, String? id) {
  if (id == null) return null;
  for (final hamster in hamsters) {
    if (hamster.id == id) return hamster;
  }
  return null;
}

String? _hamsterName(List<I2Hamster> hamsters, String? id) =>
    _hamsterById(hamsters, id)?.displayName;

String _localDateTimeLabel(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

Color _crmContactStatusColor(String status) => switch (status) {
  'active' => IosColors.systemGreen,
  'lead' => IosColors.systemBlue,
  'archived' => IosColors.systemGray,
  _ => IosColors.systemGray,
};

Color _crmReservationStatusColor(String status) => switch (status) {
  'held' => IosColors.systemOrange,
  'confirmed' => IosColors.systemBlue,
  'handed_over' => IosColors.systemGreen,
  'cancelled' => IosColors.systemRed,
  _ => IosColors.systemGray,
};
