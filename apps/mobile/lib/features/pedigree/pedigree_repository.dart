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

class MemoryPedigreeRepository implements PedigreeRepository {
  MemoryPedigreeRepository({Map<String, PedigreeGraph>? graphs})
    : _graphs = {...?graphs};

  final Map<String, PedigreeGraph> _graphs;

  /// Seed a linear 3-generation sire/dam tree for tests.
  PedigreeGraph seedThreeGenerationTree({String rootId = 'h-root'}) {
    final g2s = PedigreeNode(
      id: '$rootId-g2s',
      internalCode: 'G2-S',
      name: '曾祖父',
      sex: 'male',
    );
    final g2d = PedigreeNode(
      id: '$rootId-g2d',
      internalCode: 'G2-D',
      name: '曾祖母',
      sex: 'female',
    );
    final g2s2 = PedigreeNode(
      id: '$rootId-g2s2',
      internalCode: 'G2-S2',
      name: '外曾祖父',
      sex: 'male',
    );
    final g2d2 = PedigreeNode(
      id: '$rootId-g2d2',
      internalCode: 'G2-D2',
      name: '外曾祖母',
      sex: 'female',
    );
    final sire = PedigreeNode(
      id: '$rootId-sire',
      internalCode: 'F-S',
      name: '父本',
      sex: 'male',
    );
    final dam = PedigreeNode(
      id: '$rootId-dam',
      internalCode: 'F-D',
      name: '母本',
      sex: 'female',
    );
    final root = PedigreeNode(
      id: rootId,
      internalCode: 'ROOT',
      name: '雪团',
      sex: 'female',
    );

    final graph = PedigreeGraph(
      rootHamsterId: rootId,
      nodes: [root, sire, dam, g2s, g2d, g2s2, g2d2],
      edges: [
        PedigreeEdge(childId: rootId, parentId: sire.id, role: 'sire'),
        PedigreeEdge(childId: rootId, parentId: dam.id, role: 'dam'),
        PedigreeEdge(childId: sire.id, parentId: g2s.id, role: 'sire'),
        PedigreeEdge(childId: sire.id, parentId: g2d.id, role: 'dam'),
        PedigreeEdge(childId: dam.id, parentId: g2s2.id, role: 'sire'),
        PedigreeEdge(childId: dam.id, parentId: g2d2.id, role: 'dam'),
      ],
    );
    _graphs[rootId] = graph;
    return graph;
  }

  void put(PedigreeGraph graph) => _graphs[graph.rootHamsterId] = graph;

  @override
  Future<PedigreeGraph> getPedigree(
    String hamsterId, {
    int generations = 4,
  }) async {
    final graph = _graphs[hamsterId];
    if (graph == null) {
      throw const PedigreeRepositoryException('谱系不存在');
    }
    return graph;
  }
}

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
