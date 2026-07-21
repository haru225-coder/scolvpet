// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/pedigree/pedigree_models.dart';
import 'package:scolvpet_mobile/features/pedigree/pedigree_repository.dart';

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
