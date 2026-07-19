import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_widgets.dart';
import 'pedigree_controller.dart';
import 'pedigree_models.dart';

/// Read-only multi-generation pedigree view (T-P0-07).
class PedigreePage extends StatefulWidget {
  const PedigreePage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.hamsterLabel,
    this.generations = 3,
    this.onOpenBreeding,
  });

  final PedigreeController controller;
  final String hamsterId;
  final String? hamsterLabel;
  final int generations;
  final VoidCallback? onOpenBreeding;

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
                    ? '谱系'
                    : '谱系 · $_currentHamsterLabel',
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
                // Always render the requested depth so empty higher generations stay
                // discoverable; collapse only when the graph truly has no edges.
                final visibleRows = graph.edges.isEmpty
                    ? rows.take(1).toList()
                    : rows;
                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    const IosBanner(
                      icon: CupertinoIcons.info_circle,
                      color: IosColors.systemIndigo,
                      text: '谱系从当前仓鼠向上展示父系、母系和多代祖先。点按已知祖先可继续查看它的谱系。',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '向上 $filled 代祖先 · 已识别 $known 只'
                      '${graph.commonAncestors.isEmpty ? '' : ' · 共同祖先 ${graph.commonAncestors.length}'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    if (graph.edges.isEmpty)
                      IosBanner(
                        icon: CupertinoIcons.arrow_up_right,
                        color: IosColors.systemOrange,
                        text: '还没有父本或母本关系，所以目前只显示本人。繁育计划确认父母并完成个体化后，这里会自动展开。',
                        actionLabel: widget.onOpenBreeding == null
                            ? null
                            : '前往繁育',
                        onAction: widget.onOpenBreeding,
                      ),
                    if (graph.edges.isEmpty) const SizedBox(height: 12),
                    for (var i = 0; i < visibleRows.length; i++) ...[
                      _GenerationHeader(
                        generation: i,
                        count: visibleRows[i]
                            .where((s) => s.node != null)
                            .length,
                      ),
                      const SizedBox(height: 8),
                      _GenerationRow(
                        slots: visibleRows[i],
                        onOpenAncestor: _openAncestor,
                      ),
                      const SizedBox(height: 16),
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
                                  '在谱系中出现 ${a.paths} 次 · 最近第 ${a.minimumGeneration} 代',
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

class _GenerationHeader extends StatelessWidget {
  const _GenerationHeader({required this.generation, required this.count});

  final int generation;
  final int count;

  @override
  Widget build(BuildContext context) {
    final label = switch (generation) {
      0 => '本代',
      1 => '父母（第 1 代）',
      2 => '祖父母（第 2 代）',
      3 => '曾祖（第 3 代）',
      _ => '第 $generation 代祖先',
    };
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: ScolvPalette.of(context).label,
          ),
        ),
        const SizedBox(width: 8),
        Text('$count 只', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _GenerationRow extends StatelessWidget {
  const _GenerationRow({required this.slots, required this.onOpenAncestor});

  final List<PedigreeTreeSlot> slots;
  final Future<void> Function(PedigreeNode node) onOpenAncestor;

  @override
  Widget build(BuildContext context) {
    if (slots.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: _AncestorCard(slot: slots.single),
      );
    }
    if (slots.length == 2) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _AncestorCard(
                slot: slots[i],
                onTap: slots[i].node == null
                    ? null
                    : () => onOpenAncestor(slots[i].node!),
              ),
            ),
          ],
        ],
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < slots.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            SizedBox(
              width: 148,
              child: _AncestorCard(
                slot: slots[i],
                onTap: slots[i].node == null
                    ? null
                    : () => onOpenAncestor(slots[i].node!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AncestorCard extends StatelessWidget {
  const _AncestorCard({required this.slot, this.onTap});

  final PedigreeTreeSlot slot;
  final VoidCallback? onTap;

  Color _sexColor(BuildContext context) {
    final sex = slot.node?.sex.toLowerCase() ?? '';
    if (sex == 'male' || sex == 'm') return IosColors.systemBlue;
    if (sex == 'female' || sex == 'f') return ScolvPalette.of(context).accent;
    return ScolvPalette.of(context).secondaryLabel;
  }

  @override
  Widget build(BuildContext context) {
    final unknown = slot.isUnknown;
    final card = Container(
      key: Key('pedigree-slot-${slot.generation}-${slot.rolePath.join('-')}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unknown
            ? ScolvPalette.of(context).tertiaryFill
            : ScolvPalette.of(context).secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(
          color: ScolvPalette.of(context).separator,
          width: IosMetrics.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _sexColor(context).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  slot.generation == 0 ? '本代' : slot.roleLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _sexColor(context),
                  ),
                ),
              ),
              if (slot.generation > 0) ...[
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    slot.pathLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            unknown ? '未知' : slot.node!.displayName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: unknown
                  ? ScolvPalette.of(context).secondaryLabel
                  : ScolvPalette.of(context).label,
            ),
          ),
          if (!unknown && slot.node!.varietyCode != null) ...[
            const SizedBox(height: 4),
            Text(
              slot.node!.varietyCode!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (slot.edge?.evidenceType != null) ...[
            const SizedBox(height: 4),
            Text(
              pedigreeEvidenceLabel(slot.edge!.evidenceType),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
          if (onTap != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '查看这只仓鼠的谱系',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ScolvPalette.of(context).accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 14,
                  color: ScolvPalette.of(context).accent,
                ),
              ],
            ),
          ],
        ],
      ),
    );
    if (onTap == null) return card;
    return IosPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: card,
    );
  }
}
