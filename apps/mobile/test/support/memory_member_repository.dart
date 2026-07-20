// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/members/member_models.dart';
import 'package:scolvpet_mobile/features/members/member_repository.dart';
import 'package:scolvpet_mobile/features/members/rbac.dart';

class MemoryMemberRepository implements MemberRepository {
  MemoryMemberRepository({
    this.organizationId = 'org-demo',
    this.ownerPhone = '13800138000',
    this.ownerName = '舍主',
  }) {
    _members = [
      OrganizationMember(
        id: 'member-owner',
        organizationId: organizationId,
        accountId: 'account-owner',
        phone: ownerPhone,
        displayName: ownerName,
        role: 'owner',
        status: 'active',
        invitedAt: DateTime.utc(2026, 1, 1),
        acceptedAt: DateTime.utc(2026, 1, 1),
        version: 1,
      ),
    ];
  }

  final String organizationId;
  final String ownerPhone;
  final String ownerName;
  late List<OrganizationMember> _members;
  int _seq = 1;

  String _normalizePhone(String raw) {
    var phone = raw.trim();
    if (phone.startsWith('+86')) phone = phone.substring(3);
    if (phone.startsWith('86') && phone.length > 11) {
      phone = phone.substring(2);
    }
    return phone.trim();
  }

  @override
  Future<List<OrganizationMember>> listMembers() async {
    return _members.where((m) => m.status != 'revoked').toList();
  }

  @override
  Future<OrganizationMember> invite(MemberInviteDraft draft) async {
    final phone = _normalizePhone(draft.phone);
    if (phone.length < 6) {
      throw const MemberRepositoryException('请输入有效手机号');
    }
    if (!inviteableRoles.contains(draft.role)) {
      throw const MemberRepositoryException('角色无效');
    }
    if (_members.any((m) => m.phone == phone && m.status != 'revoked')) {
      throw const MemberRepositoryException('该手机号已在成员列表中');
    }
    final member = OrganizationMember(
      id: 'member-${_seq++}',
      organizationId: organizationId,
      phone: phone,
      displayName: draft.displayName,
      role: draft.role,
      status: 'invited',
      invitedAt: DateTime.now().toUtc(),
      version: 1,
    );
    _members = [..._members, member];
    return member;
  }

  @override
  Future<OrganizationMember> updateRole({
    required String memberId,
    required int version,
    required String role,
    String? displayName,
  }) async {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index < 0) throw const MemberRepositoryException('成员不存在');
    final current = _members[index];
    if (current.version != version) {
      throw const MemberRepositoryException('版本冲突，请刷新');
    }
    if (current.isOwner) {
      throw const MemberRepositoryException('不可修改舍主角色');
    }
    if (!inviteableRoles.contains(role)) {
      throw const MemberRepositoryException('角色无效');
    }
    final next = current.copyWith(
      role: role,
      displayName: displayName ?? current.displayName,
      version: current.version + 1,
    );
    _members = [..._members]..[index] = next;
    return next;
  }

  @override
  Future<OrganizationMember> revoke({
    required String memberId,
    required int version,
  }) async {
    final index = _members.indexWhere((m) => m.id == memberId);
    if (index < 0) throw const MemberRepositoryException('成员不存在');
    final current = _members[index];
    if (current.version != version) {
      throw const MemberRepositoryException('版本冲突，请刷新');
    }
    if (current.isOwner) {
      throw const MemberRepositoryException('不可撤销舍主');
    }
    final next = current.copyWith(
      status: 'revoked',
      version: current.version + 1,
      revokedAt: DateTime.now().toUtc(),
    );
    _members = [..._members]..[index] = next;
    return next;
  }
}

