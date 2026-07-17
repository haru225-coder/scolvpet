import 'package:flutter/material.dart';

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
  });

  final PedigreeController controller;
  final String hamsterId;
  final String? hamsterLabel;
  final int generations;

  @override
  State<PedigreePage> createState() => _PedigreePageState();
}

class _PedigreePageState extends State<PedigreePage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load(
      widget.hamsterId,
      generationsDepth: widget.generations,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.hamsterLabel == null
                  ? '谱系'
                  : '谱系 · ${widget.hamsterLabel}',
            ),
            actions: [
              IconButton(
                key: const Key('pedigree-refresh'),
                tooltip: '刷新',
                onPressed: widget.controller.retry,
                icon: const Icon(Icons.refresh),
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
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  Text(
                    '向上 $filled 代祖先 · 已识别 $known 只'
                    '${graph.commonAncestors.isEmpty ? '' : ' · 共同祖先 ${graph.commonAncestors.length}'}',
                    style: const TextStyle(color: Color(0xff6c7774)),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < rows.length; i++) ...[
                    _GenerationHeader(
                      generation: i,
                      count: rows[i].where((s) => s.node != null).length,
                    ),
                    const SizedBox(height: 8),
                    _GenerationRow(slots: rows[i]),
                    const SizedBox(height: 16),
                  ],
                  if (graph.commonAncestors.isNotEmpty) ...[
                    const Text(
                      '共同祖先提示',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...graph.commonAncestors.map((a) {
                      final node = graph.nodeById[a.hamsterId];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.hub_outlined),
                          title: Text(node?.displayName ?? a.hamsterId),
                          subtitle: Text(
                            '路径 ${a.paths} · 最近第 ${a.minimumGeneration} 代',
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              );
            },
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
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Color(0xff1f2928),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$count 只',
          style: const TextStyle(color: Color(0xff6c7774), fontSize: 12),
        ),
      ],
    );
  }
}

class _GenerationRow extends StatelessWidget {
  const _GenerationRow({required this.slots});

  final List<PedigreeTreeSlot> slots;

  @override
  Widget build(BuildContext context) {
    // Wrap so wide generations (8+ slots) remain readable.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final slot in slots)
          SizedBox(
            width: slots.length <= 2
                ? (MediaQuery.sizeOf(context).width - 48) / 2
                : slots.length <= 4
                ? (MediaQuery.sizeOf(context).width - 56) / 2
                : 150,
            child: _AncestorCard(slot: slot),
          ),
      ],
    );
  }
}

class _AncestorCard extends StatelessWidget {
  const _AncestorCard({required this.slot});

  final PedigreeTreeSlot slot;

  Color get _sexColor {
    final sex = slot.node?.sex.toLowerCase() ?? '';
    if (sex == 'male' || sex == 'm') return const Color(0xff4a7c9b);
    if (sex == 'female' || sex == 'f') return const Color(0xffc77852);
    return const Color(0xff6c7774);
  }

  @override
  Widget build(BuildContext context) {
    final unknown = slot.isUnknown;
    return Card(
      key: Key(
        'pedigree-slot-${slot.generation}-${slot.rolePath.join('-')}',
      ),
      color: unknown ? const Color(0xfff0f2f1) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _sexColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    slot.generation == 0 ? '本代' : slot.roleLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _sexColor,
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
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xff6c7774),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              unknown ? '未知' : slot.node!.displayName,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: unknown
                    ? const Color(0xff6c7774)
                    : const Color(0xff1f2928),
              ),
            ),
            if (!unknown && slot.node!.varietyCode != null) ...[
              const SizedBox(height: 4),
              Text(
                slot.node!.varietyCode!,
                style: const TextStyle(fontSize: 12, color: Color(0xff6c7774)),
              ),
            ],
            if (slot.edge?.evidenceType != null) ...[
              const SizedBox(height: 4),
              Text(
                '证据 ${slot.edge!.evidenceType}',
                style: const TextStyle(fontSize: 11, color: Color(0xff6c7774)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
