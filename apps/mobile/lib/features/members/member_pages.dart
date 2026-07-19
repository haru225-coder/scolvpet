import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'member_controller.dart';
import 'member_models.dart';
import 'rbac.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key, required this.controller});

  final MemberController controller;

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.refresh();
  }

  Future<void> _invite() async {
    final draft = await showModalBottomSheet<MemberInviteDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _InviteSheet(),
    );
    if (draft == null || !mounted) return;
    final ok = await widget.controller.invite(draft);
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (message != null) {
      showIosMessage(context, message);
    }
    if (ok) setState(() {});
  }

  Future<void> _changeRole(OrganizationMember member) async {
    final role = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('选择角色')),
            for (final r in inviteableRoles)
              ListTile(
                key: Key('member-role-option-$r'),
                title: Text(memberRoleLabel(r)),
                trailing: member.role == r
                    ? Icon(
                        CupertinoIcons.checkmark_alt,
                        color: ScolvPalette.of(context).accent,
                      )
                    : null,
                onTap: () => Navigator.pop(context, r),
              ),
          ],
        ),
      ),
    );
    if (role == null || role == member.role || !mounted) return;
    final ok = await widget.controller.changeRole(member, role);
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (message != null) {
      showIosMessage(context, message);
    }
    if (ok) setState(() {});
  }

  Future<void> _revoke(OrganizationMember member) async {
    final confirmed = await showIosAlert(
      context: context,
      title: '撤销成员',
      message: '确认撤销 ${member.title}（${memberRoleLabel(member.role)}）？',
      cancelLabel: '取消',
      confirmLabel: '撤销',
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    final ok = await widget.controller.revoke(member);
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (message != null) {
      showIosMessage(context, message);
    }
    if (ok) setState(() {});
  }

  Future<void> _showMemberDetails(OrganizationMember member) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final palette = ScolvPalette.of(context);
        final statusColor = _memberStatusColor(member.status);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _MemberAvatar(member: member, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            member.phone,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: palette.secondaryLabel),
                          ),
                        ],
                      ),
                    ),
                    IosStatusBadge(
                      label: memberStatusLabel(member.status),
                      color: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  memberRoleLabel(member.role),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: palette.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  memberRoleDescription(member.role),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.secondaryLabel,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final label in memberRolePermissionLabels(member.role))
                      IosStatusBadge(label: label, color: palette.accent),
                  ],
                ),
                if (!member.isOwner && widget.controller.canManage) ...[
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _changeRole(member);
                    },
                    icon: const Icon(
                      CupertinoIcons.person_crop_circle_badge_checkmark,
                    ),
                    label: const Text('修改角色'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _revoke(member);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: IosColors.systemRed,
                    ),
                    child: const Text('撤销成员'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final members =
            widget.controller.listState.data ?? const <OrganizationMember>[];
        final activeCount = members
            .where((member) => member.status == 'active')
            .length;
        final invitedCount = members
            .where((member) => member.status == 'invited')
            .length;
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('成员与权限'),
            actions: [
              IconButton(
                key: const Key('member-refresh'),
                onPressed: widget.controller.refresh,
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          floatingActionButton: widget.controller.canManage
              ? FloatingActionButton.extended(
                  key: const Key('member-invite'),
                  onPressed: busy ? null : _invite,
                  backgroundColor: ScolvPalette.of(context).accent,
                  foregroundColor: ScolvPalette.of(context).groupedBackground,
                  elevation: 0,
                  icon: const Icon(CupertinoIcons.person_badge_plus),
                  label: const Text('邀请成员'),
                )
              : null,
          body: Column(
            children: [
              IosModuleIntro(
                icon: CupertinoIcons.person_2_fill,
                title: '团队协作',
                description: widget.controller.canManage
                    ? '邀请伙伴加入当前熊舍，并按实际职责分配可操作范围。'
                    : '你当前以${memberRoleLabel(widget.controller.currentRole)}身份加入，写入口会按权限显示。',
                metrics: [
                  IosModuleMetric(label: '成员', value: '${members.length}'),
                  IosModuleMetric(
                    label: '已加入',
                    value: '$activeCount',
                    color: IosColors.systemGreen,
                  ),
                  IosModuleMetric(
                    label: '待接受',
                    value: '$invitedCount',
                    color: IosColors.systemOrange,
                  ),
                ],
              ),
              Expanded(
                child: I2AsyncStateView<List<OrganizationMember>>(
                  state: widget.controller.listState,
                  onRetry: widget.controller.refresh,
                  emptyBuilder: (context) => Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: BearEmptyCard(
                        title: '还没有团队成员',
                        subtitle: '邀请第一位伙伴后，可以按繁育、饲养、客服或只读职责分工。',
                        illustration: BearAssets.onboardingSetup,
                        actionLabel: widget.controller.canManage
                            ? '邀请成员'
                            : null,
                        onAction: widget.controller.canManage ? _invite : null,
                      ),
                    ),
                  ),
                  builder: (members) {
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
                      children: [
                        IosGroupedSection(
                          children: [
                            for (final member in members)
                              IosListTile(
                                key: Key('member-card-${member.id}'),
                                leading: _MemberAvatar(member: member),
                                title: member.title,
                                subtitle:
                                    '${memberRoleLabel(member.role)}\n${memberRoleDescription(member.role)}',
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IosStatusBadge(
                                      label: memberStatusLabel(member.status),
                                      color: _memberStatusColor(member.status),
                                    ),
                                    if (!member.isOwner &&
                                        widget.controller.canManage) ...[
                                      const SizedBox(width: 4),
                                      PopupMenuButton<String>(
                                        key: Key('member-menu-${member.id}'),
                                        enabled: !busy,
                                        onSelected: (value) {
                                          if (value == 'role') {
                                            _changeRole(member);
                                          } else if (value == 'revoke') {
                                            _revoke(member);
                                          }
                                        },
                                        itemBuilder: (context) => const [
                                          PopupMenuItem(
                                            value: 'role',
                                            child: Text('修改角色'),
                                          ),
                                          PopupMenuItem(
                                            value: 'revoke',
                                            child: Text('撤销'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () => _showMemberDetails(member),
                                showChevron: false,
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet();

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _phone = TextEditingController();
  final _name = TextEditingController();
  String _role = 'caretaker';

  @override
  void dispose() {
    _phone.dispose();
    _name.dispose();
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
          const Text(
            '邀请成员',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('member-invite-phone'),
            controller: _phone,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '手机号 *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('member-invite-name'),
            controller: _name,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: '显示名（可选）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          IosPickerField<String>(
            key: const Key('member-invite-role'),
            label: '角色',
            selected: _role,
            items: [
              for (final r in inviteableRoles)
                IosPickerItem(value: r, label: memberRoleLabel(r)),
            ],
            onSelected: (value) {
              if (value != null) setState(() => _role = value);
            },
          ),
          const SizedBox(height: 8),
          Text(
            memberRoleDescription(_role),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ScolvPalette.of(context).secondaryLabel,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final label in memberRolePermissionLabels(_role))
                IosStatusBadge(
                  label: label,
                  color: ScolvPalette.of(context).accent,
                ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('member-invite-submit'),
            onPressed: () {
              final phone = _phone.text.trim();
              if (phone.length < 6) {
                showIosMessage(context, '请输入有效手机号');
                return;
              }
              Navigator.pop(
                context,
                MemberInviteDraft(
                  phone: phone,
                  role: _role,
                  displayName: _name.text.trim().isEmpty
                      ? null
                      : _name.text.trim(),
                ),
              );
            },
            child: const Text('发送邀请'),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member, this.size = 36});

  final OrganizationMember member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final color = member.isOwner ? palette.accent : palette.secondaryLabel;
    final label = memberRoleLabel(member.role);
    final initial = label.isEmpty ? '?' : label.substring(0, 1);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: member.isOwner ? 0.95 : 0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: member.isOwner ? palette.groupedBackground : palette.label,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}

Color _memberStatusColor(String status) => switch (status) {
  'active' => IosColors.systemGreen,
  'invited' => IosColors.systemOrange,
  'revoked' => IosColors.systemRed,
  _ => IosColors.systemGray,
};
