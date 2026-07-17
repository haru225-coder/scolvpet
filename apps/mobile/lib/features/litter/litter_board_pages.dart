import 'package:flutter/material.dart';

import '../i2/i2_models.dart';
import 'litter_board_controller.dart';
import 'litter_board_models.dart';

const _accent = Color(0xffc77852);
const _ink = Color(0xff1f2928);
const _muted = Color(0xff6c7774);

class LitterBoardListPage extends StatefulWidget {
  const LitterBoardListPage({
    super.key,
    required this.controller,
    required this.enclosures,
    this.canWrite = true,
    this.offline = false,
    this.lastSyncLabel,
  });

  final LitterBoardController controller;
  final List<I2Enclosure> enclosures;
  final bool canWrite;
  final bool offline;
  final String? lastSyncLabel;

  @override
  State<LitterBoardListPage> createState() => _LitterBoardListPageState();
}

class _LitterBoardListPageState extends State<LitterBoardListPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.refreshList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.listState;
        return Scaffold(
          appBar: AppBar(
            title: const Text('窝次'),
            actions: [
              IconButton(
                onPressed: widget.controller.refreshList,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              if (widget.offline)
                Material(
                  color: const Color(0xfffff3cd),
                  child: ListTile(
                    dense: true,
                    leading: const Icon(Icons.cloud_off, size: 18),
                    title: Text(
                      '离线只读${widget.lastSyncLabel == null ? '' : ' · ${widget.lastSyncLabel}'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              Expanded(child: _buildBody(state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(I2AsyncState<List<LitterBoard>> state) {
    switch (state.status) {
      case I2AsyncStatus.loading:
      case I2AsyncStatus.idle:
        return const Center(child: CircularProgressIndicator());
      case I2AsyncStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message ?? '加载失败'),
              TextButton(
                onPressed: widget.controller.refreshList,
                child: const Text('重试'),
              ),
            ],
          ),
        );
      case I2AsyncStatus.empty:
        return const Center(child: Text('暂无窝次记录'));
      case I2AsyncStatus.data:
        final litters = state.data ?? const <LitterBoard>[];
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: litters.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final litter = litters[index];
            final action = nextLitterAction(litter.state);
            return Card(
              key: Key('litter-card-${litter.id}'),
              child: ListTile(
                title: Text(litter.displayName),
                subtitle: Text(
                  '${litterBoardStateLabel(litter.state)} · '
                  '活仔 ${litter.currentManagedCount}/${litter.initialAliveCount}',
                ),
                trailing: action == null
                    ? Chip(label: Text(litterBoardStateLabel(litter.state)))
                    : Chip(
                        label: Text(litterActionLabel(action)),
                        backgroundColor: _accent.withValues(alpha: 0.15),
                      ),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => LitterBoardDetailPage(
                        controller: widget.controller,
                        litterId: litter.id,
                        enclosures: widget.enclosures,
                        canWrite: widget.canWrite,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      case I2AsyncStatus.conflict:
        return Center(child: Text(state.message ?? '冲突'));
    }
  }
}

class LitterBoardDetailPage extends StatefulWidget {
  const LitterBoardDetailPage({
    super.key,
    required this.controller,
    required this.litterId,
    required this.enclosures,
    this.canWrite = true,
  });

  final LitterBoardController controller;
  final String litterId;
  final List<I2Enclosure> enclosures;
  final bool canWrite;

  @override
  State<LitterBoardDetailPage> createState() => _LitterBoardDetailPageState();
}

class _LitterBoardDetailPageState extends State<LitterBoardDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.openLitter(widget.litterId);
    });
  }

  Future<void> _runAction(LitterBoard board) async {
    if (!widget.canWrite) {
      _toast('离线只读，联网后操作');
      return;
    }
    if (widget.enclosures.isEmpty) {
      _toast('需要至少一个笼盒用于分笼');
      return;
    }
    final enc = widget.enclosures.first.id;
    final ok = await widget.controller.runNextAction(
      maleEnclosureId: enc,
      femaleEnclosureId: widget.enclosures.length > 1
          ? widget.enclosures[1].id
          : enc,
    );
    if (!mounted) return;
    _toast(widget.controller.lastMessage ?? (ok ? '完成' : '失败'));
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final detail = widget.controller.detailState;
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(title: const Text('窝次详情')),
          body: switch (detail.status) {
            I2AsyncStatus.loading || I2AsyncStatus.idle => const Center(
              child: CircularProgressIndicator(),
            ),
            I2AsyncStatus.error => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(detail.message ?? '加载失败'),
                  TextButton(
                    onPressed: () =>
                        widget.controller.openLitter(widget.litterId),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
            _ => _buildDetail(detail.data, busy),
          },
        );
      },
    );
  }

  Widget _buildDetail(LitterBoard? board, bool busy) {
    if (board == null) {
      return const Center(child: Text('无数据'));
    }
    final action = nextLitterAction(board.state);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          board.displayName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${litterBoardStateLabel(board.state)} · 出生 ${board.bornAt.toLocal().toString().split('.').first}',
          style: const TextStyle(color: _muted),
        ),
        const SizedBox(height: 16),
        _StepRail(state: board.state),
        const SizedBox(height: 16),
        if (action != null)
          FilledButton(
            key: Key('litter-next-${board.id}'),
            onPressed: busy ? null : () => _runAction(board),
            child: Text(litterActionLabel(action)),
          )
        else
          const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text('窝次主路径已结束'),
              subtitle: Text('可在仓鼠列表查看个体化结果'),
            ),
          ),
        const SizedBox(height: 20),
        const Text(
          '幼崽',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (board.pups.isEmpty)
          const Text('暂无幼崽身份（可从服务端刷新）', style: TextStyle(color: _muted))
        else
          ...board.pups.map(
            (pup) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(pup.temporaryCode),
                subtitle: Text(
                  [
                    pup.outcomeStatus,
                    if (pup.sex != null) pup.sex!,
                    if (pup.weaned) '已断奶',
                    if (pup.sexAssigned) '已分性',
                    if (pup.individualized) '已建档',
                  ].join(' · '),
                ),
                trailing: pup.individualized
                    ? const Icon(Icons.pets, color: _accent)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.state});

  final String state;

  static const labels = ['带崽', '断奶', '分性', '个体化', '完成'];

  int get index {
    final action = nextLitterAction(state);
    if (state == 'closed') return 4;
    return switch (action) {
      LitterBoardAction.wean => 0,
      LitterBoardAction.sexAndSeparate => 1,
      LitterBoardAction.individualize => 2,
      null => state == 'closed' ? 4 : 3,
    };
  }

  @override
  Widget build(BuildContext context) {
    final current = index;
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: current >= i ? _accent : const Color(0xffdce5e3),
              ),
            ),
          Column(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: current >= i
                    ? _accent
                    : const Color(0xffdce5e3),
                foregroundColor: current >= i ? Colors.white : _muted,
                child: Text('${i + 1}', style: const TextStyle(fontSize: 10)),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 10,
                  color: current == i ? _ink : _muted,
                  fontWeight: current == i ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
