import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/bear_brand.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../genetic/genetic.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'breeding_controller.dart';
import 'breeding_models.dart';

String _breedingHamsterLabel(List<I2Hamster> hamsters, String id, String role) {
  for (final hamster in hamsters) {
    if (hamster.id == id) return hamster.displayName;
  }
  return role;
}

/// P0-5: 繁育工作流 Hub（进度 / 计划 + 窝次入口）。
class BreedingHubPage extends StatefulWidget {
  const BreedingHubPage({
    super.key,
    required this.controller,
    required this.hamsters,
    required this.enclosures,
    required this.ruleVersionId,
    required this.onOpenLitters,
    this.canWrite = true,
    this.geneticRepository,
    this.onOpenGenetic,
  });

  final BreedingController controller;
  final List<I2Hamster> hamsters;
  final List<I2Enclosure> enclosures;
  final String? ruleVersionId;
  final VoidCallback onOpenLitters;
  final bool canWrite;
  final GeneticRepository? geneticRepository;
  final void Function({GeneticHubPrefill? prefill})? onOpenGenetic;

  @override
  State<BreedingHubPage> createState() => _BreedingHubPageState();
}

class _BreedingHubPageState extends State<BreedingHubPage> {
  /// 0 = 进度, 1 = 窝次, 2 = 计划（对齐视觉草稿三段）
  int _segment = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.refresh();
  }

  void _openWizard({BreedingPlan? plan}) {
    if (plan != null) widget.controller.select(plan);
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => BreedingWizardPage(
          controller: widget.controller,
          hamsters: widget.hamsters,
          enclosures: widget.enclosures,
          ruleVersionId: widget.ruleVersionId,
          canWrite: widget.canWrite,
          onOpenLitters: widget.onOpenLitters,
          geneticRepository: widget.geneticRepository,
          onOpenGenetic: widget.onOpenGenetic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final listState = widget.controller.listState;
        final plans = listState.data ?? const <BreedingPlan>[];
        return RefreshIndicator(
          color: p.accent,
          onRefresh: () => widget.controller.refresh(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 0),
                child: IosLargeTitle(
                  '繁育',
                  subtitle: '当前进行中的配对、孕期与窝次',
                  trailing: IconButton(
                    key: const Key('breeding-hub-open-wizard'),
                    tooltip: widget.canWrite ? '新建繁育计划' : '打开繁育向导',
                    onPressed: () => _openWizard(),
                    icon: Icon(
                      widget.canWrite
                          ? CupertinoIcons.plus_circle
                          : CupertinoIcons.calendar,
                      color: p.accent,
                    ),
                  ),
                ),
              ),
              if (!widget.canWrite) ...[
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看繁育与窝次记录，新增计划和状态推进已设为只读。',
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('进度')),
                    ButtonSegment(value: 1, label: Text('窝次')),
                    ButtonSegment(value: 2, label: Text('计划')),
                  ],
                  selected: {_segment},
                  onSelectionChanged: (s) => setState(() => _segment = s.first),
                ),
              ),
              if (_segment == 1)
                _BreedingLittersSegment(
                  onOpenLitters: widget.onOpenLitters,
                )
              else if (listState.status == I2AsyncStatus.loading &&
                  !listState.hasValue)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: IosLoading(showSkeleton: true),
                )
              else if (listState.status == I2AsyncStatus.error)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: IosBanner(
                    icon: CupertinoIcons.exclamationmark_circle,
                    color: IosColors.systemRed,
                    text: listState.message ?? '繁育计划加载失败',
                    actionLabel: '重试',
                    onAction: () => widget.controller.refresh(),
                  ),
                )
              else if (_segment == 0)
                _BreedingProgressBody(
                  plans: plans,
                  hamsters: widget.hamsters,
                  onOpenPlan: (plan) => _openWizard(plan: plan),
                  onOpenLitters: widget.onOpenLitters,
                  onCreate: widget.canWrite ? () => _openWizard() : null,
                )
              else
                _BreedingPlansBody(
                  plans: plans,
                  hamsters: widget.hamsters,
                  onOpenPlan: (plan) => _openWizard(plan: plan),
                  onCreate: widget.canWrite ? () => _openWizard() : null,
                  onOpenGenetic: widget.onOpenGenetic,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 窝次分段：入口卡片，复用既有窝次看板（不重造领域）。
class _BreedingLittersSegment extends StatelessWidget {
  const _BreedingLittersSegment({required this.onOpenLitters});

  final VoidCallback onOpenLitters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: BearEmptyCard(
        key: const Key('breeding-hub-open-litters'),
        mood: BearMood.happy,
        illustration: BearAssets.emptyList,
        title: '窝次管理',
        subtitle: '查看育仔进度、日龄与分窝节点；记录在窝次看板中维护。',
        actionLabel: '打开窝次看板',
        onAction: onOpenLitters,
      ),
    );
  }
}

bool _isActiveBreedingState(String state) {
  switch (state) {
    case 'draft':
    case 'pair_ready':
    case 'pairing':
    case 'post_pair':
    case 'gestation':
    case 'litter_nursing':
    case 'weaning_due':
    case 'sex_separation_due':
    case 'individualizing':
    case 'hold':
      return true;
    default:
      return false;
  }
}

/// 展示用分组：仅 UI 分组，state 文案走 breedingStateLabel（权威）。
String _progressGroupKey(String state) {
  switch (state) {
    case 'draft':
    case 'pair_ready':
      return 'todo';
    case 'pairing':
      return 'pairing';
    case 'post_pair':
      return 'post_pair';
    case 'gestation':
      return 'gestation';
    case 'litter_nursing':
    case 'weaning_due':
    case 'sex_separation_due':
    case 'individualizing':
      return 'litter';
    case 'hold':
      return 'hold';
    default:
      return 'other';
  }
}

String _progressGroupTitle(String key) => switch (key) {
  'todo' => '需要处理',
  'pairing' => '配对中',
  'post_pair' => '已分笼',
  'gestation' => '孕期',
  'litter' => '育仔 / 窝次阶段',
  'hold' => '挂起',
  _ => '其他进行中',
};

int _progressGroupOrder(String key) => switch (key) {
  'todo' => 0,
  'pairing' => 1,
  'post_pair' => 2,
  'gestation' => 3,
  'litter' => 4,
  'hold' => 5,
  _ => 9,
};

class _BreedingProgressBody extends StatelessWidget {
  const _BreedingProgressBody({
    required this.plans,
    required this.hamsters,
    required this.onOpenPlan,
    required this.onOpenLitters,
    this.onCreate,
  });

  final List<BreedingPlan> plans;
  final List<I2Hamster> hamsters;
  final ValueChanged<BreedingPlan> onOpenPlan;
  final VoidCallback onOpenLitters;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final active = plans.where((p) => _isActiveBreedingState(p.state)).toList();
    final grouped = <String, List<BreedingPlan>>{};
    for (final plan in active) {
      final key = _progressGroupKey(plan.state);
      grouped.putIfAbsent(key, () => []).add(plan);
    }
    final keys = grouped.keys.toList()
      ..sort((a, b) => _progressGroupOrder(a).compareTo(_progressGroupOrder(b)));

    final pairing = active.where((p) => p.state == 'pairing').length;
    final gestation = active.where((p) => p.state == 'gestation').length;
    final litter = active
        .where(
          (p) => const {
            'litter_nursing',
            'weaning_due',
            'sex_separation_due',
            'individualizing',
          }.contains(p.state),
        )
        .length;
    final todo = active
        .where((p) => p.state == 'draft' || p.state == 'pair_ready')
        .length;

    if (active.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: BearEmptyCard(
          key: const Key('breeding-progress-empty'),
          title: '当前没有进行中的繁育',
          subtitle: '新建繁育计划后，这里会按配对、孕期和窝次阶段展示进度。',
          mood: BearMood.sleepy,
          illustration: BearAssets.emptyList,
          actionLabel: onCreate == null ? '打开窝次看板' : '新建繁育计划',
          onAction: onCreate ?? onOpenLitters,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Container(
            key: const Key('breeding-progress-summary'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: ScolvPalette.of(context).secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
              border: Border.all(
                color: ScolvPalette.of(context).separator,
                width: IosMetrics.hairline,
              ),
            ),
            child: Row(
              children: [
                _SummaryChip(label: '待处理', value: '$todo'),
                _SummaryChip(label: '配对', value: '$pairing'),
                _SummaryChip(label: '孕期', value: '$gestation'),
                _SummaryChip(label: '育仔', value: '$litter'),
              ],
            ),
          ),
        ),
        for (final key in keys) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  _progressGroupTitle(key),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ScolvPalette.of(context).label,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ScolvPalette.of(context).accentSoft,
                    borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
                  ),
                  child: Text(
                    '${grouped[key]!.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: ScolvPalette.of(context).accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (var i = 0; i < grouped[key]!.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _BreedingPlanTile(
                    plan: grouped[key]![i],
                    hamsters: hamsters,
                    onTap: () => onOpenPlan(grouped[key]![i]),
                  ),
                ],
              ],
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: OutlinedButton(
            key: const Key('breeding-progress-open-litters'),
            onPressed: onOpenLitters,
            child: const Text('打开窝次看板'),
          ),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: p.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreedingPlansBody extends StatelessWidget {
  const _BreedingPlansBody({
    required this.plans,
    required this.hamsters,
    required this.onOpenPlan,
    this.onCreate,
    this.onOpenGenetic,
  });

  final List<BreedingPlan> plans;
  final List<I2Hamster> hamsters;
  final ValueChanged<BreedingPlan> onOpenPlan;
  final VoidCallback? onCreate;
  final void Function({GeneticHubPrefill? prefill})? onOpenGenetic;

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: BearEmptyCard(
          title: '还没有繁育计划',
          subtitle: '创建计划后，可从配对推进到产仔。',
          mood: BearMood.happy,
          illustration: BearAssets.emptyList,
          actionLabel: onCreate == null ? null : '新建计划',
          onAction: onCreate,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onCreate != null || onOpenGenetic != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                if (onCreate != null)
                  Expanded(
                    child: FilledButton.tonal(
                      key: const Key('breeding-plans-create'),
                      onPressed: onCreate,
                      child: const Text('新建计划'),
                    ),
                  ),
                if (onCreate != null && onOpenGenetic != null)
                  const SizedBox(width: 10),
                if (onOpenGenetic != null)
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('breeding-plans-genetic'),
                      onPressed: () => onOpenGenetic!(),
                      child: const Text('配对推算'),
                    ),
                  ),
              ],
            ),
          ),
        IosGroupedSection(
          header: const IosSectionHeader('全部计划'),
          children: [
            for (final plan in plans)
              _BreedingPlanTile(
                plan: plan,
                hamsters: hamsters,
                onTap: () => onOpenPlan(plan),
              ),
          ],
        ),
      ],
    );
  }
}

class _BreedingPlanTile extends StatelessWidget {
  const _BreedingPlanTile({
    required this.plan,
    required this.hamsters,
    required this.onTap,
  });

  final BreedingPlan plan;
  final List<I2Hamster> hamsters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = ScolvPalette.of(context);
    final sire = _breedingHamsterLabel(hamsters, plan.sireId, '父本');
    final dam = _breedingHamsterLabel(hamsters, plan.damId, '母本');
    final meta = <String>[breedingStateLabel(plan.state)];
    // Day N 仅来自真实 planned_pairing_at 的日历差，不伪造预产。
    final planned = plan.plannedPairingAt;
    if (planned != null) {
      final days = DateTime.now().toUtc().difference(planned.toUtc()).inDays;
      if (days >= 0 && days < 400) meta.add('Day $days');
      meta.add('计划 ${i2DateLabel(planned)}');
    }
    final expStart = plan.expectedBirthStart;
    final expEnd = plan.expectedBirthEnd;
    if (expStart != null && expEnd != null) {
      meta.add('预产 ${i2DateLabel(expStart)}–${i2DateLabel(expEnd)}');
    } else if (expStart != null) {
      meta.add('预产起 ${i2DateLabel(expStart)}');
    }
    final actual = plan.actualBirthAt;
    if (actual != null) meta.add('产仔 ${i2DateLabel(actual)}');
    final next = nextActionLabel(plan.state);

    return Material(
      color: p.secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
      child: InkWell(
        key: Key('breeding-plan-${plan.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
            border: Border.all(color: p.separator, width: IosMetrics.hairline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$sire × $dam',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: p.label,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: p.secondaryLabel,
                      ),
                    ),
                    if (plan.displayName != '$sire × $dam' &&
                        (plan.name?.trim().isNotEmpty ?? false)) ...[
                      const SizedBox(height: 2),
                      Text(
                        plan.displayName,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: p.tertiaryLabel,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (next != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: p.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
                  ),
                  child: Text(
                    next,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: p.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: p.tertiaryLabel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BreedingWizardPage extends StatefulWidget {
  const BreedingWizardPage({
    super.key,
    required this.controller,
    required this.hamsters,
    required this.enclosures,
    required this.ruleVersionId,
    required this.onOpenLitters,
    this.canWrite = true,
    this.geneticRepository,
    this.onOpenGenetic,
  });

  final BreedingController controller;
  final List<I2Hamster> hamsters;
  final List<I2Enclosure> enclosures;
  final String? ruleVersionId;
  final VoidCallback onOpenLitters;
  final bool canWrite;
  final GeneticRepository? geneticRepository;
  final void Function({GeneticHubPrefill? prefill})? onOpenGenetic;

  @override
  State<BreedingWizardPage> createState() => _BreedingWizardPageState();
}

class _BreedingWizardPageState extends State<BreedingWizardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.refresh();
    });
  }

  Future<void> _createPlan() async {
    if (!widget.canWrite) {
      _toast('当前状态为只读，暂不能新建繁育计划');
      return;
    }
    final eligible = widget.hamsters.where((hamster) {
      return hamster.lifecycleStatus == 'active' &&
          hamster.breedingStatus != 'retired';
    });
    final males = eligible.where((h) => h.sex == 'male').toList();
    final females = eligible.where((h) => h.sex == 'female').toList();
    if (males.isEmpty || females.isEmpty) {
      _toast('需要至少一只公鼠和一只母鼠');
      return;
    }
    if (widget.ruleVersionId == null || widget.ruleVersionId!.isEmpty) {
      _toast('缺少物种规则版本');
      return;
    }
    String? sireId = males.first.id;
    String? damId = females.first.id;
    final nameCtrl = TextEditingController();
    try {
      final ok = await showCupertinoDialog<bool>(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setLocal) {
            return CupertinoAlertDialog(
            title: const Text('新建繁育计划'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoTextField(
                    controller: nameCtrl,
                    textInputAction: TextInputAction.done,
                    placeholder: '名称（可选）',
                  ),
                  const SizedBox(height: 12),
                  IosPickerField<String>(
                    label: '公本',
                    items: [
                      for (final h in males)
                        IosPickerItem(
                          value: h.id,
                          label:
                              '${h.displayName} · ${h.corePhenotypeLabel ?? '无表型'}',
                        ),
                    ],
                    selected: sireId,
                    onSelected: (v) => setLocal(() => sireId = v),
                  ),
                  const SizedBox(height: 12),
                  IosPickerField<String>(
                    label: '母本',
                    items: [
                      for (final h in females)
                        IosPickerItem(
                          value: h.id,
                          label:
                              '${h.displayName} · ${h.corePhenotypeLabel ?? '无表型'}',
                        ),
                    ],
                    selected: damId,
                    onSelected: (v) => setLocal(() => damId = v),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('创建'),
              ),
            ],
            );
          },
        ),
      );
      if (ok != true || sireId == null || damId == null) return;
      final success = await widget.controller.createPlan(
        CreateBreedingPlanInput(
          sireId: sireId!,
          damId: damId!,
          ruleVersionId: widget.ruleVersionId!,
          name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
        ),
      );
      if (!mounted) return;
      _toast(widget.controller.lastMessage ?? (success ? '已创建' : '失败'));
    } finally {
      nameCtrl.dispose();
    }
  }

  Future<void> _advance(BreedingPlan plan) async {
    if (!widget.canWrite) {
      _toast('当前状态为只读，暂不能推进繁育计划');
      return;
    }
    var enclosureId = widget.enclosures.isEmpty
        ? ''
        : widget.enclosures.first.id;
    var sireDestinationEnclosureId = enclosureId;
    var damDestinationEnclosureId = enclosureId;
    var livePups = 4;

    Map<String, int>? phenotypeCounts;
    SimulationSnapshot? simSnap;
    if (plan.state == 'gestation') {
      simSnap = SimulationSnapshot.tryParseNotes(plan.notes);
      final birth = await showCupertinoDialog<_BirthDialogResult>(
        context: context,
        builder: (ctx) => _ConfirmBirthDialog(
          snapshot: simSnap,
          geneticRepository: widget.geneticRepository,
        ),
      );
      if (birth == null) return;
      livePups = birth.livePups;
      phenotypeCounts = birth.phenotypeCounts;
      if (livePups > 0) {
        final selection = await _selectEnclosures(
          title: '选择产仔笼盒',
          description: '选择母鼠与幼崽当前所在笼盒。',
        );
        if (selection == null) return;
        enclosureId = selection.primaryEnclosureId;
      }
    } else if (plan.state == 'draft' || plan.state == 'pair_ready') {
      final selection = await _selectEnclosures(
        title: plan.state == 'draft' ? '选择配对笼盒' : '确认配对笼盒',
        description: plan.state == 'draft'
            ? '发布计划时记录预定配对笼盒。'
            : '开始前确认本次实际使用的配对笼盒。',
      );
      if (selection == null) return;
      enclosureId = selection.primaryEnclosureId;
    } else if (plan.state == 'pairing') {
      final selection = await _selectEnclosures(
        title: '确认分笼去向',
        description: '配对结束后，公鼠和母鼠必须回到不同笼盒。',
        chooseDestinations: true,
      );
      if (selection == null) return;
      enclosureId = selection.primaryEnclosureId;
      sireDestinationEnclosureId = selection.sireDestinationEnclosureId!;
      damDestinationEnclosureId = selection.damDestinationEnclosureId!;
    }

    widget.controller.select(plan);
    final ok = await widget.controller.advanceHappyPath(
      enclosureId: enclosureId,
      sireDestinationEnclosureId: sireDestinationEnclosureId,
      damDestinationEnclosureId: damDestinationEnclosureId,
      livePups: livePups,
    );
    if (!mounted) return;
    _toast(widget.controller.lastMessage ?? (ok ? '已推进' : '失败'));

    if (ok &&
        livePups > 0 &&
        phenotypeCounts != null &&
        phenotypeCounts.isNotEmpty &&
        simSnap != null &&
        widget.geneticRepository != null) {
      try {
        final litterId = widget.controller.selected?.litterId;
        final compare = await widget.geneticRepository!.compareActual(
          series: simSnap.series,
          sirePhenotype: simSnap.sire,
          damPhenotype: simSnap.dam,
          actualCounts: phenotypeCounts,
          save: true,
          breedingPlanId: plan.id,
          litterId: litterId,
        );
        if (!mounted) return;
        await showCupertinoDialog<void>(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('本窝结果'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    '${compare.sirePhenotype} × ${compare.damPhenotype} · '
                    '合计 ${compare.totalActual} 只',
                  ),
                  const SizedBox(height: 8),
                  for (final row in compare.rows)
                    IosListTile(
                      title: row.phenotype,
                      subtitle:
                          '预计约 ${row.expectedCount.toStringAsFixed(1)} 只 · '
                          '实际 ${row.actualCount} 只',
                      trailing: Text(row.predictedPercent),
                      showChevron: false,
                      minHeight: 40,
                    ),
                ],
              ),
            ),
            actions: [
              if (widget.onOpenGenetic != null)
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onOpenGenetic!(
                      prefill: GeneticHubPrefill(
                        series: simSnap!.series,
                        sirePhenotype: simSnap.sire,
                        damPhenotype: simSnap.dam,
                        initialTab: GeneticHubTab.feedback,
                      ),
                    );
                  },
                  child: const Text('补充本窝表型'),
                ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(ctx),
                child: const Text('知道了'),
              ),
            ],
          ),
        );
      } catch (error) {
        if (mounted) {
          _toast(geneticErrorMessage(error));
        }
      }
    }
  }

  Future<_BreedingEnclosureSelection?> _selectEnclosures({
    required String title,
    required String description,
    bool chooseDestinations = false,
  }) async {
    if (widget.enclosures.isEmpty) {
      _toast('请先建立可用笼盒');
      return null;
    }
    if (chooseDestinations && widget.enclosures.length < 2) {
      _toast('分笼至少需要两个不同笼盒');
      return null;
    }
    var primary = widget.enclosures.first.id;
    var sireDestination = widget.enclosures.first.id;
    var damDestination = chooseDestinations
        ? widget.enclosures[1].id
        : widget.enclosures.first.id;
    String? validationError;
    return showCupertinoDialog<_BreedingEnclosureSelection>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          final items = [
            for (final enclosure in widget.enclosures)
              IosPickerItem(value: enclosure.id, label: enclosure.code),
          ];
          return CupertinoAlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(description),
                  const SizedBox(height: 12),
                  if (!chooseDestinations)
                    IosPickerField<String>(
                      label: '笼盒',
                      items: items,
                      selected: primary,
                      onSelected: (value) {
                        if (value == null) return;
                        setLocal(() {
                          primary = value;
                          validationError = null;
                        });
                      },
                    )
                  else ...[
                    IosPickerField<String>(
                      label: '公鼠去向',
                      items: items,
                      selected: sireDestination,
                      onSelected: (value) {
                        if (value == null) return;
                        setLocal(() {
                          sireDestination = value;
                          validationError = null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    IosPickerField<String>(
                      label: '母鼠去向',
                      items: items,
                      selected: damDestination,
                      onSelected: (value) {
                        if (value == null) return;
                        setLocal(() {
                          damDestination = value;
                          validationError = null;
                        });
                      },
                    ),
                  ],
                  if (validationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      validationError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  if (chooseDestinations &&
                      sireDestination == damDestination) {
                    setLocal(() => validationError = '公鼠和母鼠必须选择不同笼盒');
                    return;
                  }
                  Navigator.pop(
                    context,
                    _BreedingEnclosureSelection(
                      primaryEnclosureId: chooseDestinations
                          ? sireDestination
                          : primary,
                      sireDestinationEnclosureId: chooseDestinations
                          ? sireDestination
                          : null,
                      damDestinationEnclosureId: chooseDestinations
                          ? damDestination
                          : null,
                    ),
                  );
                },
                child: const Text('确认'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toast(String message) {
    showIosMessage(context, message);
  }

  void _openGeneticForPlan(BreedingPlan plan) {
    final snap = SimulationSnapshot.tryParseNotes(plan.notes);
    if (snap == null || widget.onOpenGenetic == null) {
      _toast('这个计划还没有配对预测');
      return;
    }
    widget.onOpenGenetic!(
      prefill: GeneticHubPrefill(
        series: snap.series,
        sirePhenotype: snap.sire,
        damPhenotype: snap.dam,
        sireHamsterId: plan.sireId,
        damHamsterId: plan.damId,
        initialTab: plan.litterId != null || plan.state == 'litter_nursing'
            ? GeneticHubTab.feedback
            : GeneticHubTab.simulate,
        litterSize: snap.litterSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final listState = widget.controller.listState;
        final plans =
            listState.data ?? const <BreedingPlan>[];
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
        final hasRule = widget.ruleVersionId?.isNotEmpty == true;
        return Scaffold(
          appBar: AppBar(
            title: const Text('繁育向导'),
            actions: [
              IconButton(
                tooltip: '刷新繁育计划',
                onPressed: busy ? null : widget.controller.refresh,
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          floatingActionButton: widget.canWrite
              ? FloatingActionButton.extended(
                  onPressed: busy || !hasRule ? null : _createPlan,
                  backgroundColor: ScolvPalette.of(context).accent,
                  foregroundColor: ScolvPalette.of(context).groupedBackground,
                  elevation: 0,
                  icon: const Icon(CupertinoIcons.add),
                  label: const Text('新建计划'),
                )
              : null,
          body: Column(
            children: [
              if (!widget.canWrite)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.lock_shield,
                    color: IosColors.systemOrange,
                    text: '当前角色可查看繁育计划，新增与状态推进已设为只读。',
                  ),
                ),
              if (widget.canWrite && !hasRule)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosBanner(
                    icon: CupertinoIcons.exclamationmark_triangle,
                    color: IosColors.systemOrange,
                    text: '缺少物种规则版本。请先在“我的 - 物种规则”完成规则配置，再新建繁育计划。',
                  ),
                ),
              if (busy)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: ScolvPalette.of(context).accent,
                  backgroundColor: Colors.transparent,
                ),
              Expanded(
                child: listState.status == I2AsyncStatus.error
                    ? I2StateMessage(
                        icon: CupertinoIcons.cloud,
                        message: listState.message ?? '繁育计划加载失败',
                        actionLabel: '重试',
                        onRetry: widget.controller.refresh,
                        tone: IosColors.systemRed,
                      )
                    : listState.status == I2AsyncStatus.conflict
                    ? I2StateMessage(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        message: listState.message ?? '计划状态已有更新',
                        actionLabel: '重新加载',
                        onRetry: widget.controller.refresh,
                        tone: IosColors.systemOrange,
                      )
                    : listState.status == I2AsyncStatus.loading ||
                          listState.status == I2AsyncStatus.idle
                    ? const IosLoading()
                    : plans.isEmpty
                    ? I2StateMessage(
                        icon: CupertinoIcons.arrow_2_squarepath,
                        message: '还没有繁育计划',
                        actionLabel: widget.canWrite && hasRule ? '新建计划' : null,
                        onRetry: widget.canWrite && hasRule ? _createPlan : null,
                        illustration: BearAssets.emptyList,
                        mood: BearMood.sleepy,
                      )
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final action = nextActionLabel(plan.state);
                    final hasSnap =
                        SimulationSnapshot.tryParseNotes(plan.notes) != null;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == plans.length - 1 ? 0 : 12,
                      ),
                      child: Container(
                        key: Key('breeding-plan-${plan.id}'),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    plan.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ScolvPalette.of(context).accentSoft,
                                    borderRadius: BorderRadius.circular(
                                      IosMetrics.pillRadius,
                                    ),
                                  ),
                                  child: Text(
                                    breedingStateLabel(plan.state),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ScolvPalette.of(context).accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '公 ${_breedingHamsterLabel(widget.hamsters, plan.sireId, '公鼠')}'
                              ' · 母 ${_breedingHamsterLabel(widget.hamsters, plan.damId, '母鼠')}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (hasSnap) ...[
                              const SizedBox(height: 4),
                              Text(
                                '已有配对预测',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: ScolvPalette.of(context).accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            _StepRail(state: plan.state),
                            const SizedBox(height: 12),
                            if (hasSnap && widget.onOpenGenetic != null)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  key: Key('breeding-open-genetic-${plan.id}'),
                                  onPressed: () => _openGeneticForPlan(plan),
                                  icon: const Icon(
                                    CupertinoIcons.lab_flask,
                                    size: 16,
                                  ),
                                  label: Text(
                                    plan.litterId != null ? '记录本窝' : '查看预测',
                                  ),
                                ),
                              ),
                            if (hasSnap && widget.onOpenGenetic != null)
                              const SizedBox(height: 8),
                            if (action != null)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  key: Key('breeding-next-${plan.id}'),
                                  onPressed: busy || !widget.canWrite
                                      ? null
                                      : () => _advance(plan),
                                  child: Text(action),
                                ),
                              )
                            else if (plan.state == 'litter_nursing' ||
                                plan.litterId != null)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    widget.onOpenLitters();
                                  },
                                  child: const Text('查看窝次'),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '当前计划为${breedingStateLabel(plan.state)}，没有下一步主路径操作。',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BirthDialogResult {
  const _BirthDialogResult({required this.livePups, this.phenotypeCounts});

  final int livePups;
  final Map<String, int>? phenotypeCounts;
}

class _BreedingEnclosureSelection {
  const _BreedingEnclosureSelection({
    required this.primaryEnclosureId,
    this.sireDestinationEnclosureId,
    this.damDestinationEnclosureId,
  });

  final String primaryEnclosureId;
  final String? sireDestinationEnclosureId;
  final String? damDestinationEnclosureId;
}

class _ConfirmBirthDialog extends StatefulWidget {
  const _ConfirmBirthDialog({this.snapshot, this.geneticRepository});

  final SimulationSnapshot? snapshot;
  final GeneticRepository? geneticRepository;

  @override
  State<_ConfirmBirthDialog> createState() => _ConfirmBirthDialogState();
}

class _ConfirmBirthDialogState extends State<_ConfirmBirthDialog> {
  final _aliveCtrl = TextEditingController(text: '4');
  final _customPhenoNameCtrl = TextEditingController();
  final Map<String, TextEditingController> _countCtrls = {};

  /// Phenotypes predicted with p>0 (primary list).
  List<String> _predictedPhenos = const [];

  /// Full series phenotypes (for expand).
  List<String> _allPhenos = const [];

  /// Free-text phenotype labels not in core table.
  final List<String> _extraPhenos = [];
  bool _showAllPhenos = false;
  String? _loadError;
  bool _loadingPhenos = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _aliveCtrl.addListener(() => setState(() => _validationError = null));
    _bootstrapPhenotypes();
  }

  Future<void> _bootstrapPhenotypes() async {
    final snap = widget.snapshot;
    if (snap == null || widget.geneticRepository == null) return;
    setState(() => _loadingPhenos = true);
    try {
      final repo = widget.geneticRepository!;
      final catalog = await repo.listPhenotypeCatalog();
      final ser = catalog.seriesByCode(snap.series);
      final all = ser?.phenotypes ?? const <String>[];
      // Prefer phenotypes that core table predicts for this pair.
      List<String> predicted = all;
      try {
        final sim = await repo.simulatePhenotype(
          series: snap.series,
          sirePhenotype: snap.sire,
          damPhenotype: snap.dam,
        );
        predicted = sim.outcomes
            .where((o) => o.probability > 0)
            .map((o) => o.phenotypeLabel)
            .toList();
        if (predicted.isEmpty) predicted = all;
      } catch (_) {
        predicted = all;
      }
      if (!mounted) return;
      setState(() {
        _allPhenos = all;
        _predictedPhenos = predicted;
        _loadingPhenos = false;
        for (final p in all) {
          _countCtrls.putIfAbsent(p, () {
            final c = TextEditingController(text: '0');
            c.addListener(() => setState(() => _validationError = null));
            return c;
          });
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = '表型选项暂时不可用，可先记录活仔数';
        _loadingPhenos = false;
      });
    }
  }

  List<String> get _visiblePhenos =>
      _showAllPhenos ? _allPhenos : _predictedPhenos;

  Map<String, int> _readCounts() {
    final out = <String, int>{};
    for (final p in _allPhenos) {
      final n = int.tryParse(_countCtrls[p]?.text.trim() ?? '') ?? 0;
      if (n > 0) out[p] = n;
    }
    for (final p in _extraPhenos) {
      final n = int.tryParse(_countCtrls[p]?.text.trim() ?? '') ?? 0;
      if (n > 0) out[p] = n;
    }
    return out;
  }

  TextEditingController _ctrlFor(String phenotype) {
    return _countCtrls.putIfAbsent(phenotype, () {
      final c = TextEditingController(text: '0');
      c.addListener(() => setState(() => _validationError = null));
      return c;
    });
  }

  void _addCustomPhenotype() {
    final name = _customPhenoNameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _validationError = '请先输入表型名称');
      return;
    }
    if (_allPhenos.contains(name) || _extraPhenos.contains(name)) {
      setState(() => _validationError = '该表型已在列表中，直接改计数即可');
      return;
    }
    setState(() {
      _extraPhenos.add(name);
      _ctrlFor(name);
      _customPhenoNameCtrl.clear();
      _validationError = null;
    });
  }

  int get _livePups => int.tryParse(_aliveCtrl.text.trim()) ?? 0;

  PhenotypeCountValidation get _validation =>
      PhenotypeCountValidation(livePups: _livePups, counts: _readCounts());

  @override
  void dispose() {
    _aliveCtrl.dispose();
    _customPhenoNameCtrl.dispose();
    for (final c in _countCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snap = widget.snapshot;
    final validation = _validation;
    final sum = validation.sum;
    final live = _livePups;

    return CupertinoAlertDialog(
      title: const Text('确认产仔'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoTextField(
                controller: _aliveCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                placeholder: '活仔数',
              ),
              Text('如果没有活仔，请填 0', style: Theme.of(context).textTheme.bodySmall),
              if (_validationError != null)
                Text(
                  _validationError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              if (snap != null) ...[
                const SizedBox(height: 12),
                Text(
                  '本次配对：${snap.sire} × ${snap.dam}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '记录每种表型的数量，合计应等于活仔总数',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  validation.hasAnyCount
                      ? '已记录 $sum 只 / 活仔 $live 只'
                            '${validation.isValid ? ' ✓' : ' ✗'}'
                      : '尚未填表型计数（可跳过，仅记活仔数）',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: !validation.hasAnyCount
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : (validation.isValid
                              ? Colors.green.shade700
                              : Theme.of(context).colorScheme.error),
                  ),
                ),
                if (_loadingPhenos)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                if (_loadError != null)
                  Text(
                    _loadError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                for (final p in _visiblePhenos) ...[
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    key: Key('birth-pheno-$p'),
                    controller: _countCtrls[p],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    placeholder: p,
                  ),
                ],
                for (final p in _extraPhenos) ...[
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    key: Key('birth-pheno-extra-$p'),
                    controller: _ctrlFor(p),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    placeholder: '$p（手填）',
                    suffix: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          _extraPhenos.remove(p);
                          _countCtrls.remove(p)?.dispose();
                          _validationError = null;
                        });
                      },
                      child: const Icon(CupertinoIcons.xmark, size: 18),
                    ),
                  ),
                ],
                if (_allPhenos.length > _predictedPhenos.length) ...[
                  const SizedBox(height: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () =>
                        setState(() => _showAllPhenos = !_showAllPhenos),
                    child: Text(_showAllPhenos ? '只显示预测表型' : '显示全部表型'),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        key: const Key('birth-custom-pheno-name'),
                        controller: _customPhenoNameCtrl,
                        textInputAction: TextInputAction.done,
                        placeholder: '其他表型名称',
                        onSubmitted: (_) => _addCustomPhenotype(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: CupertinoButton(
                        key: const Key('birth-add-custom-pheno'),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onPressed: _addCustomPhenotype,
                        child: const Text('添加'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            if (_aliveCtrl.text.trim().isEmpty) {
              setState(() => _validationError = '请输入活仔数，若无活仔请填 0');
              return;
            }
            final live = _livePups;
            final counts = _readCounts();
            final v = PhenotypeCountValidation(livePups: live, counts: counts);
            if (!v.isValid) {
              setState(() => _validationError = v.errorMessage);
              return;
            }
            Navigator.pop(
              context,
              _BirthDialogResult(
                livePups: live,
                phenotypeCounts: counts.isEmpty ? null : counts,
              ),
            );
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.state});

  final String state;

  static const _steps = <(String, String)>[
    ('draft', '草稿'),
    ('pair_ready', '待配'),
    ('pairing', '配对'),
    ('post_pair', '分笼'),
    ('gestation', '孕期'),
    ('litter_nursing', '产仔'),
  ];

  int get _index {
    final step = wizardStepForState(state);
    return switch (step) {
      BreedingWizardStep.draft => 0,
      BreedingWizardStep.pairReady => 1,
      BreedingWizardStep.pairing => 2,
      BreedingWizardStep.postPair => 3,
      BreedingWizardStep.gestation => 4,
      BreedingWizardStep.litterNursing => 5,
      BreedingWizardStep.other => -1,
    };
  }

  @override
  Widget build(BuildContext context) {
    final current = _index;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 390 ? 390.0 : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Row(
              children: [
                for (var i = 0; i < _steps.length; i++) ...[
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
                        width: 24,
                        height: 24,
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
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: current >= i
                                ? Colors.white
                                : ScolvPalette.of(context).secondaryLabel,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _steps[i].$2,
                        style: TextStyle(
                          fontSize: 10,
                          color: current == i
                              ? ScolvPalette.of(context).label
                              : ScolvPalette.of(context).secondaryLabel,
                          fontWeight: current == i
                              ? FontWeight.w700
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
