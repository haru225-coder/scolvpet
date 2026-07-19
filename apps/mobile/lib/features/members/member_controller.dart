import 'package:flutter/foundation.dart';

import '../i2/i2_models.dart';
import 'member_models.dart';
import 'member_repository.dart';
import 'rbac.dart';

class MemberController extends ChangeNotifier {
  MemberController({required this.repository, this.currentRole = 'owner'});

  final MemberRepository repository;

  /// Role of the signed-in user within the current organization.
  String currentRole;

  I2AsyncState<List<OrganizationMember>> listState = const I2AsyncState.idle();
  I2AsyncState<void> actionState = const I2AsyncState.idle();
  String? lastMessage;

  bool get canManage => memberCanManageMembers(currentRole);

  Future<void> refresh() async {
    listState = const I2AsyncState.loading();
    notifyListeners();
    try {
      final members = await repository.listMembers();
      listState = members.isEmpty
          ? const I2AsyncState.empty(message: '暂无成员')
          : I2AsyncState.data(members);
    } catch (error) {
      listState = I2AsyncState.error(memberErrorMessage(error));
    }
    notifyListeners();
  }

  Future<bool> invite(MemberInviteDraft draft) async {
    if (!canManage) {
      lastMessage = '当前角色无权邀请成员';
      notifyListeners();
      return false;
    }
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      await repository.invite(draft);
      actionState = const I2AsyncState.data(null);
      lastMessage = '已发送邀请';
      await refresh();
      return true;
    } catch (error) {
      final message = memberErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeRole(OrganizationMember member, String role) async {
    if (!canManage) {
      lastMessage = '当前角色无权修改成员';
      notifyListeners();
      return false;
    }
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      await repository.updateRole(
        memberId: member.id,
        version: member.version,
        role: role,
      );
      actionState = const I2AsyncState.data(null);
      lastMessage = '角色已更新';
      await refresh();
      return true;
    } catch (error) {
      final message = memberErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> revoke(OrganizationMember member) async {
    if (!canManage) {
      lastMessage = '当前角色无权撤销成员';
      notifyListeners();
      return false;
    }
    actionState = const I2AsyncState.loading();
    lastMessage = null;
    notifyListeners();
    try {
      await repository.revoke(memberId: member.id, version: member.version);
      actionState = const I2AsyncState.data(null);
      lastMessage = '已撤销成员';
      await refresh();
      return true;
    } catch (error) {
      final message = memberErrorMessage(error);
      actionState = I2AsyncState.error(message);
      lastMessage = message;
      notifyListeners();
      return false;
    }
  }
}
