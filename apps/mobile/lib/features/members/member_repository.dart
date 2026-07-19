import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'member_models.dart';
import 'rbac.dart';

abstract interface class MemberRepository {
  Future<List<OrganizationMember>> listMembers();

  Future<OrganizationMember> invite(MemberInviteDraft draft);

  Future<OrganizationMember> updateRole({
    required String memberId,
    required int version,
    required String role,
    String? displayName,
  });

  Future<OrganizationMember> revoke({
    required String memberId,
    required int version,
  });
}

class MemberRepositoryException implements Exception {
  const MemberRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String memberErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '成员请求失败，请稍后重试',
  mapLocal: (e) => e is MemberRepositoryException ? e.message : null,
);

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

class DefaultApiMemberRepository implements MemberRepository {
  DefaultApiMemberRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();

  String _key() => 'member-${_uuid.v4()}';

  @override
  Future<List<OrganizationMember>> listMembers() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/organization-members',
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map(
          (item) =>
              OrganizationMember.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<OrganizationMember> invite(MemberInviteDraft draft) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/organization-members',
      data: {
        'phone': draft.phone,
        'role': draft.role,
        if (draft.displayName != null) 'display_name': draft.displayName,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    final data = response.data?['data'];
    if (data is! Map) {
      throw const MemberRepositoryException('邀请失败');
    }
    return OrganizationMember.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<OrganizationMember> updateRole({
    required String memberId,
    required int version,
    required String role,
    String? displayName,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '/organization-members/$memberId',
      data: {
        'role': role,
        if (displayName != null) 'display_name': displayName,
      },
      options: Options(
        headers: {'Idempotency-Key': _key(), 'If-Match': '"$version"'},
      ),
    );
    final data = response.data?['data'];
    if (data is! Map) {
      throw const MemberRepositoryException('更新角色失败');
    }
    return OrganizationMember.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<OrganizationMember> revoke({
    required String memberId,
    required int version,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/organization-members/$memberId/revoke',
      options: Options(
        headers: {'Idempotency-Key': _key(), 'If-Match': '"$version"'},
      ),
    );
    final data = response.data?['data'];
    if (data is! Map) {
      throw const MemberRepositoryException('撤销失败');
    }
    return OrganizationMember.fromJson(Map<String, dynamic>.from(data));
  }
}
