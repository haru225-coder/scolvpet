import 'package:flutter/material.dart';

import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'genetic_controller.dart';
import 'genetic_models.dart';

/// Genetic profiles + breeding simulator hub (T-P1-06).
class GeneticHubPage extends StatefulWidget {
  const GeneticHubPage({super.key, required this.controller});

  final GeneticController controller;

  @override
  State<GeneticHubPage> createState() => _GeneticHubPageState();
}

class _GeneticHubPageState extends State<GeneticHubPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final Map<String, String> _sire = {
    for (final l in defaultGeneticLoci) l.code: '${l.dominantAllele}/${l.recessiveAllele}',
  };
  final Map<String, String> _dam = {
    for (final l in defaultGeneticLoci) l.code: '${l.dominantAllele}/${l.recessiveAllele}',
  };

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
    widget.controller.refreshAll();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (ok) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('遗传表型与模拟'),
            bottom: TabBar(
              controller: _tabs,
              tabs: const [
                Tab(key: Key('genetic-tab-sim'), text: '配对模拟'),
                Tab(key: Key('genetic-tab-profiles'), text: '档案'),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('genetic-refresh'),
                onPressed: widget.controller.refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: _tabs.index == 1
              ? FloatingActionButton.extended(
                  key: const Key('genetic-fab'),
                  onPressed: _createProfile,
                  icon: const Icon(Icons.add),
                  label: const Text('新建档案'),
                )
              : FloatingActionButton.extended(
                  key: const Key('genetic-run-sim'),
                  onPressed: () => _snack(
                    () => widget.controller.simulate(sire: _sire, dam: _dam),
                  ),
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('开始模拟'),
                ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _SimulatorTab(
                sire: _sire,
                dam: _dam,
                onChanged: () => setState(() {}),
                simulateState: widget.controller.simulateState,
                onRetry: () => widget.controller.simulate(sire: _sire, dam: _dam),
              ),
              _ProfilesTab(
                state: widget.controller.profilesState,
                onRetry: widget.controller.refreshProfiles,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createProfile() async {
    final nameCtrl = TextEditingController();
    final genotype = {
      for (final l in defaultGeneticLoci)
        l.code: '${l.dominantAllele}/${l.dominantAllele}',
    };
    var confidence = 'unknown';
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) {
          return AlertDialog(
            title: const Text('新建遗传档案'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const Key('genetic-profile-name'),
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: '名称',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final locus in defaultGeneticLoci) ...[
                    DropdownButtonFormField<String>(
                      key: Key('genetic-profile-${locus.code}'),
                      initialValue: genotype[locus.code],
                      items: [
                        for (final pair in locus.pairOptions)
                          DropdownMenuItem(value: pair, child: Text(pair)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        genotype[locus.code] = value;
                        setLocal(() {});
                      },
                      decoration: InputDecoration(
                        labelText: '${locus.code} · ${locus.name}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  DropdownButtonFormField<String>(
                    initialValue: confidence,
                    items: const [
                      DropdownMenuItem(value: 'unknown', child: Text('未知')),
                      DropdownMenuItem(value: 'inferred', child: Text('推测')),
                      DropdownMenuItem(value: 'observed', child: Text('实测')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      confidence = value;
                      setLocal(() {});
                    },
                    decoration: const InputDecoration(
                      labelText: '置信度',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
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
    await _snack(
      () => widget.controller.createProfile(
        GeneticProfileDraft(
          name: nameCtrl.text,
          genotype: genotype,
          confidence: confidence,
        ),
      ),
    );
  }
}

class _SimulatorTab extends StatelessWidget {
  const _SimulatorTab({
    required this.sire,
    required this.dam,
    required this.onChanged,
    required this.simulateState,
    required this.onRetry,
  });

  final Map<String, String> sire;
  final Map<String, String> dam;
  final VoidCallback onChanged;
  final I2AsyncState<GeneticSimulationResult> simulateState;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Text(
          '简化孟德尔模型（A/B/C 三位点），仅供教育与配对参考。',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _ParentCard(
          title: '父本（Sire）',
          genotype: sire,
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        _ParentCard(
          title: '母本（Dam）',
          genotype: dam,
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
        Text(
          '模拟结果',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        I2AsyncStateView<GeneticSimulationResult>(
          state: simulateState,
          onRetry: onRetry,
          emptyBuilder: (_) => const I2StateMessage(
            icon: Icons.science_outlined,
            message: '选择父母基因型后点击「开始模拟」',
          ),
          builder: (result) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (result.notes.isNotEmpty)
                  Text(
                    result.notes,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                const SizedBox(height: 8),
                for (final outcome in result.outcomes) ...[
                  Card(
                    child: ListTile(
                      key: Key('genetic-outcome-${outcome.genotypeKey}'),
                      title: Text(outcome.phenotypeLabel),
                      subtitle: Text(
                        outcome.genotype.entries
                            .map((e) => '${e.key}=${e.value}')
                            .join(' · '),
                      ),
                      trailing: Text(
                        outcome.percentLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ParentCard extends StatelessWidget {
  const _ParentCard({
    required this.title,
    required this.genotype,
    required this.onChanged,
  });

  final String title;
  final Map<String, String> genotype;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            for (final locus in defaultGeneticLoci) ...[
              DropdownButtonFormField<String>(
                key: Key('genetic-${title.contains('父') ? 'sire' : 'dam'}-${locus.code}'),
                initialValue: genotype[locus.code],
                items: [
                  for (final pair in locus.pairOptions)
                    DropdownMenuItem(
                      value: pair,
                      child: Text('${locus.code} $pair · ${locus.name}'),
                    ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  genotype[locus.code] = value;
                  onChanged();
                },
                decoration: InputDecoration(
                  labelText: locus.name,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
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
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                key: Key('genetic-profile-${item.id}'),
                leading: const Icon(Icons.biotech_outlined),
                title: Text(item.name),
                subtitle: Text(
                  '${item.phenotypeSummary}\n${item.genotypeSummary} · ${item.confidenceLabel}',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
