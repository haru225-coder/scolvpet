import 'package:dio/dio.dart';
import 'package:scolvpet_api/scolvpet_api.dart' as api;

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'pedigree_models.dart';

abstract interface class PedigreeRepository {
  Future<PedigreeGraph> getPedigree(String hamsterId, {int generations = 4});

  /// Create or replace a parentage edge. When [correctionReason] is set and an
  /// active edge already exists for child+role, the server supersedes the old
  /// edge (audit trail) then inserts the new one.
  Future<void> createParentage({
    required String childHamsterId,
    required String parentHamsterId,
    required String role,
    String? correctionReason,
  });

  /// End the active parentage for child+role without replacement.
  Future<void> endParentage({
    required String childHamsterId,
    required String role,
    required String correctionReason,
  });
}

class PedigreeRepositoryException implements Exception {
  const PedigreeRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String pedigreeErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '谱系加载失败，请稍后重试',
  nonDioFallback: '谱系暂时无法加载，请稍后重试',
  mapLocal: (e) => e is PedigreeRepositoryException ? e.message : null,
  mapDio: (e) {
    final code = e.response?.statusCode;
    if (code == 404) return '未找到该仓鼠的谱系或父母关系';
    if (code == 409) {
      return '该位置已有父母关系。请使用「替换」并填写纠错原因。';
    }
    if (code == 422) {
      final data = e.response?.data;
      final msg = data is Map ? data['message']?.toString() : null;
      if (msg != null && msg.trim().isNotEmpty) return msg;
      return '无法建立该血统关系（性别、环路或纠错原因校验未通过）';
    }
    return null;
  },
);

class DefaultApiPedigreeRepository implements PedigreeRepository {
  DefaultApiPedigreeRepository({required this.client});

  final ApiClient client;

  PedigreeNode _mapNode(api.Hamster h) => PedigreeNode(
    id: h.id,
    internalCode: h.internalCode,
    name: h.name,
    sex: h.sex.value,
    varietyCode: h.varietyCode,
  );

  PedigreeEdge _mapEdge(api.PedigreeParentage p) => PedigreeEdge(
    childId: p.childHamsterId,
    parentId: p.parentHamsterId,
    role: p.role.value,
    evidenceType: p.evidenceType.value,
    confidence: p.confidence,
  );

  @override
  Future<PedigreeGraph> getPedigree(
    String hamsterId, {
    int generations = 4,
  }) async {
    final response = await client.api.getHamsterPedigree(
      hamsterId: hamsterId,
      generations: generations,
    );
    final data = response.data?.data;
    if (data == null) {
      throw const PedigreeRepositoryException('谱系响应为空');
    }
    return PedigreeGraph(
      rootHamsterId: data.rootHamsterId,
      nodes: data.nodes.map(_mapNode).toList(),
      edges: data.parentages.map(_mapEdge).toList(),
      commonAncestors: data.commonAncestors
          .map(
            (a) => PedigreeCommonAncestor(
              hamsterId: a.hamsterId,
              paths: a.paths,
              minimumGeneration: a.minimumGeneration,
            ),
          )
          .toList(),
    );
  }

  String _idem(String op, String a, String b, String role) =>
      'ped-$op-${DateTime.now().microsecondsSinceEpoch}-'
      '${a.hashCode.abs()}-${b.hashCode.abs()}-$role';

  @override
  Future<void> createParentage({
    required String childHamsterId,
    required String parentHamsterId,
    required String role,
    String? correctionReason,
  }) async {
    final roleEnum = role == 'dam'
        ? api.PedigreeParentageCreateRequestRoleEnum.dam
        : api.PedigreeParentageCreateRequestRoleEnum.sire;
    // Generated create request has no correction_reason field yet; send full
    // JSON body via dio so replace supersede works against current API.
    await client.dio.post<Map<String, dynamic>>(
      '/pedigree-parentages',
      data: <String, dynamic>{
        'child_hamster_id': childHamsterId,
        'parent_hamster_id': parentHamsterId,
        'role': roleEnum.value,
        'evidence_type': 'manual',
        'confidence': 1,
        'valid_from': DateTime.now().toUtc().toIso8601String(),
        'notes': '血统遗传图快速填入',
        if (correctionReason != null && correctionReason.trim().isNotEmpty)
          'correction_reason': correctionReason.trim(),
      },
      options: Options(
        headers: <String, dynamic>{
          'Idempotency-Key': _idem(
            'create',
            childHamsterId,
            parentHamsterId,
            role,
          ),
        },
      ),
    );
  }

  @override
  Future<void> endParentage({
    required String childHamsterId,
    required String role,
    required String correctionReason,
  }) async {
    final reason = correctionReason.trim();
    if (reason.isEmpty) {
      throw const PedigreeRepositoryException('解除关系必须填写纠错原因');
    }
    await client.dio.post<Map<String, dynamic>>(
      '/pedigree-parentages/end',
      data: <String, dynamic>{
        'child_hamster_id': childHamsterId,
        'role': role == 'dam' ? 'dam' : 'sire',
        'correction_reason': reason,
      },
      options: Options(
        headers: <String, dynamic>{
          'Idempotency-Key': _idem('end', childHamsterId, role, reason),
        },
      ),
    );
  }
}
