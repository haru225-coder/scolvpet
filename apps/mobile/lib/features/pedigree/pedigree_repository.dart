import 'package:scolvpet_api/scolvpet_api.dart' as api;

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'pedigree_models.dart';

abstract interface class PedigreeRepository {
  Future<PedigreeGraph> getPedigree(String hamsterId, {int generations = 4});
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
  mapDio: (e) => e.response?.statusCode == 404 ? '未找到该仓鼠的谱系' : null,
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
}
