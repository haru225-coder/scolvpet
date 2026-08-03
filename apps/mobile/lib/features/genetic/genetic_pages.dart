import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../breeding/breeding_controller.dart';
import '../breeding/breeding_models.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'genetic_controller.dart';
import 'genetic_models.dart';
import 'genetics_copy.dart';
import 'option_or_custom_field.dart';

enum GeneticHubTab { simulate, target, feedback, profiles }

/// Prefill when opening genetic hub from hamster detail / breeding plan.
class GeneticHubPrefill {
  const GeneticHubPrefill({
    this.series,
    this.sirePhenotype,
    this.damPhenotype,
    this.sireHamsterId,
    this.damHamsterId,
    this.litterSize,
    this.initialTab = GeneticHubTab.simulate,
    this.autoSimulate = false,
  });

  final String? series;
  final String? sirePhenotype;
  final String? damPhenotype;
  final String? sireHamsterId;
  final String? damHamsterId;
  final int? litterSize;
  final GeneticHubTab initialTab;

  /// When true and both phenotypes available, run core-table simulate on open.
  final bool autoSimulate;

  int get tabIndex => switch (initialTab) {
    GeneticHubTab.simulate => 0,
    GeneticHubTab.target => 1,
    GeneticHubTab.feedback => 2,
    GeneticHubTab.profiles => 3,
  };
}

/// Rank mate candidates for pairing with [self].
/// Opposite sex first, then same core series, then has phenotype, then name.
List<I2Hamster> rankMateCandidates({
  required I2Hamster self,
  required List<I2Hamster> all,
}) {
  final others = all.where((h) => h.id != self.id).toList();
  int score(I2Hamster h) {
    var s = 0;
    if (self.sex == 'male' && h.sex == 'female') s += 100;
    if (self.sex == 'female' && h.sex == 'male') s += 100;
    if (self.sex == 'unknown' || h.sex == 'unknown') s += 40;
    if (self.coreSeriesCode != null &&
        h.coreSeriesCode == self.coreSeriesCode) {
      s += 30;
    }
    if (h.hasCorePhenotype) s += 20;
    if (h.lifecycleStatus == 'active') s += 10;
    return s;
  }

  others.sort((a, b) {
    final byScore = score(b).compareTo(score(a));
    if (byScore != 0) return byScore;
    return a.displayName.compareTo(b.displayName);
  });
  return others;
}

/// Pick a mate hamster for [self] from [candidates].
Future<I2Hamster?> showMatePickerSheet({
  required BuildContext context,
  required I2Hamster self,
  required List<I2Hamster> allHamsters,
}) async {
  final ranked = rankMateCandidates(self: self, all: allHamsters);
  if (ranked.isEmpty) {
    showIosMessage(context, '没有可选的配对对象');
    return null;
  }
  final preferredSex = self.sex == 'male'
      ? 'female'
      : (self.sex == 'female' ? 'male' : null);
  final preferred = preferredSex == null
      ? ranked
      : ranked
            .where((h) => h.sex == preferredSex || h.sex == 'unknown')
            .toList();
  final list = preferred.isNotEmpty ? preferred : ranked;

  return showCupertinoModalPopup<I2Hamster>(
    context: context,
    builder: (ctx) {
      final p = ScolvPalette.of(ctx);
      return Container(
        decoration: BoxDecoration(
          color: p.secondaryGroupedBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(IosMetrics.continuousRadius),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.55,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    '为「${self.displayName}」选择配对对象',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    self.hasCorePhenotype
                        ? '本鼠表型：${self.corePhenotypeLabel}'
                              '${self.coreSeriesCode != null ? '（${self.coreSeriesCode}）' : ''}'
                        : '本鼠尚未填写表型，可先编辑档案',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => Container(
                      height: IosMetrics.hairline,
                      color: p.separator,
                    ),
                    itemBuilder: (context, index) {
                      final h = list[index];
                      return IosListTile(
                        key: Key('mate-pick-${h.id}'),
                        leading: IosGlyph(
                          icon: CupertinoIcons.person,
                          color: switch (h.sex) {
                            'male' => IosColors.systemBlue,
                            'female' => IosColors.systemRed,
                            _ => IosColors.systemGray,
                          },
                        ),
                        title: h.displayName,
                        subtitle: h.corePhenotypeLabel ?? '未填写表型',
                        trailing: h.hasCorePhenotype
                            ? const Icon(CupertinoIcons.checkmark_circle)
                            : null,
                        onTap: () => Navigator.pop(ctx, h),
                        showChevron: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Build prefill for pairing [a] with [b] (order by sex when possible).
GeneticHubPrefill prefillForPair(I2Hamster a, I2Hamster b) {
  I2Hamster sire = a;
  I2Hamster dam = b;
  if (a.sex == 'female' && b.sex != 'female') {
    sire = b;
    dam = a;
  } else if (b.sex == 'male' && a.sex != 'male') {
    sire = b;
    dam = a;
  } else if (a.sex == 'female' && b.sex == 'female') {
    // keep order
  }
  final series = sire.coreSeriesCode ?? dam.coreSeriesCode;
  return GeneticHubPrefill(
    series: series,
    sirePhenotype: sire.corePhenotypeLabel,
    damPhenotype: dam.corePhenotypeLabel,
    sireHamsterId: sire.id,
    damHamsterId: dam.id,
    initialTab: GeneticHubTab.simulate,
    autoSimulate: sire.hasCorePhenotype && dam.hasCorePhenotype,
  );
}

/// Genetic hub: authority phenotype-table simulator + profiles (T-P1-06).
class GeneticHubPage extends StatefulWidget {
  const GeneticHubPage({
    super.key,
    required this.controller,
    this.hamsters = const [],
    this.breedingController,
    this.ruleVersionId,
    this.prefill,
  });

  final GeneticController controller;

  /// Optional hamster roster for picking sire/dam by core phenotype.
  final List<I2Hamster> hamsters;

  /// Optional: create breeding-plan draft from simulation notes.
  final BreedingController? breedingController;

  /// Required when creating a breeding plan from simulation.
  final String? ruleVersionId;

  /// Deep-link style prefill (from plan / hamster).
  final GeneticHubPrefill? prefill;

  @override
  State<GeneticHubPage> createState() => _GeneticHubPageState();
}

class _GeneticHubPageState extends State<GeneticHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  String? _seriesCode;
  String? _sirePhenotype;
  String? _damPhenotype;
  String? _targetPhenotype;
  String? _simulationTargetPhenotype;
  String? _sireHamsterId;
  String? _damHamsterId;
  int _litterSize = 6;

  @override
  void initState() {
    super.initState();
    final pre = widget.prefill;
    _tabs = TabController(
      length: 4,
      vsync: this,
      initialIndex: pre?.tabIndex.clamp(0, 3) ?? 0,
    );
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
    if (pre != null) {
      _seriesCode = pre.series;
      _sirePhenotype = pre.sirePhenotype;
      _damPhenotype = pre.damPhenotype;
      _sireHamsterId = pre.sireHamsterId;
      _damHamsterId = pre.damHamsterId;
      if (pre.litterSize != null && pre.litterSize! > 0) {
        _litterSize = pre.litterSize!;
      }
      // Apply hamster phenotypes if only ids provided.
      if (_sireHamsterId != null) {
        final h = widget.hamsters.cast<I2Hamster?>().firstWhere(
          (x) => x?.id == _sireHamsterId,
          orElse: () => null,
        );
        _sirePhenotype ??= h?.corePhenotypeLabel;
        _seriesCode ??= h?.coreSeriesCode;
      }
      if (_damHamsterId != null) {
        final h = widget.hamsters.cast<I2Hamster?>().firstWhere(
          (x) => x?.id == _damHamsterId,
          orElse: () => null,
        );
        _damPhenotype ??= h?.corePhenotypeLabel;
        _seriesCode ??= h?.coreSeriesCode;
      }
    }
    widget.controller.refreshAll().then((_) {
      if (!mounted) return;
      _seedDefaultsFromCatalog();
      _maybeAutoSimulate();
    });
  }

  void _seedDefaultsFromCatalog() {
    final catalog = widget.controller.catalogState.data;
    if (catalog == null || catalog.series.isEmpty) return;
    final series =
        catalog.seriesByCode(_seriesCode ?? '') ?? catalog.series.first;
    setState(() {
      _seriesCode ??= series.code;
      final phenos = series.phenotypes;
      if (phenos.isNotEmpty) {
        _sirePhenotype ??= phenos.first;
        _damPhenotype ??= phenos.length > 1 ? phenos[1] : phenos.first;
        _targetPhenotype ??= phenos.first;
      }
    });
  }

  void _maybeAutoSimulate() {
    final pre = widget.prefill;
    if (pre == null || !pre.autoSimulate) return;
    if (_seriesCode == null ||
        _sirePhenotype == null ||
        _damPhenotype == null) {
      return;
    }
    widget.controller.simulatePhenotype(
      series: _seriesCode!,
      sirePhenotype: _sirePhenotype!,
      damPhenotype: _damPhenotype!,
      sireHamsterId: _sireHamsterId,
      damHamsterId: _damHamsterId,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _snack(Future<bool> Function() action) async {
    final ok = await action();
    if (!mounted) return;
    final message = widget.controller.lastMessage;
    if (message != null) {
      showIosMessage(context, message);
    }
    if (ok) setState(() {});
  }

  PhenotypeSeriesCatalog? get _currentSeries {
    final catalog = widget.controller.catalogState.data;
    if (catalog == null || _seriesCode == null) return null;
    return catalog.seriesByCode(_seriesCode!);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(GeneticsUiCopy.pageTitle),
            actions: [
              IconButton(
                key: const Key('genetic-refresh'),
                onPressed: () async {
                  await widget.controller.refreshAll();
                  if (mounted) _seedDefaultsFromCatalog();
                },
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          floatingActionButton: switch (_tabs.index) {
            0 => FloatingActionButton.extended(
              key: const Key('genetic-run-sim'),
              onPressed:
                  _seriesCode == null ||
                      _sirePhenotype == null ||
                      _damPhenotype == null
                  ? null
                  : () => _snack(
                      () => widget.controller.simulatePhenotype(
                        series: _seriesCode!,
                        sirePhenotype: _sirePhenotype!,
                        damPhenotype: _damPhenotype!,
                        sireHamsterId: _sireHamsterId,
                        damHamsterId: _damHamsterId,
                      ),
                    ),
              backgroundColor: ScolvPalette.of(context).accent,
              foregroundColor: ScolvPalette.of(context).groupedBackground,
              elevation: 0,
              icon: const Icon(CupertinoIcons.lab_flask_solid),
              label: const Text(GeneticsUiCopy.runCta),
            ),
            1 => FloatingActionButton.extended(
              key: const Key('genetic-run-target'),
              onPressed: _seriesCode == null || _targetPhenotype == null
                  ? null
                  : () => _snack(
                      () => widget.controller.findTargetCrosses(
                        series: _seriesCode!,
                        targetPhenotype: _targetPhenotype!,
                      ),
                    ),
              backgroundColor: ScolvPalette.of(context).accent,
              foregroundColor: ScolvPalette.of(context).groupedBackground,
              elevation: 0,
              icon: const Icon(CupertinoIcons.search),
              label: const Text('查找组合'),
            ),
            3 => FloatingActionButton.extended(
              key: const Key('genetic-fab'),
              onPressed: _createProfile,
              backgroundColor: ScolvPalette.of(context).accent,
              foregroundColor: ScolvPalette.of(context).groupedBackground,
              elevation: 0,
              icon: const Icon(CupertinoIcons.add),
              label: const Text('新建档案'),
            ),
            _ => null, // 结果回填使用页内按钮
          },
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  IosMetrics.pagePadding,
                  12,
                  IosMetrics.pagePadding,
                  0,
                ),
                child: IosSegmentedControl<int>(
                  tabs: const [
                    IosSegmentTab(value: 0, label: '配对预测'),
                    IosSegmentTab(value: 1, label: '想要的表型'),
                    IosSegmentTab(value: 2, label: '记录本窝'),
                    IosSegmentTab(value: 3, label: '档案'),
                  ],
                  selected: _tabs.index,
                  onSelect: (i) => _tabs.animateTo(i),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _PairSimTab(
                      catalogState: widget.controller.catalogState,
                      seriesCode: _seriesCode,
                      sirePhenotype: _sirePhenotype,
                      damPhenotype: _damPhenotype,
                      sireHamsterId: _sireHamsterId,
                      damHamsterId: _damHamsterId,
                      litterSize: _litterSize,
                      targetPhenotype: _simulationTargetPhenotype,
                      hamsters: widget.hamsters,
                      simulateState: widget.controller.simulateState,
                      canCreatePlan:
                          widget.breedingController != null &&
                          widget.ruleVersionId != null &&
                          _sireHamsterId != null &&
                          _damHamsterId != null,
                      onSeriesChanged: (code) {
                        final ser = widget.controller.catalogState.data
                            ?.seriesByCode(code);
                        setState(() {
                          _seriesCode = code;
                          final phenos = ser?.phenotypes ?? const <String>[];
                          _sirePhenotype = phenos.isNotEmpty
                              ? phenos.first
                              : null;
                          _damPhenotype = phenos.length > 1
                              ? phenos[1]
                              : (phenos.isNotEmpty ? phenos.first : null);
                          _targetPhenotype = phenos.isNotEmpty
                              ? phenos.first
                              : null;
                          _simulationTargetPhenotype = null;
                          _sireHamsterId = null;
                          _damHamsterId = null;
                        });
                      },
                      onSireChanged: (v) => setState(() {
                        _sirePhenotype = v;
                        _sireHamsterId = null;
                      }),
                      onDamChanged: (v) => setState(() {
                        _damPhenotype = v;
                        _damHamsterId = null;
                      }),
                      onSireHamsterChanged: (id) {
                        final h = widget.hamsters.cast<I2Hamster?>().firstWhere(
                          (x) => x?.id == id,
                          orElse: () => null,
                        );
                        setState(() {
                          _sireHamsterId = id;
                          if (h?.corePhenotypeLabel != null) {
                            _sirePhenotype = h!.corePhenotypeLabel;
                          }
                          if (h?.coreSeriesCode != null) {
                            _seriesCode = h!.coreSeriesCode;
                          }
                        });
                      },
                      onDamHamsterChanged: (id) {
                        final h = widget.hamsters.cast<I2Hamster?>().firstWhere(
                          (x) => x?.id == id,
                          orElse: () => null,
                        );
                        setState(() {
                          _damHamsterId = id;
                          if (h?.corePhenotypeLabel != null) {
                            _damPhenotype = h!.corePhenotypeLabel;
                          }
                          if (h?.coreSeriesCode != null) {
                            _seriesCode = h!.coreSeriesCode;
                          }
                        });
                      },
                      onLitterSizeChanged: (n) =>
                          setState(() => _litterSize = n),
                      onTargetChanged: (v) => setState(() {
                        _simulationTargetPhenotype = v;
                      }),
                      onCreatePlan: _createPlanFromSim,
                      onRetryCatalog: widget.controller.refreshCatalog,
                      onRetrySim: () {
                        if (_seriesCode == null ||
                            _sirePhenotype == null ||
                            _damPhenotype == null) {
                          return;
                        }
                        widget.controller.simulatePhenotype(
                          series: _seriesCode!,
                          sirePhenotype: _sirePhenotype!,
                          damPhenotype: _damPhenotype!,
                          sireHamsterId: _sireHamsterId,
                          damHamsterId: _damHamsterId,
                        );
                      },
                    ),
                    _TargetTab(
                      catalogState: widget.controller.catalogState,
                      seriesCode: _seriesCode,
                      targetPhenotype: _targetPhenotype,
                      targetState: widget.controller.targetState,
                      onSeriesChanged: (code) {
                        final ser = widget.controller.catalogState.data
                            ?.seriesByCode(code);
                        setState(() {
                          _seriesCode = code;
                          final phenos = ser?.phenotypes ?? const <String>[];
                          _targetPhenotype = phenos.isNotEmpty
                              ? phenos.first
                              : null;
                        });
                      },
                      onTargetChanged: (v) =>
                          setState(() => _targetPhenotype = v),
                      onRetryCatalog: widget.controller.refreshCatalog,
                      onRetryTarget: () {
                        if (_seriesCode == null || _targetPhenotype == null) {
                          return;
                        }
                        widget.controller.findTargetCrosses(
                          series: _seriesCode!,
                          targetPhenotype: _targetPhenotype!,
                        );
                      },
                      onApplyPair: (a, b) {
                        setState(() {
                          _sirePhenotype = a;
                          _damPhenotype = b;
                          // 反查套用的是表型组合，不是原先选中的具体亲本。
                          // 清掉旧档案，避免新组合误带旧亲本做个体校准。
                          _sireHamsterId = null;
                          _damHamsterId = null;
                          _tabs.index = 0;
                        });
                      },
                    ),
                    _FeedbackTab(
                      catalogState: widget.controller.catalogState,
                      seriesCode: _seriesCode,
                      sirePhenotype: _sirePhenotype,
                      damPhenotype: _damPhenotype,
                      compareState: widget.controller.compareState,
                      summaryState: widget.controller.summaryState,
                      onSeriesChanged: (code) {
                        final ser = widget.controller.catalogState.data
                            ?.seriesByCode(code);
                        setState(() {
                          _seriesCode = code;
                          final phenos = ser?.phenotypes ?? const <String>[];
                          _sirePhenotype = phenos.isNotEmpty
                              ? phenos.first
                              : null;
                          _damPhenotype = phenos.length > 1
                              ? phenos[1]
                              : (phenos.isNotEmpty ? phenos.first : null);
                        });
                      },
                      onSireChanged: (v) => setState(() => _sirePhenotype = v),
                      onDamChanged: (v) => setState(() => _damPhenotype = v),
                      onRetryCatalog: widget.controller.refreshCatalog,
                      onRetrySummary: widget.controller.refreshFeedbackSummary,
                      onCompare: (counts) => _snack(
                        () => widget.controller.compareActual(
                          series: _seriesCode!,
                          sirePhenotype: _sirePhenotype!,
                          damPhenotype: _damPhenotype!,
                          actualCounts: counts,
                          save: true,
                        ),
                      ),
                    ),
                    _ProfilesTab(
                      state: widget.controller.profilesState,
                      onRetry: widget.controller.refreshProfiles,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createPlanFromSim() async {
    final breeding = widget.breedingController;
    final ruleId = widget.ruleVersionId;
    final result = widget.controller.simulateState.data;
    if (breeding == null ||
        ruleId == null ||
        result == null ||
        _sireHamsterId == null ||
        _damHamsterId == null) {
      showIosMessage(context, '请先选择公母档案并完成推算');
      return;
    }
    final notes = buildSimulationPlanNotes(
      result: result,
      litterSize: _litterSize,
    );
    final ok = await breeding.createPlan(
      CreateBreedingPlanInput(
        sireId: _sireHamsterId!,
        damId: _damHamsterId!,
        ruleVersionId: ruleId,
        name:
            '${result.sirePhenotype ?? '父'}×${result.damPhenotype ?? '母'} 推算计划',
        notes: notes,
      ),
    );
    if (!mounted) return;
    showIosMessage(
      context,
      ok
          ? (breeding.lastMessage ?? '已写入繁殖计划')
          : (breeding.lastMessage ?? '创建失败'),
    );
  }

  Future<void> _createProfile() async {
    final nameCtrl = TextEditingController();
    final genotype = {
      for (final l in defaultGeneticLoci)
        l.code: '${l.dominantAllele}/${l.dominantAllele}',
    };
    var confidence = 'unknown';
    // Optional table phenotype annotation
    String? seriesPhenotype = _sirePhenotype;
    final series = _currentSeries;

    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          final p = ScolvPalette.of(context);
          return CupertinoAlertDialog(
            title: const Text('新建遗传档案'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  CupertinoTextField(
                    key: const Key('genetic-profile-name'),
                    controller: nameCtrl,
                    textInputAction: TextInputAction.done,
                    placeholder: '名称',
                    padding: const EdgeInsets.symmetric(
                      horizontal: IosMetrics.tilePadding,
                      vertical: IosMetrics.tileVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: p.secondaryFill,
                      borderRadius: BorderRadius.circular(
                        IosMetrics.continuousRadius,
                      ),
                    ),
                  ),
                  if (series != null && series.phenotypes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _IosAlertPicker(
                      label: '表型（${series.name}）',
                      value: series.phenotypes.contains(seriesPhenotype)
                          ? seriesPhenotype!
                          : series.phenotypes.first,
                      options: series.phenotypes,
                      onChanged: (value) {
                        seriesPhenotype = value;
                        setLocal(() {});
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final locus in defaultGeneticLoci) ...[
                    _IosAlertPicker(
                      label: '${locus.code} · ${locus.name}（可选位点）',
                      value: genotype[locus.code]!,
                      options: locus.pairOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        genotype[locus.code] = value;
                        setLocal(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  _IosAlertPicker(
                    label: '置信度',
                    value: confidence,
                    options: const ['unknown', 'inferred', 'observed'],
                    displayName: (v) => switch (v) {
                      'unknown' => '未知',
                      'inferred' => '推测',
                      'observed' => '实测',
                      _ => v,
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      confidence = value;
                      setLocal(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                key: const Key('genetic-profile-submit'),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('创建'),
              ),
            ],
          );
        },
      ),
    );
    if (ok != true || !mounted) return;
    final notes = seriesPhenotype == null
        ? null
        : 'table_phenotype=$seriesPhenotype;series=${_seriesCode ?? ''}';
    await _snack(
      () => widget.controller.createProfile(
        GeneticProfileDraft(
          name: nameCtrl.text,
          genotype: genotype,
          confidence: confidence,
          notes: notes,
        ),
      ),
    );
  }
}

class _PairSimTab extends StatelessWidget {
  const _PairSimTab({
    required this.catalogState,
    required this.seriesCode,
    required this.sirePhenotype,
    required this.damPhenotype,
    required this.sireHamsterId,
    required this.damHamsterId,
    required this.litterSize,
    required this.targetPhenotype,
    required this.hamsters,
    required this.simulateState,
    required this.canCreatePlan,
    required this.onSeriesChanged,
    required this.onSireChanged,
    required this.onDamChanged,
    required this.onSireHamsterChanged,
    required this.onDamHamsterChanged,
    required this.onLitterSizeChanged,
    required this.onTargetChanged,
    required this.onCreatePlan,
    required this.onRetryCatalog,
    required this.onRetrySim,
  });

  final I2AsyncState<PhenotypeCatalog> catalogState;
  final String? seriesCode;
  final String? sirePhenotype;
  final String? damPhenotype;
  final String? sireHamsterId;
  final String? damHamsterId;
  final int litterSize;
  final String? targetPhenotype;
  final List<I2Hamster> hamsters;
  final I2AsyncState<GeneticSimulationResult> simulateState;
  final bool canCreatePlan;
  final ValueChanged<String> onSeriesChanged;
  final ValueChanged<String?> onSireChanged;
  final ValueChanged<String?> onDamChanged;
  final ValueChanged<String?> onSireHamsterChanged;
  final ValueChanged<String?> onDamHamsterChanged;
  final ValueChanged<int> onLitterSizeChanged;
  final ValueChanged<String?> onTargetChanged;
  final VoidCallback onCreatePlan;
  final VoidCallback onRetryCatalog;
  final VoidCallback onRetrySim;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<PhenotypeCatalog>(
      state: catalogState,
      onRetry: onRetryCatalog,
      builder: (catalog) {
        final series = catalog.series;
        if (series.isEmpty) {
          return const I2StateMessage(
            icon: CupertinoIcons.exclamationmark_triangle,
            message: '暂时没有可用的表型数据',
          );
        }
        final current = series.firstWhere(
          (s) => s.code == seriesCode,
          orElse: () => series.first,
        );
        final phenos = current.phenotypes;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            Text(
              '选择父母表型，直接查看下一窝可能出现什么。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            IosPickerField<String>(
              key: const Key('genetic-series'),
              label: '系列',
              items: [
                for (final s in series)
                  IosPickerItem(value: s.code, label: s.name),
              ],
              selected: current.code,
              onSelected: (v) {
                if (v != null) onSeriesChanged(v);
              },
            ),
            const SizedBox(height: IosMetrics.listGap),
            if (hamsters.isNotEmpty) ...[
              IosPickerField<String>(
                key: const Key('genetic-sire-hamster'),
                label: '公的档案（可选）',
                items: [
                  const IosPickerItem(value: '', label: '（不选档案，仅按表型）'),
                  for (final h in hamsters.where((x) => x.sex != 'female'))
                    IosPickerItem(
                      value: h.id,
                      label:
                          '${h.displayName} · ${h.corePhenotypeLabel ?? '无表型'}',
                    ),
                ],
                selected: sireHamsterId ?? '',
                onSelected: (v) =>
                    onSireHamsterChanged(v == null || v.isEmpty ? null : v),
              ),
              const SizedBox(height: IosMetrics.listGap),
              IosPickerField<String>(
                key: const Key('genetic-dam-hamster'),
                label: '母的档案（可选）',
                items: [
                  const IosPickerItem(value: '', label: '（不选档案，仅按表型）'),
                  for (final h in hamsters.where((x) => x.sex != 'male'))
                    IosPickerItem(
                      value: h.id,
                      label:
                          '${h.displayName} · ${h.corePhenotypeLabel ?? '无表型'}',
                    ),
                ],
                selected: damHamsterId ?? '',
                onSelected: (v) =>
                    onDamHamsterChanged(v == null || v.isEmpty ? null : v),
              ),
              const SizedBox(height: IosMetrics.listGap),
            ],
            OptionOrCustomField(
              key: Key('genetic-sire-phenotype-${current.code}'),
              label: '公的样子',
              options: phenos,
              value: sirePhenotype,
              allowEmpty: false,
              customHint: '自定义公的样子',
              helperText: '列表外名称可以记录；需要推算时请选择列表中的名称',
              onChanged: onSireChanged,
            ),
            const SizedBox(height: IosMetrics.listGap),
            OptionOrCustomField(
              key: Key('genetic-dam-phenotype-${current.code}'),
              label: '母的样子',
              options: phenos,
              value: damPhenotype,
              allowEmpty: false,
              customHint: '自定义母的样子',
              helperText: '列表外名称可以记录；需要推算时请选择列表中的名称',
              onChanged: onDamChanged,
            ),
            const SizedBox(height: IosMetrics.listGap),
            Row(
              children: [
                Text('预计窝产', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(width: 12),
                Expanded(
                  child: CupertinoSlider(
                    key: const Key('genetic-litter-size'),
                    value: litterSize.toDouble().clamp(1, 16),
                    min: 1,
                    max: 16,
                    divisions: 15,
                    onChanged: (v) => onLitterSizeChanged(v.round()),
                  ),
                ),
                Text(
                  '$litterSize 只',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            IosPickerField<String>(
              key: const Key('genetic-simulation-target'),
              label: '重点关注（可选）',
              items: [
                const IosPickerItem(value: '', label: '不特别关注'),
                for (final phenotype in phenos)
                  IosPickerItem(value: phenotype, label: phenotype),
              ],
              selected: phenos.contains(targetPhenotype)
                  ? targetPhenotype!
                  : '',
              onSelected: (value) {
                onTargetChanged(value == null || value.isEmpty ? null : value);
              },
            ),
            const SizedBox(height: IosMetrics.sectionGap),
            Text(
              GeneticsUiCopy.resultHeading,
              key: const Key('genetic-result-title'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            I2AsyncStateView<GeneticSimulationResult>(
              state: simulateState,
              onRetry: onRetrySim,
              emptyBuilder: (_) => const I2StateMessage(
                icon: CupertinoIcons.lab_flask,
                message: GeneticsUiCopy.emptyHint,
              ),
              builder: (result) {
                final mostLikely = mostLikelyOutcome(result.outcomes);
                final targetProbability = phenotypeProbability(
                  result.outcomes,
                  targetPhenotype,
                );
                final targetAtLeastOne = probabilityAtLeastOne(
                  targetProbability,
                  litterSize,
                );
                final conclusion = buildGeneticsConclusion(result);
                final sireHead = formatParentHeadline(
                  sexLabel: '公',
                  phenotypeLabel:
                      result.sirePhenotype ?? result.sire['phenotype'],
                  genotype: result.sire,
                );
                final damHead = formatParentHeadline(
                  sexLabel: '母',
                  phenotypeLabel:
                      result.damPhenotype ?? result.dam['phenotype'],
                  genotype: result.dam,
                );
                final risk = detectRiskPhrase(result);
                final p = ScolvPalette.of(context);
                final toneColor = switch (conclusion.tone) {
                  GeneticsConclusionTone.green => IosColors.systemGreen,
                  GeneticsConclusionTone.blue => IosColors.systemBlue,
                  GeneticsConclusionTone.yellow => IosColors.systemOrange,
                  GeneticsConclusionTone.orange => IosColors.systemOrange,
                  GeneticsConclusionTone.red => IosColors.systemRed,
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // L1 结论先行
                    Container(
                      key: const Key('genetic-l1-conclusion'),
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: toneColor.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(IosMetrics.continuousRadius),
                        border: Border.all(
                          color: toneColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        conclusion.line,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: p.label,
                          height: 1.35,
                        ),
                      ),
                    ),
                    if (risk != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        key: const Key('genetic-risk-banner'),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: IosColors.systemRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            IosMetrics.smallRadius,
                          ),
                        ),
                        child: Text(
                          '${GeneticsUiCopy.riskBanner}\n$risk',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                            color: IosColors.systemRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // 父母：人话主行 + 灰色基因码副行
                    IosGroupedSection(
                      children: [
                        IosListTile(
                          key: const Key('genetic-parent-sire'),
                          leading: const IosGlyph(
                            icon: CupertinoIcons.person,
                            color: IosColors.systemBlue,
                          ),
                          title: sireHead.title,
                          subtitle: sireHead.subtitle,
                          showChevron: false,
                        ),
                        Divider(
                          height: 1,
                          thickness: IosMetrics.hairline,
                          color: p.separator,
                        ),
                        IosListTile(
                          key: const Key('genetic-parent-dam'),
                          leading: const IosGlyph(
                            icon: CupertinoIcons.person,
                            color: IosColors.systemRed,
                          ),
                          title: damHead.title,
                          subtitle: damHead.subtitle,
                          showChevron: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: IosMetrics.listGap),
                    // L2 / L3 宝宝可能长这样
                    Text(
                      GeneticsUiCopy.resultHeading,
                      key: const Key('genetic-offspring-heading'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (result.outcomes.isEmpty)
                      IosGroupedSection(
                        children: [
                          IosListTile(
                            key: const Key('genetic-missing-data'),
                            title: GeneticsUiCopy.missingData,
                            subtitle: '先补齐父母的表型资料再试',
                            trailing: Text(
                              GeneticsUiCopy.fillDataCta,
                              style: TextStyle(
                                color: p.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            showChevron: false,
                          ),
                        ],
                      )
                    else
                      IosGroupedSection(
                        children: [
                          for (var i = 0; i < result.outcomes.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                thickness: IosMetrics.hairline,
                                color: p.separator,
                              ),
                            Builder(
                              builder: (context) {
                                final outcome = result.outcomes[i];
                                final isTop = mostLikely != null &&
                                    outcome.phenotypeLabel ==
                                        mostLikely.phenotypeLabel &&
                                    outcome.probability ==
                                        mostLikely.probability;
                                return IosListTile(
                                  key: isTop
                                      ? const Key('genetic-most-likely')
                                      : Key(
                                          'genetic-outcome-${outcome.phenotypeLabel}',
                                        ),
                                  leading: IosGlyph(
                                    icon: isTop
                                        ? CupertinoIcons.star_fill
                                        : CupertinoIcons.circle_fill,
                                    color: isTop
                                        ? IosColors.systemOrange
                                        : IosColors.systemTeal,
                                  ),
                                  title: displayPhenotypeLabel(
                                    outcome.phenotypeLabel,
                                  ),
                                  subtitle: formatExpectedPupsLine(
                                    outcome.probability,
                                    litterSize,
                                  ),
                                  trailing: Text(
                                    formatGeneticsPercent(outcome.probability),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  showChevron: false,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    if (targetPhenotype != null &&
                        targetPhenotype!.isNotEmpty) ...[
                      const SizedBox(height: IosMetrics.listGap),
                      IosGroupedSection(
                        children: [
                          IosListTile(
                            key: const Key('genetic-target-at-least-one'),
                            leading: const IosGlyph(
                              icon: CupertinoIcons.scope,
                              color: IosColors.systemGreen,
                            ),
                            title: '出现「$targetPhenotype」的机会',
                            subtitle: '这一窝至少出现 1 只',
                            trailing: Text(
                              formatGeneticsPercent(targetAtLeastOne),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            showChevron: false,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: IosMetrics.sectionGap),
                    // L4 专业信息默认折叠
                    Theme(
                      data: Theme.of(context).copyWith(dividerColor: p.separator),
                      child: ExpansionTile(
                        key: const Key('genetic-l4-professional'),
                        initiallyExpanded: false,
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          GeneticsUiCopy.professionalSectionTitle,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              result.consumerPredictionBasisLabel,
                              key: const Key('genetic-prediction-basis'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (result.seriesName != null ||
                              result.series != null)
                            Text(
                              '系列：${result.seriesName ?? result.series}'
                              '${result.tableVersion == null || result.tableVersion!.isEmpty ? '' : ' · ${result.tableVersion}'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '父本携带：${summarizeGenotypeCarries(result.sire)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '母本携带：${summarizeGenotypeCarries(result.dam)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          for (final outcome in result.outcomes)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${outcome.phenotypeLabel} · ${outcome.genotypeKey}'
                                '${outcome.genotype['fraction'] != null && outcome.genotype['fraction']!.isNotEmpty ? ' · ${outcome.genotype['fraction']}' : ''}'
                                ' · ${formatGeneticsPercent(outcome.probability)}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: p.secondaryLabel),
                              ),
                            ),
                          if (result.notes.trim().isNotEmpty)
                            Text(
                              result.notes,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: p.tertiaryLabel),
                            ),
                        ],
                      ),
                    ),
                    if (canCreatePlan) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        key: const Key('genetic-create-plan'),
                        onPressed: onCreatePlan,
                        icon: const Icon(CupertinoIcons.doc_on_clipboard),
                        label: const Text(GeneticsUiCopy.savePlanCta),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}


class _TargetTab extends StatelessWidget {
  const _TargetTab({
    required this.catalogState,
    required this.seriesCode,
    required this.targetPhenotype,
    required this.targetState,
    required this.onSeriesChanged,
    required this.onTargetChanged,
    required this.onRetryCatalog,
    required this.onRetryTarget,
    required this.onApplyPair,
  });

  final I2AsyncState<PhenotypeCatalog> catalogState;
  final String? seriesCode;
  final String? targetPhenotype;
  final I2AsyncState<List<TargetCrossRecommendation>> targetState;
  final ValueChanged<String> onSeriesChanged;
  final ValueChanged<String?> onTargetChanged;
  final VoidCallback onRetryCatalog;
  final VoidCallback onRetryTarget;
  final void Function(String parentA, String parentB) onApplyPair;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<PhenotypeCatalog>(
      state: catalogState,
      onRetry: onRetryCatalog,
      builder: (catalog) {
        final series = catalog.series;
        if (series.isEmpty) {
          return const I2StateMessage(
            icon: CupertinoIcons.exclamationmark_triangle,
            message: '暂时没有可用的表型数据',
          );
        }
        final current = series.firstWhere(
          (s) => s.code == seriesCode,
          orElse: () => series.first,
        );
        final phenos = current.phenotypes;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            Text(
              '想要某一种表型时，反查更合适的亲本组合。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            IosPickerField<String>(
              key: const Key('genetic-target-series'),
              label: '系列',
              items: [
                for (final s in series)
                  IosPickerItem(value: s.code, label: s.name),
              ],
              selected: current.code,
              onSelected: (v) {
                if (v != null) onSeriesChanged(v);
              },
            ),
            const SizedBox(height: IosMetrics.listGap),
            OptionOrCustomField(
              key: Key('genetic-target-phenotype-${current.code}'),
              label: '目标后代表型',
              options: phenos,
              value: targetPhenotype,
              allowEmpty: false,
              customHint: '自定义目标表型',
              helperText: '需要从列表中选择名称，才能找到合适的组合',
              onChanged: onTargetChanged,
            ),
            const SizedBox(height: IosMetrics.sectionGap),
            Text(
              '推荐组合（按目标概率降序）',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            I2AsyncStateView<List<TargetCrossRecommendation>>(
              state: targetState,
              onRetry: onRetryTarget,
              emptyBuilder: (_) => const I2StateMessage(
                icon: CupertinoIcons.search,
                message: '选择目标表型后点击「查找组合」',
              ),
              builder: (items) {
                return IosGroupedSection(
                  children: [
                    for (final item in items)
                      IosListTile(
                        key: Key(
                          'genetic-target-${item.parentA}-${item.parentB}',
                        ),
                        title: '${item.parentA} × ${item.parentB}',
                        subtitle: [
                          if (item.targetFraction != null &&
                              item.targetFraction!.isNotEmpty)
                            item.targetFraction!,
                          '点按可填入配对模拟',
                        ].join(' · '),
                        trailing: Text(
                          item.percentLabel,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        onTap: () => onApplyPair(item.parentA, item.parentB),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _FeedbackTab extends StatefulWidget {
  const _FeedbackTab({
    required this.catalogState,
    required this.seriesCode,
    required this.sirePhenotype,
    required this.damPhenotype,
    required this.compareState,
    required this.summaryState,
    required this.onSeriesChanged,
    required this.onSireChanged,
    required this.onDamChanged,
    required this.onRetryCatalog,
    required this.onRetrySummary,
    required this.onCompare,
  });

  final I2AsyncState<PhenotypeCatalog> catalogState;
  final String? seriesCode;
  final String? sirePhenotype;
  final String? damPhenotype;
  final I2AsyncState<PhenotypeCompareResult> compareState;
  final I2AsyncState<List<PhenotypeFeedbackPairSummary>> summaryState;
  final ValueChanged<String> onSeriesChanged;
  final ValueChanged<String?> onSireChanged;
  final ValueChanged<String?> onDamChanged;
  final VoidCallback onRetryCatalog;
  final VoidCallback onRetrySummary;
  final Future<void> Function(Map<String, int> counts) onCompare;

  @override
  State<_FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<_FeedbackTab> {
  final Map<String, TextEditingController> _countCtrls = {};
  final _liveCtrl = TextEditingController();
  final _customPhenoNameCtrl = TextEditingController();

  /// Extra free-text phenotype labels not in the core catalog list.
  final List<String> _extraPhenos = [];
  String? _countError;

  @override
  void dispose() {
    _liveCtrl.dispose();
    _customPhenoNameCtrl.dispose();
    for (final c in _countCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _ctrlFor(String phenotype) {
    return _countCtrls.putIfAbsent(phenotype, () {
      final c = TextEditingController(text: '0');
      c.addListener(() => setState(() => _countError = null));
      return c;
    });
  }

  Map<String, int> _readCounts(List<String> phenos) {
    final out = <String, int>{};
    for (final p in phenos) {
      final n = int.tryParse(_ctrlFor(p).text.trim()) ?? 0;
      if (n > 0) out[p] = n;
    }
    for (final p in _extraPhenos) {
      final n = int.tryParse(_ctrlFor(p).text.trim()) ?? 0;
      if (n > 0) out[p] = n;
    }
    return out;
  }

  void _addCustomPhenotype(List<String> catalogPhenos) {
    final name = _customPhenoNameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _countError = '请先输入表型名称');
      return;
    }
    if (catalogPhenos.contains(name) || _extraPhenos.contains(name)) {
      setState(() => _countError = '该表型已在列表中，直接改计数即可');
      return;
    }
    setState(() {
      _extraPhenos.add(name);
      _ctrlFor(name);
      _customPhenoNameCtrl.clear();
      _countError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<PhenotypeCatalog>(
      state: widget.catalogState,
      onRetry: widget.onRetryCatalog,
      builder: (catalog) {
        final series = catalog.series;
        if (series.isEmpty) {
          return const I2StateMessage(
            icon: CupertinoIcons.exclamationmark_triangle,
            message: '暂时没有可用的表型数据',
          );
        }
        final current = series.firstWhere(
          (s) => s.code == widget.seriesCode,
          orElse: () => series.first,
        );
        final phenos = current.phenotypes;
        final counts = _readCounts(phenos);
        final liveHint = int.tryParse(_liveCtrl.text.trim());
        final validation = liveHint == null
            ? null
            : PhenotypeCountValidation(livePups: liveHint, counts: counts);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            Text(
              '产仔后记录每种表型的数量，看看实际结果。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            IosPickerField<String>(
              key: Key('genetic-fb-series-${current.code}'),
              label: '系列',
              items: [
                for (final s in series)
                  IosPickerItem(value: s.code, label: s.name),
              ],
              selected: current.code,
              onSelected: (v) {
                if (v != null) widget.onSeriesChanged(v);
              },
            ),
            const SizedBox(height: IosMetrics.listGap),
            OptionOrCustomField(
              key: Key('genetic-fb-sire-${current.code}'),
              label: '公的样子',
              options: phenos,
              value: widget.sirePhenotype,
              allowEmpty: false,
              customHint: '自定义公的样子',
              helperText: '需要从列表中选择名称，才能比较预计和实际',
              onChanged: widget.onSireChanged,
            ),
            const SizedBox(height: IosMetrics.listGap),
            OptionOrCustomField(
              key: Key('genetic-fb-dam-${current.code}'),
              label: '母的样子',
              options: phenos,
              value: widget.damPhenotype,
              allowEmpty: false,
              customHint: '自定义母的样子',
              helperText: '需要从列表中选择名称，才能比较预计和实际',
              onChanged: widget.onDamChanged,
            ),
            const SizedBox(height: 16),
            Text(
              '本窝实际表型计数',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('genetic-fb-live'),
              controller: _liveCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _countError = null),
              decoration: InputDecoration(
                labelText: '活仔总数（校验用）',
                helperText: '填写后：表型合计必须等于活仔数',
                border: const OutlineInputBorder(),
                isDense: true,
                errorText: _countError ?? validation?.errorMessage,
              ),
            ),
            const SizedBox(height: 8),
            if (validation != null)
              Text(
                validation.hasAnyCount
                    ? '表型合计 ${validation.sum} / 活仔 ${validation.livePups}'
                          '${validation.isValid ? ' ✓' : ''}'
                    : '尚未填表型计数',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: validation.isValid
                      ? Colors.green.shade700
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            const SizedBox(height: 8),
            for (final p in phenos) ...[
              TextField(
                key: Key('genetic-fb-count-$p'),
                controller: _ctrlFor(p),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: p,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
            ],
            for (final p in _extraPhenos) ...[
              TextField(
                key: Key('genetic-fb-count-extra-$p'),
                controller: _ctrlFor(p),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: '$p（手填）',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle, size: 18),
                    onPressed: () {
                      setState(() {
                        _extraPhenos.remove(p);
                        _countCtrls.remove(p)?.dispose();
                        _countError = null;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('genetic-fb-custom-name'),
                    controller: _customPhenoNameCtrl,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: '其他表型名称',
                      hintText: '不在列表中的表型',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addCustomPhenotype(phenos),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton.icon(
                    key: const Key('genetic-fb-add-custom'),
                    onPressed: () => _addCustomPhenotype(phenos),
                    icon: const Icon(CupertinoIcons.add, size: 16),
                    label: const Text('添加'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('genetic-fb-submit'),
              onPressed: () {
                final counts = _readCounts(phenos);
                final live = int.tryParse(_liveCtrl.text.trim());
                if (live != null) {
                  final v = PhenotypeCountValidation(
                    livePups: live,
                    counts: counts,
                  );
                  if (!v.isValid) {
                    setState(() => _countError = v.errorMessage);
                    return;
                  }
                }
                if (counts.isEmpty) {
                  setState(() => _countError = '请至少填写一个表型计数');
                  return;
                }
                widget.onCompare(counts);
              },
              icon: const Icon(CupertinoIcons.chart_bar_alt_fill),
              label: const Text('对比并记入统计'),
            ),
            const SizedBox(height: 16),
            I2AsyncStateView<PhenotypeCompareResult>(
              state: widget.compareState,
              onRetry: () {
                final counts = _readCounts(phenos);
                widget.onCompare(counts);
              },
              emptyBuilder: (_) => const I2StateMessage(
                icon: CupertinoIcons.chart_bar,
                message: '填写实际只数后点击对比',
              ),
              builder: (result) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${result.sirePhenotype} × ${result.damPhenotype} · 合计 ${result.totalActual} 只',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (result.notes.isNotEmpty)
                      Text(
                        '已记录，会让后续预测更贴近实际。',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    IosGroupedSection(
                      children: [
                        for (final row in result.rows)
                          IosListTile(
                            key: Key('genetic-fb-row-${row.phenotype}'),
                            title: row.phenotype,
                            subtitle:
                                '预计约 ${row.expectedCount.toStringAsFixed(1)} 只 · '
                                '实际 ${row.actualCount} 只',
                            trailing: Text(
                              row.predictedPercent,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              '历史记录',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              '记录越多，后续预测会越贴近你自己的繁育结果。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            I2AsyncStateView<List<PhenotypeFeedbackPairSummary>>(
              state: widget.summaryState,
              onRetry: widget.onRetrySummary,
              emptyBuilder: (_) => const I2StateMessage(
                icon: CupertinoIcons.chart_pie,
                message: '暂无历史回填记录',
              ),
              builder: (items) {
                return IosGroupedSection(
                  children: [
                    for (final item in items)
                      IosListTile(
                        key: Key(
                          'genetic-summary-${item.series}-${item.sirePhenotype}-${item.damPhenotype}',
                        ),
                        title: item.pairLabel,
                        subtitle:
                            '${item.series} · 样本 ${item.sampleCount} 窝 · '
                            '平均 ${item.avgLitterSize.toStringAsFixed(1)} 只',
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProfilesTab extends StatelessWidget {
  const _ProfilesTab({required this.state, required this.onRetry});

  final I2AsyncState<List<GeneticProfile>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<List<GeneticProfile>>(
      state: state,
      onRetry: onRetry,
      builder: (items) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 88),
          children: [
            IosGroupedSection(
              children: [
                for (final item in items)
                  IosListTile(
                    key: Key('genetic-profile-${item.id}'),
                    leading: const IosGlyph(
                      icon: CupertinoIcons.lab_flask_solid,
                      color: IosColors.systemIndigo,
                    ),
                    title: item.name,
                    subtitle:
                        '${item.phenotypeSummary}\n${item.genotypeSummary} · ${item.confidenceLabel}',
                    showChevron: false,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// CupertinoAlertDialog 内用的统一选择行。
class _IosAlertPicker extends StatelessWidget {
  const _IosAlertPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.displayName,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String Function(String)? displayName;

  @override
  Widget build(BuildContext context) {
    return IosPickerField<String>(
      label: label,
      items: [
        for (final option in options)
          IosPickerItem(
            value: option,
            label: displayName?.call(option) ?? option,
          ),
      ],
      selected: value,
      displayName: displayName,
      onSelected: onChanged,
    );
  }
}
