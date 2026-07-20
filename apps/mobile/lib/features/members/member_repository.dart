import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'member_models.dart';

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
