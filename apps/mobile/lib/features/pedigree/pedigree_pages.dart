import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/correction_reason_sheet.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'pedigree_controller.dart';
import 'pedigree_models.dart';

/// Editable multi-generation pedigree genetic chart.
///
/// Empty slots: tap → pick existing / quick-create → write parentage.
/// Known nodes: tap → navigate into that animal's tree.
class PedigreePage extends StatefulWidget {
  const PedigreePage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.hamsterLabel,
    this.generations = 3,
    this.onOpenBreeding,
    this.canEdit = false,
    this.candidates = const <I2Hamster>[],
    this.createStub,
  });

  final PedigreeController controller;
  final String hamsterId;
  final String? hamsterLabel;
  final int generations;
  final VoidCallback? onOpenBreeding;

  /// When true, empty slots open a simple fill sheet.
  final bool canEdit;

  /// Existing hamsters for one-tap pick (filtered by sex in the sheet).
  final List<I2Hamster> candidates;

  /// Creates a minimal stub used for mid-generation auto-fill or quick create.
  final PedigreeStubFactory? createStub;

  @override
  State<PedigreePage> createState() => _PedigreePageState();
}

class _PedigreePageState extends State<PedigreePage> {
  final List<({String id, String? label})> _history = [];
  late String _currentHamsterId;
  String? _currentHamsterLabel;

  @override
  void initState() {
    super.initState();
    _currentHamsterId = widget.hamsterId;
    _currentHamsterLabel = widget.hamsterLabel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.controller.load(
        _currentHamsterId,
        generationsDepth: widget.generations,
      );
    });
  }

  @override
  void didUpdateWidget(covariant PedigreePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hamsterId == widget.hamsterId) return;
    _history.clear();
    _currentHamsterId = widget.hamsterId;
    _currentHamsterLabel = widget.hamsterLabel;
    widget.controller.load(
      _currentHamsterId,
      generationsDepth: widget.generations,
    );
  }

  Future<void> _openAncestor(PedigreeNode node) async {
    if (node.id == _currentHamsterId) return;
    setState(() {
      _history.add((id: _currentHamsterId, label: _currentHamsterLabel));
      _currentHamsterId = node.id;
      _currentHamsterLabel = node.displayName;
    });
    await widget.controller.load(node.id, generationsDepth: widget.generations);
  }

  Future<void> _goBackInPedigree() async {
    if (_history.isEmpty) return;
    final previous = _history.removeLast();
    setState(() {
      _currentHamsterId = previous.id;
      _currentHamsterLabel = previous.label;
    });
    await widget.controller.load(
      previous.id,
      generationsDepth: widget.generations,
    );
  }

  Future<void> _onSlotTap(PedigreeTreeSlot slot) async {
    final target = pedigreeFillTargetForSlot(slot);
    // Root node: navigate only (or no-op).
    if (target == null) {
      if (slot.node != null) await _openAncestor(slot.node!);
      return;
    }

    if (!widget.canEdit || widget.createStub == null) {
      if (slot.node != null) {
        await _openAncestor(slot.node!);
        return;
      }
      if (!mounted) return;
      showIosMessage(context, '该位置尚未填写；有编辑权限时可点此直接填入');
      return;
    }

    if (slot.node != null) {
      await _onFilledSlotEdit(slot, target);
      return;
    }
    await _fillEmptySlot(slot, target);
  }

  Future<void> _onFilledSlotEdit(
    PedigreeTreeSlot slot,
    PedigreeFillTarget target,
  ) async {
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        key: const Key('pedigree-slot-actions'),
        title: Text(target.label),
        message: Text('当前：${slot.node!.displayName}'),
        actions: [
          CupertinoActionSheetAction(
            key: const Key('pedigree-action-open'),
            onPressed: () => Navigator.pop(ctx, 'open'),
            child: const Text('查看其血统'),
          ),
          CupertinoActionSheetAction(
            key: const Key('pedigree-action-replace'),
            onPressed: () => Navigator.pop(ctx, 'replace'),
            child: const Text('替换（需写纠错原因）'),
          ),
          CupertinoActionSheetAction(
            key: const Key('pedigree-action-end'),
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, 'end'),
            child: const Text('解除关系（需写纠错原因）'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'open':
        await _openAncestor(slot.node!);
      case 'replace':
        await _fillEmptySlot(slot, target, replacing: true);
      case 'end':
        await _endSlot(slot, target);
    }
  }

  Future<void> _endSlot(
    PedigreeTreeSlot slot,
    PedigreeFillTarget target,
  ) async {
    final reason = await showPedigreeCorrectionReasonSheet(
      context: context,
      title: '解除「${target.label}」',
      hint: '例如：核实后无此父母 / 档案选错',
    );
    if (reason == null || !mounted) return;
    final ok = await widget.controller.endSlot(
      slot: slot,
      correctionReason: reason,
    );
    if (!mounted) return;
    final msg = widget.controller.lastMessage;
    if (msg != null) showIosMessage(context, msg);
    if (ok) HapticFeedback.lightImpact();
  }

  Future<void> _fillEmptySlot(
    PedigreeTreeSlot slot,
    PedigreeFillTarget target, {
    bool replacing = false,
  }) async {
    String? correctionReason;
    if (replacing) {
      correctionReason = await showPedigreeCorrectionReasonSheet(
        context: context,
        title: '替换「${target.label}」',
        hint: '例如：选错同名仓鼠 / 临时档确认有误',
      );
      if (correctionReason == null || !mounted) return;
    }

    final parent = await showPedigreeFillSheet(
      context: context,
      target: target,
      candidates: widget.candidates,
      excludeIds: {
        _currentHamsterId,
        ...?widget.controller.graphState.data?.nodes.map((n) => n.id),
      },
      createNamed: (name) async {
        final sex = target.preferredSex;
        final node = await widget.createStub!(
          name: name,
          sex: sex,
          relationLabel: target.label,
        );
        return node;
      },
    );
    if (parent == null || !mounted) return;

    final ok = await widget.controller.fillSlot(
      slot: slot,
      parentId: parent.id,
      createStub: widget.createStub!,
      correctionReason: correctionReason,
    );
    if (!mounted) return;
    final msg = widget.controller.lastMessage;
    if (msg != null) showIosMessage(context, msg);
    if (ok) HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return PopScope(
          canPop: _history.isEmpty,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _goBackInPedigree();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: _history.isEmpty
                  ? null
                  : IconButton(
                      tooltip: '返回上一只仓鼠',
                      onPressed: _goBackInPedigree,
                      icon: const Icon(CupertinoIcons.back),
                    ),
              title: Text(
                _currentHamsterLabel == null
                    ? '血统档案'
                    : '血统档案 · $_currentHamsterLabel',
              ),
              actions: [
                IconButton(
                  key: const Key('pedigree-refresh'),
                  tooltip: '刷新',
                  onPressed: widget.controller.retry,
                  icon: const Icon(CupertinoIcons.arrow_clockwise),
                ),
              ],
            ),
            body: I2AsyncStateView<PedigreeGraph>(
              state: widget.controller.graphState,
              onRetry: widget.controller.retry,
              builder: (graph) {
                final rows = widget.controller.generations;
                final known = countKnownAncestors(rows);
                final filled = maxFilledGeneration(rows);
                // Keep the direct parent slots visible even without stored edges, so
                // the tree makes the missing father/mother relationship explicit.
                final visibleRows = graph.edges.isEmpty
                    ? rows.take(2).toList()
                    : rows;
                final descendants = listDirectDescendants(graph);
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    IosBanner(
                      icon: CupertinoIcons.info_circle,
                      color: IosColors.systemIndigo,
                      text: widget.canEdit
                          ? '空格「+」填入；已填格子可「替换 / 解除」（必须写纠错原因）。缺中间代会自动补档。'
                          : '血统遗传图：祖代在上、当前个体在下。点已知祖先可上溯；双指缩放。',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '向上 $filled 代 · 已识别祖先 $known 只'
                      '${descendants.isEmpty ? '' : ' · 直系后代 ${descendants.length} 只'}'
                      '${graph.commonAncestors.isEmpty ? '' : ' · 共同祖先 ${graph.commonAncestors.length}'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    if (graph.edges.isEmpty)
                      IosBanner(
                        icon: CupertinoIcons.arrow_up_right,
                        color: IosColors.systemOrange,
                        text:
                            '还没有父本或母本关系，所以目前只显示当前个体。繁育确认父母并完成个体化后，这里会自动展开。',
                        actionLabel: widget.onOpenBreeding == null
                            ? null
                            : '前往繁育',
                        onAction: widget.onOpenBreeding,
                      ),
                    if (graph.edges.isEmpty) const SizedBox(height: 12),
                    _ClassicPedigreeChart(
                      key: ValueKey(graph.rootHamsterId),
                      rows: visibleRows,
                      canEdit: widget.canEdit,
                      assigning: widget.controller.assigning,
                      onSlotTap: _onSlotTap,
                    ),
                    if (descendants.isNotEmpty) ...[
                      const SizedBox(height: IosMetrics.sectionGap),
                      _DescendantsSection(
                        nodes: descendants,
                        onOpen: _openAncestor,
                      ),
                    ],
                    if (graph.commonAncestors.isNotEmpty) ...[
                      const IosSectionHeader('共同祖先提示'),
                      IosGroupedSection(
                        margin: EdgeInsets.zero,
                        children: [
                          for (final a in graph.commonAncestors)
                            IosListTile(
                              leading: const IosGlyph(
                                icon: CupertinoIcons.share_up,
                                color: IosColors.systemIndigo,
                              ),
                              title:
                                  graph.nodeById[a.hamsterId]?.displayName ??
                                  '未命名祖先',
                              subtitle:
                                  '在血统中出现 ${a.paths} 次 · 最近第 ${a.minimumGeneration} 代',
                              showChevron: false,
                            ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Classic vertical pedigree genetic chart (ancestors ↑, proband ↓).
class _ClassicPedigreeChart extends StatelessWidget {
  const _ClassicPedigreeChart({
    super.key,
    required this.rows,
    required this.onSlotTap,
    this.canEdit = false,
    this.assigning = false,
  });

  final List<List<PedigreeTreeSlot>> rows;
  final Future<void> Function(PedigreeTreeSlot slot) onSlotTap;
  final bool canEdit;
  final bool assigning;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final layout = layoutClassicPedigreeChart(rows);
    // Viewport height scales with generations but stays glanceable.
    final viewportHeight = math.min(
      420.0,
      math.max(260.0, layout.canvasHeight + 8),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.arrow_branch, size: 16, color: palette.accent),
            const SizedBox(width: 6),
            Text(
              '血统遗传图',
              key: const Key('pedigree-tree-title'),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              canEdit ? '点空位填入 · 双指缩放' : '双指缩放 · 拖动画布',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          canEdit
              ? '空白格点一下就能选仓鼠或新建；爷爷/曾祖缺中间代时会自动补。'
              : '祖代在上 → 父本/母本分叉 → 当前个体在下（标准二分谱系）',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: palette.secondaryLabel,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          key: const Key('pedigree-tree'),
          height: viewportHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
            border: Border.all(
              color: palette.separator,
              width: IosMetrics.hairline,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                palette.accentSoft.withValues(alpha: 0.45),
                palette.tertiaryFill,
                palette.secondaryGroupedBackground,
              ],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  key: const Key('pedigree-chart-viewer'),
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(48),
                  minScale: 0.55,
                  maxScale: 2.4,
                  child: SizedBox(
                    width: layout.canvasWidth,
                    height: layout.canvasHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _ClassicPedigreeConnectorPainter(
                              edges: layout.edges,
                              lineColor: palette.accent.withValues(alpha: 0.55),
                              sireColor: IosColors.systemBlue.withValues(
                                alpha: 0.55,
                              ),
                              damColor: palette.accent.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                        for (var g = 0; g <= layout.maxGeneration; g++)
                          _generationRailLabel(
                            context: context,
                            layout: layout,
                            generation: g,
                          ),
                        for (final n in layout.nodes)
                          Positioned(
                            left: n.left,
                            top: n.top,
                            width: n.width,
                            height: n.height,
                            child: _PedigreeGeneticNode(
                              chartNode: n,
                              canEdit: canEdit,
                              onTap: () => onSlotTap(n.slot),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (assigning)
                Positioned.fill(
                  child: ColoredBox(
                    color: palette.groupedBackground.withValues(alpha: 0.45),
                    child: const Center(child: CupertinoActivityIndicator()),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _LegendChip(
              color: IosColors.systemBlue,
              label: '♂ 公',
              shape: BoxShape.rectangle,
            ),
            const SizedBox(width: 10),
            _LegendChip(
              color: palette.accent,
              label: '♀ 母',
              shape: BoxShape.circle,
            ),
            const SizedBox(width: 10),
            _LegendChip(
              color: palette.secondaryLabel,
              label: canEdit ? '+ 可填入' : '未知',
              shape: BoxShape.rectangle,
              dashed: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _generationRailLabel({
    required BuildContext context,
    required PedigreeChartLayout layout,
    required int generation,
  }) {
    // Find any node in this generation for Y.
    PedigreeChartNode? sample;
    for (final n in layout.nodes) {
      if (n.slot.generation == generation) {
        sample = n;
        break;
      }
    }
    if (sample == null) return const SizedBox.shrink();
    final label = switch (generation) {
      0 => '本代',
      1 => '父母',
      2 => '祖代',
      3 => '曾祖',
      _ => '第$generation代',
    };
    return Positioned(
      left: 4,
      top: sample.centerY - 8,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: ScolvPalette.of(context).tertiaryLabel,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _ClassicPedigreeConnectorPainter extends CustomPainter {
  const _ClassicPedigreeConnectorPainter({
    required this.edges,
    required this.lineColor,
    required this.sireColor,
    required this.damColor,
  });

  final List<PedigreeChartEdge> edges;
  final Color lineColor;
  final Color sireColor;
  final Color damColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Group edges by (childX, branchY) to draw one horizontal bar per pair.
    final groups = <String, List<PedigreeChartEdge>>{};
    for (final e in edges) {
      final key =
          '${e.childCenterX.toStringAsFixed(1)}_${e.branchY.toStringAsFixed(1)}';
      groups.putIfAbsent(key, () => <PedigreeChartEdge>[]).add(e);
    }

    for (final group in groups.values) {
      final childX = group.first.childCenterX;
      final childTop = group.first.childTopY;
      final branchY = group.first.branchY;

      double minX = childX;
      double maxX = childX;
      for (final e in group) {
        minX = math.min(minX, e.parentCenterX);
        maxX = math.max(maxX, e.parentCenterX);
      }

      final barPaint = Paint()
        ..color = lineColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Vertical up from child to branch bar.
      canvas.drawLine(
        Offset(childX, childTop),
        Offset(childX, branchY),
        barPaint,
      );
      // Horizontal bar spanning parents.
      canvas.drawLine(Offset(minX, branchY), Offset(maxX, branchY), barPaint);

      for (final e in group) {
        final paint = Paint()
          ..color = e.isSire ? sireColor : damColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        // Drop from bar to parent bottom.
        canvas.drawLine(
          Offset(e.parentCenterX, branchY),
          Offset(e.parentCenterX, e.parentBottomY),
          paint,
        );
        // Small joint dots.
        canvas.drawCircle(
          Offset(e.parentCenterX, branchY),
          2.5,
          Paint()..color = e.isSire ? sireColor : damColor,
        );
      }
      canvas.drawCircle(
        Offset(childX, branchY),
        2.5,
        Paint()..color = lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClassicPedigreeConnectorPainter oldDelegate) =>
      oldDelegate.edges != edges ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.sireColor != sireColor ||
      oldDelegate.damColor != damColor;
}

/// Compact genetic-chart cell: sex glyph + relationship + name / fill affordance.
class _PedigreeGeneticNode extends StatelessWidget {
  const _PedigreeGeneticNode({
    required this.chartNode,
    this.onTap,
    this.canEdit = false,
  });

  final PedigreeChartNode chartNode;
  final VoidCallback? onTap;
  final bool canEdit;

  PedigreeTreeSlot get slot => chartNode.slot;

  bool get _isRoot => slot.generation == 0;

  Color _sexColor(BuildContext context) {
    if (slot.isUnknown) {
      final role = slot.rolePath.isEmpty ? '' : slot.rolePath.last;
      if (role == 'sire') return IosColors.systemBlue;
      if (role == 'dam') return ScolvPalette.of(context).accent;
      return ScolvPalette.of(context).secondaryLabel;
    }
    final sex = slot.node?.sex.toLowerCase() ?? '';
    if (sex == 'male' || sex == 'm') return IosColors.systemBlue;
    if (sex == 'female' || sex == 'f') return ScolvPalette.of(context).accent;
    return ScolvPalette.of(context).secondaryLabel;
  }

  bool get _isMale {
    if (slot.isUnknown) {
      return slot.rolePath.isNotEmpty && slot.rolePath.last == 'sire';
    }
    final sex = slot.node?.sex.toLowerCase() ?? '';
    return sex == 'male' || sex == 'm';
  }

  bool get _isFemale {
    if (slot.isUnknown) {
      return slot.rolePath.isNotEmpty && slot.rolePath.last == 'dam';
    }
    final sex = slot.node?.sex.toLowerCase() ?? '';
    return sex == 'female' || sex == 'f';
  }

  String get _shortName {
    if (slot.isUnknown) return canEdit ? '点此填入' : '？';
    final n = slot.node!;
    final name = n.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return n.internalCode.isEmpty ? '未命名' : n.internalCode;
  }

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final unknown = slot.isUnknown;
    final sex = _sexColor(context);
    final relationship = pedigreeRelationshipLabel(slot.rolePath);
    final fillable = unknown && canEdit && !_isRoot;

    final card = Container(
      key: Key('pedigree-slot-${slot.generation}-${slot.rolePath.join('-')}'),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: unknown
            ? (fillable
                  ? sex.withValues(alpha: 0.06)
                  : palette.secondaryFill.withValues(alpha: 0.7))
            : (_isRoot
                  ? palette.accentSoft
                  : palette.secondaryGroupedBackground),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: fillable
              ? sex.withValues(alpha: 0.55)
              : (unknown
                    ? palette.separator
                    : sex.withValues(alpha: _isRoot ? 0.7 : 0.4)),
          width: _isRoot || fillable ? 2 : 1.2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        boxShadow: unknown
            ? null
            : [
                BoxShadow(
                  color: sex.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (fillable)
                Icon(CupertinoIcons.plus_circle_fill, size: 14, color: sex)
              else
                _SexGlyph(
                  isMale: _isMale,
                  isFemale: _isFemale,
                  unknown: unknown,
                  color: sex,
                ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  relationship,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: sex,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              _shortName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: unknown ? sex.withValues(alpha: 0.85) : palette.label,
                height: 1.15,
              ),
            ),
          ),
          if (!unknown &&
              slot.node!.varietyCode != null &&
              slot.node!.varietyCode!.trim().isNotEmpty)
            Text(
              slot.node!.varietyCode!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.tertiaryLabel,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return card;
    // Root known node: still tappable for consistency (no-op navigate).
    if (_isRoot && unknown) return card;
    return IosPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: card,
    );
  }
}

/// Ask for a non-empty correction reason (required for replace / end).
///
/// Thin wrapper over the shared sheet so the pedigree widget keys stay stable.
Future<String?> showPedigreeCorrectionReasonSheet({
  required BuildContext context,
  required String title,
  String hint = '请说明原因（会写入审计）',
}) => showCorrectionReasonSheet(
  context: context,
  title: title,
  keyPrefix: 'pedigree',
  hint: hint,
);

/// Simple fill sheet: quick name create + pick from existing roster.
Future<PedigreeNode?> showPedigreeFillSheet({
  required BuildContext context,
  required PedigreeFillTarget target,
  required List<I2Hamster> candidates,
  required Set<String> excludeIds,
  required Future<PedigreeNode> Function(String name) createNamed,
}) {
  final preferred = candidates.where((h) {
    if (excludeIds.contains(h.id)) return false;
    if (h.lifecycleStatus.toLowerCase() == 'archived') return false;
    if (target.preferredSex == 'male') {
      return h.sex == 'male' || h.sex == 'unknown';
    }
    if (target.preferredSex == 'female') {
      return h.sex == 'female' || h.sex == 'unknown';
    }
    return true;
  }).toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));

  final others = candidates.where((h) {
    if (excludeIds.contains(h.id)) return false;
    if (h.lifecycleStatus.toLowerCase() == 'archived') return false;
    return !preferred.any((p) => p.id == h.id);
  }).toList()
    ..sort((a, b) => a.displayName.compareTo(b.displayName));

  final nameCtrl = TextEditingController(text: target.label);
  var creating = false;

  return showCupertinoModalPopup<PedigreeNode>(
    context: context,
    builder: (ctx) {
      final p = ScolvPalette.of(ctx);
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return Container(
            key: const Key('pedigree-fill-sheet'),
            decoration: BoxDecoration(
              color: p.secondaryGroupedBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(IosMetrics.continuousRadius),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.62,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '填入「${target.label}」',
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        target.preferredSex == 'male'
                            ? '优先公鼠 · 点选下方一只，或输入名字一键新建'
                            : '优先母鼠 · 点选下方一只，或输入名字一键新建',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: p.secondaryLabel,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              key: const Key('pedigree-fill-name'),
                              controller: nameCtrl,
                              placeholder: '新名字',
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: p.secondaryFill,
                                borderRadius: BorderRadius.circular(
                                  IosMetrics.continuousRadius,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CupertinoButton.filled(
                            key: const Key('pedigree-fill-create'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            onPressed: creating
                                ? null
                                : () async {
                                    final name = nameCtrl.text.trim();
                                    if (name.isEmpty) return;
                                    setLocal(() => creating = true);
                                    try {
                                      final node = await createNamed(name);
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx, node);
                                      }
                                    } catch (_) {
                                      setLocal(() => creating = false);
                                    }
                                  },
                            child: creating
                                ? const CupertinoActivityIndicator()
                                : const Text('新建并填入'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '从已有仓鼠选择',
                        style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: preferred.isEmpty && others.isEmpty
                          ? const Center(child: Text('暂无可选档案，请上方新建'))
                          : ListView(
                              children: [
                                for (final h in preferred)
                                  IosListTile(
                                    key: Key('pedigree-fill-pick-${h.id}'),
                                    leading: IosGlyph(
                                      icon: CupertinoIcons.paw,
                                      color: h.sex == 'male'
                                          ? IosColors.systemBlue
                                          : (h.sex == 'female'
                                                ? IosColors.systemRed
                                                : p.secondaryLabel),
                                    ),
                                    title: h.displayName,
                                    subtitle: h.corePhenotypeLabel ?? h.sex,
                                    onTap: () => Navigator.pop(
                                      ctx,
                                      PedigreeNode(
                                        id: h.id,
                                        internalCode: h.internalCode,
                                        name: h.name,
                                        sex: h.sex,
                                        varietyCode: h.varietyCode,
                                      ),
                                    ),
                                  ),
                                if (others.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      4,
                                    ),
                                    child: Text(
                                      '其他性别（可能被服务端拒绝）',
                                      style: Theme.of(ctx)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(color: p.tertiaryLabel),
                                    ),
                                  ),
                                  for (final h in others)
                                    IosListTile(
                                      key: Key(
                                        'pedigree-fill-pick-other-${h.id}',
                                      ),
                                      leading: const IosGlyph(
                                        icon: CupertinoIcons.paw,
                                        color: IosColors.systemGray,
                                      ),
                                      title: h.displayName,
                                      subtitle: h.sex,
                                      onTap: () => Navigator.pop(
                                        ctx,
                                        PedigreeNode(
                                          id: h.id,
                                          internalCode: h.internalCode,
                                          name: h.name,
                                          sex: h.sex,
                                          varietyCode: h.varietyCode,
                                        ),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  ).whenComplete(nameCtrl.dispose);
}

class _SexGlyph extends StatelessWidget {
  const _SexGlyph({
    required this.isMale,
    required this.isFemale,
    required this.unknown,
    required this.color,
  });

  final bool isMale;
  final bool isFemale;
  final bool unknown;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Standard pedigree notation: male □, female ○
    if (unknown) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.2),
          borderRadius: BorderRadius.circular(2),
        ),
        alignment: Alignment.center,
        child: Text(
          '?',
          style: TextStyle(fontSize: 8, color: color, height: 1),
        ),
      );
    }
    if (isFemale) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.6),
          color: color.withValues(alpha: 0.12),
        ),
      );
    }
    // male or unknown-sex treated as square
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: color, width: 1.6),
        color: color.withValues(alpha: 0.12),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.color,
    required this.label,
    required this.shape,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final BoxShape shape;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: shape,
            borderRadius: shape == BoxShape.rectangle
                ? BorderRadius.circular(2)
                : null,
            border: Border.all(color: color, width: 1.4),
            color: dashed ? null : color.withValues(alpha: 0.12),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ScolvPalette.of(context).secondaryLabel,
          ),
        ),
      ],
    );
  }
}

/// 直系后代列表：点按下钻到该个体的血统树。
class _DescendantsSection extends StatelessWidget {
  const _DescendantsSection({required this.nodes, required this.onOpen});

  final List<PedigreeNode> nodes;
  final Future<void> Function(PedigreeNode node) onOpen;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.arrow_down_right, size: 16, color: p.accent),
            const SizedBox(width: 6),
            Text(
              '直系后代',
              key: const Key('pedigree-descendants-title'),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              '${nodes.length} 只',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 10),
        IosGroupedSection(
          margin: EdgeInsets.zero,
          children: [
            for (var i = 0; i < nodes.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: IosMetrics.hairline,
                  color: p.separator,
                ),
              IosListTile(
                key: Key('pedigree-descendant-${nodes[i].id}'),
                leading: IosGlyph(
                  icon: CupertinoIcons.paw,
                  color: switch (nodes[i].sex.toLowerCase()) {
                    'male' || 'm' => IosColors.systemBlue,
                    'female' || 'f' => IosColors.systemRed,
                    _ => p.secondaryLabel,
                  },
                ),
                title: nodes[i].displayName,
                subtitle: nodes[i].varietyCode ?? '点按查看其血统',
                onTap: () => onOpen(nodes[i]),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
