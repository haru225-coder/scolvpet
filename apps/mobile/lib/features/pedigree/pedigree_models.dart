// Pedigree graph models and pure tree expansion (T-P0-07).

class PedigreeNode {
  const PedigreeNode({
    required this.id,
    required this.internalCode,
    this.name,
    this.sex = 'unknown',
    this.varietyCode,
  });

  final String id;
  final String internalCode;
  final String? name;
  final String sex;
  final String? varietyCode;

  String get displayName {
    final n = name?.trim();
    if (n != null && n.isNotEmpty) return '$n · $internalCode';
    return internalCode.isEmpty ? id : internalCode;
  }

  factory PedigreeNode.fromJson(Map<String, dynamic> json) => PedigreeNode(
    id: json['id'] as String? ?? '',
    internalCode: json['internal_code'] as String? ?? '',
    name: json['name'] as String?,
    sex: json['sex'] as String? ?? 'unknown',
    varietyCode: json['variety_code'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'internal_code': internalCode,
    'name': name,
    'sex': sex,
    'variety_code': varietyCode,
  };
}

class PedigreeEdge {
  const PedigreeEdge({
    required this.childId,
    required this.parentId,
    required this.role,
    this.evidenceType,
    this.confidence,
  });

  /// role: sire | dam
  final String childId;
  final String parentId;
  final String role;
  final String? evidenceType;
  final num? confidence;

  bool get isSire => role == 'sire';
  bool get isDam => role == 'dam';

  factory PedigreeEdge.fromJson(Map<String, dynamic> json) => PedigreeEdge(
    childId: json['child_hamster_id'] as String? ?? '',
    parentId: json['parent_hamster_id'] as String? ?? '',
    role: json['role'] as String? ?? 'sire',
    evidenceType: json['evidence_type'] as String?,
    confidence: json['confidence'] as num?,
  );
}

class PedigreeCommonAncestor {
  const PedigreeCommonAncestor({
    required this.hamsterId,
    required this.paths,
    required this.minimumGeneration,
  });

  final String hamsterId;
  final int paths;
  final int minimumGeneration;

  factory PedigreeCommonAncestor.fromJson(Map<String, dynamic> json) =>
      PedigreeCommonAncestor(
        hamsterId: json['hamster_id'] as String? ?? '',
        paths: (json['paths'] as num?)?.toInt() ?? 0,
        minimumGeneration: (json['minimum_generation'] as num?)?.toInt() ?? 0,
      );
}

class PedigreeGraph {
  const PedigreeGraph({
    required this.rootHamsterId,
    required this.nodes,
    required this.edges,
    this.commonAncestors = const <PedigreeCommonAncestor>[],
  });

  final String rootHamsterId;
  final List<PedigreeNode> nodes;
  final List<PedigreeEdge> edges;
  final List<PedigreeCommonAncestor> commonAncestors;

  Map<String, PedigreeNode> get nodeById => {
    for (final n in nodes) n.id: n,
  };
}

/// One ancestor slot in a generation row (sire left / dam right layout).
class PedigreeTreeSlot {
  const PedigreeTreeSlot({
    required this.generation,
    required this.rolePath,
    this.node,
    this.edge,
  });

  /// 0 = root, 1 = parents, 2 = grandparents, …
  final int generation;

  /// Path of roles from root, e.g. ['sire','dam'] = paternal grandmother.
  final List<String> rolePath;
  final PedigreeNode? node;
  final PedigreeEdge? edge;

  bool get isUnknown => node == null;

  String get roleLabel {
    if (rolePath.isEmpty) return '本人';
    final last = rolePath.last;
    return last == 'dam' ? '母' : '父';
  }

  String get pathLabel {
    if (rolePath.isEmpty) return '本代';
    return '${rolePath.map((r) => r == 'dam' ? '母' : '父').join('系·')}系';
  }
}

/// Expand ancestors upward for [generations] levels (3 = root+parents+gp).
///
/// Generation depth N means N ancestor hops (acceptance: ≥3 generations).
List<List<PedigreeTreeSlot>> buildAncestorGenerations(
  PedigreeGraph graph, {
  int generations = 3,
}) {
  final depth = generations < 1 ? 1 : generations;
  final nodes = graph.nodeById;
  final edgesByChild = <String, List<PedigreeEdge>>{};
  for (final e in graph.edges) {
    edgesByChild.putIfAbsent(e.childId, () => <PedigreeEdge>[]).add(e);
  }

  PedigreeEdge? pick(String childId, String role) {
    final list = edgesByChild[childId] ?? const <PedigreeEdge>[];
    for (final e in list) {
      if (e.role == role) return e;
    }
    return null;
  }

  final rows = <List<PedigreeTreeSlot>>[];
  // Generation 0: root
  rows.add([
    PedigreeTreeSlot(
      generation: 0,
      rolePath: const [],
      node: nodes[graph.rootHamsterId],
    ),
  ]);

  var previous = rows.first;
  for (var gen = 1; gen <= depth; gen++) {
    final row = <PedigreeTreeSlot>[];
    for (final slot in previous) {
      final childId = slot.node?.id;
      for (final role in const ['sire', 'dam']) {
        final edge = childId == null ? null : pick(childId, role);
        final parentId = edge?.parentId;
        row.add(
          PedigreeTreeSlot(
            generation: gen,
            rolePath: [...slot.rolePath, role],
            node: parentId == null ? null : nodes[parentId],
            edge: edge,
          ),
        );
      }
    }
    rows.add(row);
    previous = row;
  }
  return rows;
}

int countKnownAncestors(List<List<PedigreeTreeSlot>> rows) {
  var count = 0;
  for (var i = 1; i < rows.length; i++) {
    for (final slot in rows[i]) {
      if (slot.node != null) count++;
    }
  }
  return count;
}

int maxFilledGeneration(List<List<PedigreeTreeSlot>> rows) {
  var max = 0;
  for (var i = 1; i < rows.length; i++) {
    if (rows[i].any((s) => s.node != null)) max = i;
  }
  return max;
}
