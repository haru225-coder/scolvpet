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
    return internalCode.isEmpty ? '未命名仓鼠' : internalCode;
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

String pedigreeEvidenceLabel(String? value) => switch (value) {
  'profile' || 'record' => '档案记录',
  'manual' || 'human_confirmed' => '人工确认',
  'test' || 'genetic_test' => '检测确认',
  null || '' => '来源待更新',
  _ => '来源待更新',
};

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

  Map<String, PedigreeNode> get nodeById => {for (final n in nodes) n.id: n};
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

/// Human-facing relationship label for an ancestor role path.
///
/// gen0 [] → 当前个体；gen1 → 父本/母本；gen2 → 爷爷/奶奶/外公/外婆。
String pedigreeRelationshipLabel(List<String> rolePath) {
  if (rolePath.isEmpty) return '当前个体';
  if (rolePath.length == 1) {
    return rolePath.single == 'sire' ? '父本' : '母本';
  }
  if (rolePath.length == 2) {
    return switch ('${rolePath[0]}/${rolePath[1]}') {
      'sire/sire' => '爷爷',
      'sire/dam' => '奶奶',
      'dam/sire' => '外公',
      'dam/dam' => '外婆',
      _ => rolePath.map((r) => r == 'sire' ? '父' : '母').join(''),
    };
  }
  // 更深代：父系·母系… 路径
  return '${rolePath.map((r) => r == 'sire' ? '父' : '母').join('系·')}系';
}

/// Target for filling one empty pedigree slot via a parentage edge.
class PedigreeFillTarget {
  const PedigreeFillTarget({
    required this.rolePath,
    required this.role,
    required this.pathToChild,
    required this.label,
    required this.preferredSex,
  });

  /// Full path of the slot being filled (e.g. `['sire','dam']` = 奶奶).
  final List<String> rolePath;

  /// Last hop role: `sire` | `dam`.
  final String role;

  /// Path from root to the child of this edge (empty = root is child).
  final List<String> pathToChild;

  final String label;

  /// `male` for sire slots, `female` for dam slots.
  final String preferredSex;
}

/// Build fill target for an ancestor slot (null for root / empty path).
PedigreeFillTarget? pedigreeFillTargetForSlot(PedigreeTreeSlot slot) {
  if (slot.rolePath.isEmpty) return null;
  final role = slot.rolePath.last;
  if (role != 'sire' && role != 'dam') return null;
  return PedigreeFillTarget(
    rolePath: List<String>.from(slot.rolePath),
    role: role,
    pathToChild: slot.rolePath.sublist(0, slot.rolePath.length - 1),
    label: pedigreeRelationshipLabel(slot.rolePath),
    preferredSex: role == 'sire' ? 'male' : 'female',
  );
}

/// Active parent id for [childId] + [role] from graph edges, if any.
String? pedigreeParentIdOf(
  PedigreeGraph graph, {
  required String childId,
  required String role,
}) {
  for (final e in graph.edges) {
    if (e.childId == childId && e.role == role) return e.parentId;
  }
  return null;
}

/// Direct offspring of [rootId] derived only from existing pedigree edges.
///
/// Returns unique child nodes (order: sire-edges first, then dam-edges, then id).
List<PedigreeNode> listDirectDescendants(PedigreeGraph graph) {
  final nodes = graph.nodeById;
  final byId = <String, PedigreeNode>{};
  for (final e in graph.edges) {
    if (e.parentId != graph.rootHamsterId) continue;
    final child = nodes[e.childId];
    if (child == null) continue;
    byId.putIfAbsent(child.id, () => child);
  }
  final list = byId.values.toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));
  return list;
}

/// Positioned node in a classic binary pedigree chart (ancestors above root).
class PedigreeChartNode {
  const PedigreeChartNode({
    required this.slot,
    required this.indexInGeneration,
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
  });

  final PedigreeTreeSlot slot;
  final int indexInGeneration;
  final double centerX;
  final double centerY;
  final double width;
  final double height;

  double get left => centerX - width / 2;
  double get top => centerY - height / 2;
  double get right => centerX + width / 2;
  double get bottom => centerY + height / 2;
}

/// Connector between a child slot and one parent (sire or dam).
class PedigreeChartEdge {
  const PedigreeChartEdge({
    required this.childCenterX,
    required this.childTopY,
    required this.parentCenterX,
    required this.parentBottomY,
    required this.branchY,
    required this.isSire,
  });

  final double childCenterX;
  final double childTopY;
  final double parentCenterX;
  final double parentBottomY;

  /// Horizontal bar Y between parent bottoms and child top.
  final double branchY;
  final bool isSire;
}

/// Full layout for a classic vertical pedigree genetic chart.
class PedigreeChartLayout {
  const PedigreeChartLayout({
    required this.nodes,
    required this.edges,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.maxGeneration,
  });

  final List<PedigreeChartNode> nodes;
  final List<PedigreeChartEdge> edges;
  final double canvasWidth;
  final double canvasHeight;
  final double nodeWidth;
  final double nodeHeight;
  final int maxGeneration;

  PedigreeChartNode? nodeAt({required int generation, required int index}) {
    for (final n in nodes) {
      if (n.slot.generation == generation && n.indexInGeneration == index) {
        return n;
      }
    }
    return null;
  }
}

/// Classic binary pedigree layout: deepest ancestors on top, root at bottom.
///
/// Uses leaf-aligned columns so each parent pair sits directly above its child
/// (standard animal-breeding pedigree geometry).
PedigreeChartLayout layoutClassicPedigreeChart(
  List<List<PedigreeTreeSlot>> rows, {
  double nodeWidth = 118,
  double nodeHeight = 78,
  double horizontalGap = 14,
  double verticalGap = 36,
  double paddingX = 20,
  double paddingY = 20,
}) {
  if (rows.isEmpty) {
    return PedigreeChartLayout(
      nodes: const [],
      edges: const [],
      canvasWidth: paddingX * 2 + nodeWidth,
      canvasHeight: paddingY * 2 + nodeHeight,
      nodeWidth: nodeWidth,
      nodeHeight: nodeHeight,
      maxGeneration: 0,
    );
  }

  final maxGen = rows.length - 1;
  // Ensure binary width even if a row is short.
  final leafCount = 1 << maxGen; // 2^maxGen
  final unit = nodeWidth + horizontalGap;
  final contentWidth = leafCount * unit - horizontalGap;
  final canvasWidth = contentWidth + paddingX * 2;
  final canvasHeight =
      paddingY * 2 + (maxGen + 1) * nodeHeight + maxGen * verticalGap;

  final chartNodes = <PedigreeChartNode>[];
  for (var g = 0; g <= maxGen; g++) {
    final row = rows[g];
    final span = 1 << (maxGen - g); // leaf units covered by one slot
    for (var i = 0; i < row.length; i++) {
      final leftLeaf = i * span;
      final centerLeaf = leftLeaf + span / 2.0;
      final centerX = paddingX + centerLeaf * unit - horizontalGap / 2;
      // Ancestors (high gen) at top; root (gen 0) at bottom.
      final rowFromTop = maxGen - g;
      final centerY =
          paddingY + rowFromTop * (nodeHeight + verticalGap) + nodeHeight / 2;
      chartNodes.add(
        PedigreeChartNode(
          slot: row[i],
          indexInGeneration: i,
          centerX: centerX,
          centerY: centerY,
          width: nodeWidth,
          height: nodeHeight,
        ),
      );
    }
  }

  PedigreeChartNode? findNode(int generation, int index) {
    for (final n in chartNodes) {
      if (n.slot.generation == generation && n.indexInGeneration == index) {
        return n;
      }
    }
    return null;
  }

  final chartEdges = <PedigreeChartEdge>[];
  for (var g = 0; g < maxGen; g++) {
    final childRow = rows[g];
    for (var ci = 0; ci < childRow.length; ci++) {
      final child = findNode(g, ci);
      if (child == null) continue;
      final sire = findNode(g + 1, ci * 2);
      final dam = findNode(g + 1, ci * 2 + 1);
      if (sire == null && dam == null) continue;
      final parentBottom = sire?.bottom ?? dam!.bottom;
      final branchY = (child.top + parentBottom) / 2;
      if (sire != null) {
        chartEdges.add(
          PedigreeChartEdge(
            childCenterX: child.centerX,
            childTopY: child.top,
            parentCenterX: sire.centerX,
            parentBottomY: sire.bottom,
            branchY: branchY,
            isSire: true,
          ),
        );
      }
      if (dam != null) {
        chartEdges.add(
          PedigreeChartEdge(
            childCenterX: child.centerX,
            childTopY: child.top,
            parentCenterX: dam.centerX,
            parentBottomY: dam.bottom,
            branchY: branchY,
            isSire: false,
          ),
        );
      }
    }
  }

  return PedigreeChartLayout(
    nodes: chartNodes,
    edges: chartEdges,
    canvasWidth: canvasWidth,
    canvasHeight: canvasHeight,
    nodeWidth: nodeWidth,
    nodeHeight: nodeHeight,
    maxGeneration: maxGen,
  );
}
