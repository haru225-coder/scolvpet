import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../i2/i2_models.dart';
import 'breeding_controller.dart';
import 'breeding_models.dart';

const _accent = Color(0xffc77852);
const _ink = Color(0xff1f2928);
const _muted = Color(0xff6c7774);

class BreedingHubPage extends StatelessWidget {
  const BreedingHubPage({
    super.key,
    required this.controller,
    required this.hamsters,
    required this.enclosures,
    required this.ruleVersionId,
    required this.onOpenLitters,
    this.canWrite = true,
  });

  final BreedingController controller;
  final List<I2Hamster> hamsters;
  final List<I2Enclosure> enclosures;
  final String? ruleVersionId;
  final VoidCallback onOpenLitters;
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            Text(
              '繁育',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '主路径：草稿 → 发布 → 配对 → 分笼 → 孕期 → 产仔',
              style: TextStyle(color: _muted),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.route, color: _accent),
                title: const Text('繁育向导'),
                subtitle: const Text('创建计划并逐步推进到产仔'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => BreedingWizardPage(
                        controller: controller,
                        hamsters: hamsters,
                        enclosures: enclosures,
                        ruleVersionId: ruleVersionId,
                        canWrite: canWrite,
                        onOpenLitters: onOpenLitters,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: const Text('窝次列表'),
                subtitle: const Text('断奶 / 分性 / 个体化入口'),
                trailing: const Icon(Icons.chevron_right),
                onTap: onOpenLitters,
              ),
            ),
            if (controller.listState.hasValue) ...[
              const SizedBox(height: 16),
              Text(
                '最近计划（${controller.listState.data!.length}）',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 8),
              ...controller.listState.data!
                  .take(5)
                  .map(
                    (plan) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(plan.displayName),
                        subtitle: Text(breedingStateLabel(plan.state)),
                        trailing: Chip(label: Text(plan.state)),
                      ),
                    ),
                  ),
            ],
          ],
        );
      },
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
  });

  final BreedingController controller;
  final List<I2Hamster> hamsters;
  final List<I2Enclosure> enclosures;
  final String? ruleVersionId;
  final VoidCallback onOpenLitters;
  final bool canWrite;

  @override
  State<BreedingWizardPage> createState() => _BreedingWizardPageState();
}

class _BreedingWizardPageState extends State<BreedingWizardPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.refresh();
  }

  Future<void> _createPlan() async {
    if (!widget.canWrite) {
      _toast('离线只读，联网后操作');
      return;
    }
    final ruleId = widget.ruleVersionId;
    if (ruleId == null) {
      _toast('请先在「我的 → 物种规则」复制规则');
      return;
    }
    final males = widget.hamsters
        .where((h) => h.sex == 'male' && h.lifecycleStatus != 'archived')
        .toList();
    final females = widget.hamsters
        .where((h) => h.sex == 'female' && h.lifecycleStatus != 'archived')
        .toList();
    if (males.isEmpty || females.isEmpty) {
      _toast('需要至少一只公鼠和一只母鼠');
      return;
    }

    String? sireId = males.first.id;
    String? damId = females.first.id;
    final nameController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('新建繁育计划'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: sireId,
                  decoration: const InputDecoration(labelText: '种公'),
                  items: males
                      .map(
                        (h) => DropdownMenuItem(
                          value: h.id,
                          child: Text(h.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setLocal(() => sireId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: damId,
                  decoration: const InputDecoration(labelText: '种母'),
                  items: females
                      .map(
                        (h) => DropdownMenuItem(
                          value: h.id,
                          child: Text(h.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setLocal(() => damId = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '计划名称（可选）',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    if (ok != true || sireId == null || damId == null) return;
    final success = await widget.controller.createPlan(
      CreateBreedingPlanInput(
        sireId: sireId!,
        damId: damId!,
        ruleVersionId: ruleId,
        name: nameController.text.trim().isEmpty
            ? null
            : nameController.text.trim(),
      ),
    );
    if (!mounted) return;
    _toast(widget.controller.lastMessage ?? (success ? '已创建' : '失败'));
  }

  Future<void> _advance(BreedingPlan plan) async {
    if (!widget.canWrite) {
      _toast('离线只读，联网后操作');
      return;
    }
    if (widget.enclosures.isEmpty) {
      _toast('需要至少一个笼盒');
      return;
    }
    final enclosureId = widget.enclosures.first.id;
    var livePups = 4;

    if (plan.state == 'gestation') {
      final controller = TextEditingController(text: '4');
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('确认产仔'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '活仔数',
              helperText: '填 0 表示无活仔结局',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      livePups = int.tryParse(controller.text.trim()) ?? 0;
    }

    widget.controller.select(plan);
    final ok = await widget.controller.advanceHappyPath(
      enclosureId: enclosureId,
      livePups: livePups,
    );
    if (!mounted) return;
    _toast(widget.controller.lastMessage ?? (ok ? '已推进' : '失败'));
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
        final plans = widget.controller.listState.data ?? const <BreedingPlan>[];
        final busy =
            widget.controller.actionState.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('繁育向导'),
            actions: [
              IconButton(
                onPressed: busy ? null : widget.controller.refresh,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: busy ? null : _createPlan,
            icon: const Icon(Icons.add),
            label: const Text('新建计划'),
          ),
          body: busy && plans.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : plans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sync_alt, size: 48, color: _accent),
                      const SizedBox(height: 12),
                      const Text('还没有繁育计划'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.controller.refresh,
                        child: const Text('刷新'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    final action = nextActionLabel(plan.state);
                    return Card(
                      key: Key('breeding-plan-${plan.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    plan.displayName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Chip(
                                  label: Text(breedingStateLabel(plan.state)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '公 ${plan.sireId.length > 8 ? plan.sireId.substring(0, 8) : plan.sireId}'
                              ' · 母 ${plan.damId.length > 8 ? plan.damId.substring(0, 8) : plan.damId}',
                              style: const TextStyle(color: _muted, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            _StepRail(state: plan.state),
                            const SizedBox(height: 12),
                            if (action != null)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  key: Key('breeding-next-${plan.id}'),
                                  onPressed: busy
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
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
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
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
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
                radius: 12,
                backgroundColor: current >= i
                    ? _accent
                    : const Color(0xffdce5e3),
                foregroundColor: current >= i ? Colors.white : _muted,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _steps[i].$2,
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
