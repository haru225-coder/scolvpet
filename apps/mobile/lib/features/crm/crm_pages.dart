import 'package:flutter/material.dart';

import '../i2/i2_widgets.dart';
import 'crm_controller.dart';
import 'crm_models.dart';

/// CRM hub: contacts / reservations / handovers (T-P1-02).
class CrmHubPage extends StatefulWidget {
  const CrmHubPage({super.key, required this.controller});

  final CrmController controller;

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
            title: const Text('客户与交付'),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(key: Key('crm-tab-contacts'), text: '客户'),
                Tab(key: Key('crm-tab-reservations'), text: '预订'),
                Tab(key: Key('crm-tab-handovers'), text: '交付'),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('crm-refresh'),
                onPressed: widget.controller.refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
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
            icon: const Icon(Icons.add),
            label: Text(switch (_tabs.index) {
              0 => '新建客户',
              1 => '新建预订',
              _ => '新建交付',
            }),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _ContactsTab(
                controller: widget.controller,
              ),
              _ReservationsTab(
                controller: widget.controller,
                onConfirm: (item) =>
                    _snack(() => widget.controller.confirmReservation(item)),
                onCancel: (item) =>
                    _snack(() => widget.controller.cancelReservation(item)),
              ),
              _HandoversTab(
                controller: widget.controller,
                onComplete: (item) =>
                    _snack(() => widget.controller.completeHandover(item)),
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
    if (draft == null) return;
    await _snack(() => widget.controller.createContact(draft));
  }

  Future<void> _createReservation() async {
    final contacts = widget.controller.contactsState.data ?? const <CrmContact>[];
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先创建客户')));
      return;
    }
    final draft = await showModalBottomSheet<CrmReservationDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ReservationFormSheet(contacts: contacts),
    );
    if (draft == null) return;
    await _snack(() => widget.controller.createReservation(draft));
  }

  Future<void> _createHandover() async {
    final contacts = widget.controller.contactsState.data ?? const <CrmContact>[];
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先创建客户')));
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
      ),
    );
    if (draft == null) return;
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
      builder: (items) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final c = items[index];
          return Card(
            key: Key('crm-contact-${c.id}'),
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                [
                  c.statusLabel,
                  if (c.phone != null && c.phone!.isNotEmpty) c.phone!,
                  if (c.wechat != null && c.wechat!.isNotEmpty) '微信 ${c.wechat}',
                  if (c.notes != null && c.notes!.isNotEmpty) c.notes!,
                ].join(' · '),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ReservationsTab extends StatelessWidget {
  const _ReservationsTab({
    required this.controller,
    required this.onConfirm,
    required this.onCancel,
  });

  final CrmController controller;
  final ValueChanged<CrmReservation> onConfirm;
  final ValueChanged<CrmReservation> onCancel;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<CrmReservation>>(
      state: controller.reservationsState,
      onRetry: controller.refreshReservations,
      builder: (items) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final r = items[index];
          return Card(
            key: Key('crm-reservation-${r.id}'),
            child: ListTile(
              title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                '${r.contactName ?? r.contactId} · ${r.statusLabel}',
              ),
              trailing: r.isOpen
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'confirm') onConfirm(r);
                        if (value == 'cancel') onCancel(r);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'confirm', child: Text('确认预订')),
                        PopupMenuItem(value: 'cancel', child: Text('取消')),
                      ],
                    )
                  : Text(r.statusLabel),
            ),
          );
        },
      ),
    );
  }
}

class _HandoversTab extends StatelessWidget {
  const _HandoversTab({
    required this.controller,
    required this.onComplete,
  });

  final CrmController controller;
  final ValueChanged<CrmHandover> onComplete;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<CrmHandover>>(
      state: controller.handoversState,
      onRetry: controller.refreshHandovers,
      builder: (items) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final h = items[index];
          return Card(
            key: Key('crm-handover-${h.id}'),
            child: ListTile(
              title: Text(
                h.contactName ?? h.contactId,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(h.statusLabel),
              trailing: h.isOpen
                  ? TextButton(
                      key: Key('crm-handover-complete-${h.id}'),
                      onPressed: () => onComplete(h),
                      child: const Text('完成交付'),
                    )
                  : Text(h.statusLabel),
            ),
          );
        },
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('新建客户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
            key: const Key('crm-contact-name'),
            controller: _name,
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
            decoration: const InputDecoration(
              labelText: '手机',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _wechat,
            decoration: const InputDecoration(
              labelText: '微信',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: '备注',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('crm-contact-submit'),
            onPressed: () {
              if (_name.text.trim().isEmpty) return;
              Navigator.pop(
                context,
                CrmContactDraft(
                  name: _name.text.trim(),
                  phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
                  wechat: _wechat.text.trim().isEmpty ? null : _wechat.text.trim(),
                  notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _ReservationFormSheet extends StatefulWidget {
  const _ReservationFormSheet({required this.contacts});
  final List<CrmContact> contacts;

  @override
  State<_ReservationFormSheet> createState() => _ReservationFormSheetState();
}

class _ReservationFormSheetState extends State<_ReservationFormSheet> {
  late String _contactId;
  final _title = TextEditingController(text: '预订留种/宠物');
  final _hamsterId = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contactId = widget.contacts.first.id;
  }

  @override
  void dispose() {
    _title.dispose();
    _hamsterId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('新建预订', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('crm-reservation-contact'),
            initialValue: _contactId,
            decoration: const InputDecoration(
              labelText: '客户',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final c in widget.contacts)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() => _contactId = v!),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('crm-reservation-title'),
            controller: _title,
            decoration: const InputDecoration(
              labelText: '标题',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _hamsterId,
            decoration: const InputDecoration(
              labelText: '仓鼠 ID（可选）',
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
                  title: _title.text.trim(),
                  hamsterId: _hamsterId.text.trim().isEmpty
                      ? null
                      : _hamsterId.text.trim(),
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _HandoverFormSheet extends StatefulWidget {
  const _HandoverFormSheet({
    required this.contacts,
    required this.reservations,
  });

  final List<CrmContact> contacts;
  final List<CrmReservation> reservations;

  @override
  State<_HandoverFormSheet> createState() => _HandoverFormSheetState();
}

class _HandoverFormSheetState extends State<_HandoverFormSheet> {
  late String _contactId;
  String? _reservationId;

  @override
  void initState() {
    super.initState();
    _contactId = widget.contacts.first.id;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final related = widget.reservations
        .where((r) => r.contactId == _contactId)
        .toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('新建交付', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('crm-handover-contact'),
            initialValue: _contactId,
            decoration: const InputDecoration(
              labelText: '客户',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final c in widget.contacts)
                DropdownMenuItem(value: c.id, child: Text(c.name)),
            ],
            onChanged: (v) => setState(() {
              _contactId = v!;
              _reservationId = null;
            }),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            key: const Key('crm-handover-reservation'),
            initialValue: _reservationId,
            decoration: const InputDecoration(
              labelText: '关联预订（可选）',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('无')),
              for (final r in related)
                DropdownMenuItem(value: r.id, child: Text(r.title)),
            ],
            onChanged: (v) => setState(() => _reservationId = v),
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
                ),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
