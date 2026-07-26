// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/pedigree/pedigree_models.dart';
import 'package:scolvpet_mobile/features/pedigree/pedigree_repository.dart';

class MemoryPedigreeRepository implements PedigreeRepository {
  MemoryPedigreeRepository({Map<String, PedigreeGraph>? graphs})
    : _graphs = {...?graphs};

  final Map<String, PedigreeGraph> _graphs;
  final List<({String childId, String parentId, String role, String? reason})>
  created = [];
  final List<({String childId, String role, String reason})> ended = [];

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

  @override
  Future<void> createParentage({
    required String childHamsterId,
    required String parentHamsterId,
    required String role,
    String? correctionReason,
  }) async {
    created.add((
      childId: childHamsterId,
      parentId: parentHamsterId,
      role: role,
      reason: correctionReason,
    ));
    for (final entry in _graphs.entries.toList()) {
      final g = entry.value;
      final hasChild = g.nodes.any((n) => n.id == childHamsterId);
      if (!hasChild) continue;
      final parent = g.nodes.cast<PedigreeNode?>().firstWhere(
        (n) => n?.id == parentHamsterId,
        orElse: () => null,
      );
      final existing = g.edges.any(
        (e) => e.childId == childHamsterId && e.role == role,
      );
      if (existing &&
          (correctionReason == null || correctionReason.trim().isEmpty)) {
        throw const PedigreeRepositoryException('该位置已有父母关系');
      }
      final nodes = [
        ...g.nodes,
        if (parent == null)
          PedigreeNode(
            id: parentHamsterId,
            internalCode: parentHamsterId,
            name: '插入',
            sex: role == 'sire' ? 'male' : 'female',
          ),
      ];
      final edges = [
        ...g.edges.where(
          (e) => !(e.childId == childHamsterId && e.role == role),
        ),
        PedigreeEdge(
          childId: childHamsterId,
          parentId: parentHamsterId,
          role: role,
          evidenceType: 'manual',
        ),
      ];
      _graphs[entry.key] = PedigreeGraph(
        rootHamsterId: g.rootHamsterId,
        nodes: nodes,
        edges: edges,
        commonAncestors: g.commonAncestors,
      );
    }
  }

  @override
  Future<void> endParentage({
    required String childHamsterId,
    required String role,
    required String correctionReason,
  }) async {
    ended.add((
      childId: childHamsterId,
      role: role,
      reason: correctionReason,
    ));
    for (final entry in _graphs.entries.toList()) {
      final g = entry.value;
      final edges = g.edges
          .where((e) => !(e.childId == childHamsterId && e.role == role))
          .toList();
      _graphs[entry.key] = PedigreeGraph(
        rootHamsterId: g.rootHamsterId,
        nodes: g.nodes,
        edges: edges,
        commonAncestors: g.commonAncestors,
      );
    }
  }
}
