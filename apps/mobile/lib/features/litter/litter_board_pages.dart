import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'litter_board_controller.dart';
import 'litter_board_models.dart';

Color _litterStateColor(BuildContext context, LitterBoard litter) {
  if (litter.state == 'closed') return IosColors.systemGreen;
  if (litter.state == 'voided') return IosColors.systemRed;
  if (nextLitterAction(litter.state) != null) {
    return ScolvPalette.of(context).accent;
  }
  return IosColors.systemBlue;
}

String _litterListStatus(LitterBoard litter) {
  final action = nextLitterAction(litter.state);
  return action == null
      ? litterBoardStateLabel(litter.state)
      : litterActionLabel(action);
}

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.listState;
        final loading = state.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('窝次'),
            actions: [
              IconButton(
                tooltip: '刷新窝次',
                onPressed: loading ? null : widget.controller.refreshList,
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          body: Column(
            children: [
              if (widget.offline)
                I2OfflineBanner(
                  offline: true,
                  lastSyncLabel: widget.lastSyncLabel,
                ),
              if (!widget.canWrite && !widget.offline)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看窝次记录，分笼与阶段推进已设为只读。',
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
        return const IosLoading();
      case I2AsyncStatus.error:
        return I2StateMessage(
          icon: CupertinoIcons.cloud,
          message: state.message ?? '加载失败',
          actionLabel: '重试',
          onRetry: widget.controller.refreshList,
          tone: IosColors.systemRed,
        );
      case I2AsyncStatus.empty:
        return const I2StateMessage(
          icon: CupertinoIcons.person_3,
          message: '暂无窝次记录',
          subtitle: '产仔确认后，窝次会按日龄与阶段出现在这里。',
          mood: BearMood.sleepy,
          illustration: BearAssets.emptyList,
        );
      case I2AsyncStatus.data:
        final litters = state.data ?? const <LitterBoard>[];
        return RefreshIndicator.adaptive(
          onRefresh: widget.controller.refreshList,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              IosGroupedSection(
                children: [
                  for (final litter in litters)
                    IosListTile(
                      key: Key('litter-card-${litter.id}'),
                      leading: IosGlyph(
                        icon: CupertinoIcons.person_3_fill,
                        color: _litterStateColor(context, litter),
                      ),
                      title: litter.displayName,
                      subtitle:
                          '${litterBoardStateLabel(litter.state)} · '
                          '在管 ${litter.currentManagedCount} 只 · '
                          '初始 ${litter.initialAliveCount} 只',
                      trailing: IosStatusBadge(
                        label: _litterListStatus(litter),
                        color: _litterStateColor(context, litter),
                      ),
                      onTap: () {
                        Navigator.of(context).push<void>(
                          iosPageRoute(
                            builder: (_) => LitterBoardDetailPage(
                              controller: widget.controller,
                              litterId: litter.id,
                              enclosures: widget.enclosures,
                              canWrite: widget.canWrite,
                              offline: widget.offline,
                              lastSyncLabel: widget.lastSyncLabel,
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      case I2AsyncStatus.conflict:
        return I2StateMessage(
          icon: CupertinoIcons.exclamationmark_triangle,
          message: state.message ?? '冲突',
          tone: IosColors.systemOrange,
        );
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
    this.offline = false,
    this.lastSyncLabel,
  });

  final LitterBoardController controller;
  final String litterId;
  final List<I2Enclosure> enclosures;
  final bool canWrite;
  final bool offline;
  final String? lastSyncLabel;

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
      _toast('当前状态为只读，暂不能推进窝次');
      return;
    }
    final action = nextLitterAction(board.state);
    if (action == null) return;

    List<LitterPupSeparation> separations = const [];
    List<LitterPupProfileDraft> profiles = const [];
    switch (action) {
      case LitterBoardAction.wean:
        final confirmed = await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('确认断奶'),
            content: Text(
              '将为 ${board.alivePups.length} 只存活幼崽记录断奶，完成后进入分性分笼阶段。',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('暂不操作'),
              ),
              CupertinoDialogAction(
                key: const Key('litter-confirm-wean'),
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: const Text('确认断奶'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        break;
      case LitterBoardAction.sexAndSeparate:
        if (widget.enclosures.isEmpty) {
          _toast('请先建立可用笼盒，再进行分性分笼');
          return;
        }
        final result = await Navigator.of(context)
            .push<List<LitterPupSeparation>>(
              iosPageRoute(
                builder: (_) => _LitterSexSeparationPage(
                  board: board,
                  enclosures: widget.enclosures,
                ),
              ),
            );
        if (result == null) return;
        separations = result;
        break;
      case LitterBoardAction.individualize:
        final result = await Navigator.of(context)
            .push<List<LitterPupProfileDraft>>(
              iosPageRoute(
                builder: (_) => _LitterIndividualizationPage(board: board),
              ),
            );
        if (result == null) return;
        profiles = result;
        break;
    }
    if (!mounted) return;
    final ok = await widget.controller.runNextAction(
      separations: separations,
      profiles: profiles,
    );
    if (!mounted) return;
    _toast(widget.controller.lastMessage ?? (ok ? '完成' : '失败'));
  }

  void _toast(String message) {
    showIosMessage(context, message);
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
          appBar: AppBar(
            title: const Text('窝次详情'),
            actions: [
              IconButton(
                tooltip: '刷新窝次',
                onPressed: busy
                    ? null
                    : () => widget.controller.openLitter(widget.litterId),
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          body: Column(
            children: [
              if (widget.offline)
                I2OfflineBanner(
                  offline: true,
                  lastSyncLabel: widget.lastSyncLabel,
                ),
              Expanded(
                child: switch (detail.status) {
                  I2AsyncStatus.loading ||
                  I2AsyncStatus.idle => const IosLoading(),
                  I2AsyncStatus.error => I2StateMessage(
                    icon: CupertinoIcons.cloud,
                    message: detail.message ?? '加载失败',
                    actionLabel: '重试',
                    onRetry: () =>
                        widget.controller.openLitter(widget.litterId),
                    tone: IosColors.systemRed,
                  ),
                  _ => _buildDetail(detail.data, busy),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetail(LitterBoard? board, bool busy) {
    if (board == null) {
      return const I2StateMessage(icon: CupertinoIcons.tray, message: '无数据');
    }
    final action = nextLitterAction(board.state);
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IosLargeTitle(
            board.displayName,
            subtitle:
                '${litterBoardStateLabel(board.state)} · ${board.bornAt.month}月${board.bornAt.day}日出生',
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _StepRail(state: board.state),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildNextStep(board, action, busy),
        ),
        const SizedBox(height: 16),
        IosGroupedSection(
          children: [
            IosListTile(
              leading: const IosGlyph(
                icon: CupertinoIcons.number,
                color: IosColors.systemBlue,
              ),
              title: '幼崽数量',
              subtitle: '初始 ${board.initialAliveCount} 只',
              trailing: Text('在管 ${board.currentManagedCount} 只'),
              showChevron: false,
            ),
            IosListTile(
              leading: const IosGlyph(
                icon: CupertinoIcons.calendar,
                color: IosColors.systemOrange,
              ),
              title: '出生日期',
              trailing: Text(
                '${board.bornAt.year}年${board.bornAt.month}月${board.bornAt.day}日',
              ),
              showChevron: false,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const IosSectionHeader('幼崽'),
        if (board.pups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '尚未同步到幼崽明细，请点右上角刷新再次检查。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          IosGroupedSection(
            children: [
              for (final pup in board.pups)
                IosListTile(
                  leading: IosGlyph(
                    icon: pup.individualized
                        ? CupertinoIcons.paw_solid
                        : CupertinoIcons.person,
                    color: pup.individualized
                        ? ScolvPalette.of(context).accent
                        : IosColors.systemTeal,
                  ),
                  title: pup.temporaryCode,
                  subtitle: [
                    litterPupOutcomeLabel(pup.outcomeStatus),
                    litterPupSexLabel(pup.sex),
                    if (pup.weaned) '已断奶',
                    if (pup.sexAssigned) '已分性',
                    if (pup.individualized) '已建档',
                  ].join(' · '),
                  showChevron: false,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildNextStep(
    LitterBoard board,
    LitterBoardAction? action,
    bool busy,
  ) {
    if (action != null && widget.canWrite) {
      return IosPrimaryButton(
        key: Key('litter-next-${board.id}'),
        label: litterActionLabel(action),
        onPressed: busy ? null : () => _runAction(board),
      );
    }
    if (action != null) {
      return const IosBanner(
        icon: CupertinoIcons.lock_shield,
        color: IosColors.systemOrange,
        text: '当前角色可查看这一窝，但阶段操作已设为只读。',
      );
    }
    final terminal = isLitterTerminal(board.state);
    return IosBanner(
      icon: terminal
          ? CupertinoIcons.checkmark_seal_fill
          : CupertinoIcons.clock,
      color: terminal ? IosColors.systemGreen : IosColors.systemBlue,
      text: litterWaitingMessage(board.state),
    );
  }
}

class _LitterSexSeparationPage extends StatefulWidget {
  const _LitterSexSeparationPage({
    required this.board,
    required this.enclosures,
  });

  final LitterBoard board;
  final List<I2Enclosure> enclosures;

  @override
  State<_LitterSexSeparationPage> createState() =>
      _LitterSexSeparationPageState();
}

class _LitterSexSeparationPageState extends State<_LitterSexSeparationPage> {
  final Map<String, String?> _sexByPup = {};
  final Map<String, String?> _enclosureByPup = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    final enclosureIds = widget.enclosures.map((e) => e.id).toSet();
    for (final pup in widget.board.alivePups) {
      _sexByPup[pup.id] = pup.sex == 'male' || pup.sex == 'female'
          ? pup.sex
          : null;
      _enclosureByPup[pup.id] =
          enclosureIds.contains(pup.destinationEnclosureId)
          ? pup.destinationEnclosureId
          : null;
    }
  }

  void _setSex(LitterPup pup, String sex) {
    setState(() {
      _sexByPup[pup.id] = sex;
      _error = null;
      if (_enclosureByPup[pup.id] == null) {
        final preferredIndex = sex == 'female' && widget.enclosures.length > 1
            ? 1
            : 0;
        _enclosureByPup[pup.id] = widget.enclosures[preferredIndex].id;
      }
    });
  }

  void _submit() {
    final assignments = <LitterPupSeparation>[];
    for (final pup in widget.board.alivePups) {
      final sex = _sexByPup[pup.id];
      final enclosureId = _enclosureByPup[pup.id];
      if (sex == null || enclosureId == null) {
        setState(() => _error = '请为每只存活幼崽选择性别和目标笼盒');
        return;
      }
      assignments.add(
        LitterPupSeparation(
          pupIdentityId: pup.id,
          sex: sex,
          destinationEnclosureId: enclosureId,
          requiresRecheck: sex == 'unknown',
        ),
      );
    }

    final confirmedSexesByEnclosure = <String, Set<String>>{};
    for (final assignment in assignments) {
      if (assignment.sex == 'unknown') continue;
      confirmedSexesByEnclosure
          .putIfAbsent(assignment.destinationEnclosureId, () => <String>{})
          .add(assignment.sex);
    }
    if (confirmedSexesByEnclosure.values.any((sexes) => sexes.length > 1)) {
      setState(() => _error = '同一笼盒不能混合已确认的公母幼崽');
      return;
    }
    Navigator.pop(context, assignments);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分性分笼')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  const IosBanner(
                    icon: CupertinoIcons.info_circle,
                    color: IosColors.systemBlue,
                    text: '逐只确认性别与目标笼盒。暂时看不准时请选择“待复核”，后续需复核后才能个体化建档。',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    IosBanner(
                      icon: CupertinoIcons.exclamationmark_triangle,
                      color: IosColors.systemRed,
                      text: _error!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final pup in widget.board.alivePups) ...[
                    Container(
                      key: Key('litter-separation-${pup.id}'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ScolvPalette.of(
                          context,
                        ).secondaryGroupedBackground,
                        borderRadius: BorderRadius.circular(
                          IosMetrics.continuousRadius,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            pup.temporaryCode,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          CupertinoSlidingSegmentedControl<String>(
                            groupValue: _sexByPup[pup.id],
                            thumbColor: ScolvPalette.of(
                              context,
                            ).secondaryGroupedBackground,
                            backgroundColor: ScolvPalette.of(
                              context,
                            ).tertiaryFill,
                            onValueChanged: (value) {
                              if (value != null) _setSex(pup, value);
                            },
                            children: const {
                              'male': Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text('公'),
                              ),
                              'female': Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text('母'),
                              ),
                              'unknown': Padding(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Text('待复核'),
                              ),
                            },
                          ),
                          const SizedBox(height: 10),
                          IosPickerField<String>(
                            key: Key('litter-enclosure-${pup.id}'),
                            label: '目标笼盒',
                            items: [
                              for (final enclosure in widget.enclosures)
                                IosPickerItem(
                                  value: enclosure.id,
                                  label: enclosure.code,
                                ),
                            ],
                            selected: _enclosureByPup[pup.id],
                            onSelected: (value) {
                              setState(() {
                                _enclosureByPup[pup.id] = value;
                                _error = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: IosPrimaryButton(
                  key: const Key('litter-separation-submit'),
                  label: '确认分性分笼',
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LitterIndividualizationPage extends StatefulWidget {
  const _LitterIndividualizationPage({required this.board});

  final LitterBoard board;

  @override
  State<_LitterIndividualizationPage> createState() =>
      _LitterIndividualizationPageState();
}

class _LitterIndividualizationPageState
    extends State<_LitterIndividualizationPage> {
  final Map<String, TextEditingController> _codeCtrls = {};
  final Map<String, TextEditingController> _nameCtrls = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    final code = widget.board.code?.trim();
    final prefix = code != null && code.isNotEmpty
        ? code
        : '${widget.board.bornAt.year}'
              '${widget.board.bornAt.month.toString().padLeft(2, '0')}'
              '${widget.board.bornAt.day.toString().padLeft(2, '0')}';
    for (final pup in widget.board.alivePups) {
      _codeCtrls[pup.id] = TextEditingController(
        text: '$prefix-${pup.temporaryCode}',
      );
      _nameCtrls[pup.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in [..._codeCtrls.values, ..._nameCtrls.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final profiles = <LitterPupProfileDraft>[];
    final codes = <String>[];
    for (final pup in widget.board.alivePups) {
      final code = _codeCtrls[pup.id]!.text.trim();
      final name = _nameCtrls[pup.id]!.text.trim();
      if (code.isEmpty) {
        setState(() => _error = '${pup.temporaryCode} 的仓鼠编号不能为空');
        return;
      }
      if (code.length > 64) {
        setState(() => _error = '${pup.temporaryCode} 的仓鼠编号不能超过 64 个字符');
        return;
      }
      codes.add(code);
      profiles.add(
        LitterPupProfileDraft(
          pupIdentityId: pup.id,
          internalCode: code,
          name: name.isEmpty ? null : name,
        ),
      );
    }
    if (codes.toSet().length != codes.length) {
      setState(() => _error = '同一窝内的仓鼠编号不能重复');
      return;
    }
    Navigator.pop(context, profiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个体化建档')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  const IosBanner(
                    icon: CupertinoIcons.doc_text,
                    color: IosColors.systemBlue,
                    text: '确认后会为每只存活幼崽建立正式仓鼠档案，并自动写入父母与窝次关系。',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    IosBanner(
                      icon: CupertinoIcons.exclamationmark_triangle,
                      color: IosColors.systemRed,
                      text: _error!,
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final pup in widget.board.alivePups) ...[
                    Container(
                      key: Key('litter-profile-${pup.id}'),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ScolvPalette.of(
                          context,
                        ).secondaryGroupedBackground,
                        borderRadius: BorderRadius.circular(
                          IosMetrics.continuousRadius,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '${pup.temporaryCode} · ${litterPupSexLabel(pup.sex)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          const _LitterFieldLabel('仓鼠编号'),
                          const SizedBox(height: 6),
                          CupertinoTextField(
                            key: Key('litter-profile-code-${pup.id}'),
                            controller: _codeCtrls[pup.id],
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() => _error = null),
                          ),
                          const SizedBox(height: 12),
                          const _LitterFieldLabel('名字（可选）'),
                          const SizedBox(height: 6),
                          CupertinoTextField(
                            key: Key('litter-profile-name-${pup.id}'),
                            controller: _nameCtrls[pup.id],
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() => _error = null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: IosPrimaryButton(
                  key: const Key('litter-profile-submit'),
                  label: '建立仓鼠档案',
                  onPressed: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LitterFieldLabel extends StatelessWidget {
  const _LitterFieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.state});

  final String state;

  static const labels = ['带崽', '断奶', '分性', '个体化', '完成'];

  int get index => switch (state) {
    'litter_nursing' || 'nursing' || 'newborn' => 0,
    'weaning_due' => 1,
    'sexing_due' || 'sex_separation_due' => 2,
    'individualizing' => 3,
    'closed' => 4,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final current = index;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 360 ? 360.0 : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Row(
              children: [
                for (var i = 0; i < labels.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: current >= i
                            ? ScolvPalette.of(context).accent
                            : ScolvPalette.of(context).tertiaryFill,
                      ),
                    ),
                  Column(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: current >= i
                              ? ScolvPalette.of(context).accent
                              : ScolvPalette.of(context).tertiaryFill,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: current >= i
                                ? Colors.white
                                : ScolvPalette.of(context).secondaryLabel,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: current == i
                              ? ScolvPalette.of(context).label
                              : ScolvPalette.of(context).secondaryLabel,
                          fontWeight: current == i
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
