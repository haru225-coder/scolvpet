import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../i2/i2_widgets.dart';
import 'member_controller.dart';
import 'member_models.dart';
import 'rbac.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({
    super.key,
    required this.controller,
  });

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
                    ? const Icon(Icons.check, color: Color(0xffc77852))
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (ok) setState(() {});
  }

  Future<void> _revoke(OrganizationMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('撤销成员'),
        content: Text('确认撤销 ${member.title}（${memberRoleLabel(member.role)}）？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('撤销'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await widget.controller.revoke(member);
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
            title: const Text('成员与权限'),
            actions: [
              IconButton(
                key: const Key('member-refresh'),
                onPressed: widget.controller.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: widget.controller.canManage
              ? FloatingActionButton.extended(
                  key: const Key('member-invite'),
                  onPressed: _invite,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('邀请成员'),
                )
              : null,
          body: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  '舍主可邀请繁育员、饲养员、客服与只读访客。数据范围仍按熊舍 owner 隔离；'
                  '角色控制写入口（繁育 / 日常护理 / 只读）。',
                  style: TextStyle(color: Color(0xff6c7774), fontSize: 13),
                ),
              ),
              Expanded(
                child: I2AsyncStateView<List<OrganizationMember>>(
                  state: widget.controller.listState,
                  onRetry: widget.controller.refresh,
                  builder: (members) {
                    if (members.isEmpty) {
                      return const I2StateMessage(
                        icon: Icons.group_outlined,
                        message: '暂无成员',
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                      itemCount: members.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Card(
                          key: Key('member-card-${member.id}'),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: member.isOwner
                                  ? const Color(0xffc77852)
                                  : const Color(0xffdce5e3),
                              child: Text(
                                memberRoleLabel(member.role).substring(0, 1),
                                style: TextStyle(
                                  color: member.isOwner
                                      ? Colors.white
                                      : const Color(0xff1f2928),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            title: Text(
                              member.title,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              '${memberRoleLabel(member.role)} · '
                              '${memberStatusLabel(member.status)}\n'
                              '手机 ${member.phone}',
                            ),
                            isThreeLine: true,
                            trailing: member.isOwner ||
                                    !widget.controller.canManage
                                ? null
                                : PopupMenuButton<String>(
                                    key: Key('member-menu-${member.id}'),
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
                          ),
                        );
                      },
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
            decoration: const InputDecoration(
              labelText: '显示名（可选）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: const Key('member-invite-role'),
            initialValue: _role,
            decoration: const InputDecoration(
              labelText: '角色',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final r in inviteableRoles)
                DropdownMenuItem(
                  value: r,
                  child: Text(memberRoleLabel(r)),
                ),
            ],
            onChanged: (value) => setState(() => _role = value!),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('member-invite-submit'),
            onPressed: () {
              final phone = _phone.text.trim();
              if (phone.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入有效手机号')),
                );
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
