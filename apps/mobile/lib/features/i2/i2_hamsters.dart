import 'package:flutter/material.dart';

import '../health/health_controller.dart';
import '../health/health_models.dart';
import '../tasks/task_controller.dart';
import '../tasks/task_models.dart';
import '../weight/weight_alerts.dart';
import 'i2_controller.dart';
import 'i2_models.dart';
import 'i2_widgets.dart';

class HamsterListPage extends StatefulWidget {
  const HamsterListPage({
    super.key,
    required this.controller,
    this.onOpenDetail,
    this.onCreate,
    this.onBatchCreate,
    this.onOpenLitters,
  });

  final I2Controller controller;
  final ValueChanged<I2Hamster>? onOpenDetail;
  final VoidCallback? onCreate;
  final VoidCallback? onBatchCreate;
  final VoidCallback? onOpenLitters;

  @override
  State<HamsterListPage> createState() => _HamsterListPageState();
}

class _HamsterListPageState extends State<HamsterListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _lifecycle = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final state = widget.controller.snapshotState;
      return Scaffold(
        appBar: AppBar(
          title: const Text('仓鼠'),
          actions: [
            if (widget.onOpenLitters != null)
              IconButton(
                tooltip: '窝次',
                onPressed: widget.onOpenLitters,
                icon: const Icon(Icons.groups_outlined),
              ),
            IconButton(
              tooltip: '重试',
              onPressed: widget.controller.retry,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Column(
          children: [
            I2OfflineBanner(
              offline: widget.controller.offline,
              lastSyncLabel: widget.controller.lastSyncLabel,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: '搜索编号或昵称',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (final item in const [
                    ('all', '全部'),
                    ('active', '在养'),
                    ('retired', '已退役'),
                    ('transferred', '已转出'),
                    ('deceased', '已离世'),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(item.$2),
                        selected: _lifecycle == item.$1,
                        onSelected: (_) => setState(() => _lifecycle = item.$1),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: I2AsyncStateView<I2Snapshot>(
                state: state,
                onRetry: widget.controller.retry,
                builder: (snapshot) {
                  final query = _searchController.text.trim().toLowerCase();
                  final values = snapshot.hamsters.where((hamster) {
                    final matchesQuery =
                        query.isEmpty ||
                        hamster.internalCode.toLowerCase().contains(query) ||
                        (hamster.name ?? '').toLowerCase().contains(query);
                    final matchesLifecycle =
                        _lifecycle == 'all' ||
                        hamster.lifecycleStatus == _lifecycle;
                    return matchesQuery && matchesLifecycle;
                  }).toList();
                  if (values.isEmpty) {
                    return const I2StateMessage(
                      icon: Icons.pets_outlined,
                      message: '没有匹配的仓鼠',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: values.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final hamster = values[index];
                      final weightAlert =
                          snapshot.recentWeights
                              .where((w) => w.hamsterId == hamster.id)
                              .toList()
                            ..sort(
                              (a, b) =>
                                  b.recordedAt.compareTo(a.recordedAt),
                            );
                      final latest = weightAlert.isEmpty
                          ? null
                          : weightAlert.first;
                      final abnormal = latest != null &&
                          evaluateWeightFlags(latest).isNotEmpty;
                      return Card(
                        color: abnormal ? const Color(0xffffe8e5) : null,
                        child: ListTile(
                          onTap: widget.onOpenDetail == null
                              ? null
                              : () => widget.onOpenDetail!(hamster),
                          leading: CircleAvatar(
                            backgroundColor: abnormal
                                ? const Color(0xffb6534a)
                                : null,
                            child: Text(i2SexLabel(hamster.sex)),
                          ),
                          title: Text(hamster.displayName),
                          subtitle: Text(
                            '${hamster.varietyCode ?? '未填品系'} · '
                            '${i2LifecycleLabel(hamster.lifecycleStatus)} · '
                            '笼盒 ${hamster.currentEnclosureId ?? '未分配'}'
                            '${latest == null ? '' : ' · ${latest.weightG} g'}'
                            '${abnormal ? ' · 体重异常' : ''}',
                          ),
                          trailing: Icon(
                            abnormal
                                ? Icons.warning_amber_rounded
                                : Icons.chevron_right,
                            color: abnormal ? const Color(0xffb6534a) : null,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton:
            widget.onCreate == null && widget.onBatchCreate == null
            ? null
            : PopupMenuButton<String>(
                tooltip: '建档',
                icon: const Icon(Icons.add),
                onSelected: (value) {
                  if (value == 'single') widget.onCreate?.call();
                  if (value == 'batch') widget.onBatchCreate?.call();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'single', child: Text('单只建档 · A02')),
                  PopupMenuItem(value: 'batch', child: Text('批量建档 · A03')),
                ],
              ),
      );
    },
  );
}

class HamsterDetailPage extends StatefulWidget {
  const HamsterDetailPage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.onEdit,
    this.onAddWeight,
    this.onOpenPedigree,
    this.onOpenHealth,
    this.taskController,
    this.healthController,
  });

  final I2Controller controller;
  final String hamsterId;
  final VoidCallback? onEdit;
  final VoidCallback? onAddWeight;
  final VoidCallback? onOpenPedigree;
  final VoidCallback? onOpenHealth;
  final TaskController? taskController;
  final HealthController? healthController;

  @override
  State<HamsterDetailPage> createState() => _HamsterDetailPageState();
}

class _HamsterDetailPageState extends State<HamsterDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadHamsterDetail(widget.hamsterId);
    widget.taskController?.refresh();
    widget.healthController?.loadForHamster(widget.hamsterId);
  }

  Future<void> _completeTask(CareTaskItem task) async {
    final tc = widget.taskController;
    if (tc == null) return;
    final ok = await tc.complete(task);
    if (!mounted) return;
    final message = tc.lastMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    if (ok) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final listenables = <Listenable>[widget.controller];
    if (widget.taskController != null) {
      listenables.add(widget.taskController!);
    }
    if (widget.healthController != null) {
      listenables.add(widget.healthController!);
    }
    return AnimatedBuilder(
      animation: Listenable.merge(listenables),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: const Text('仓鼠详情'),
          actions: [
            if (widget.onEdit != null)
              IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit),
              ),
          ],
        ),
        body: Column(
          children: [
            I2OfflineBanner(
              offline: widget.controller.offline,
              lastSyncLabel: widget.controller.lastSyncLabel,
            ),
            Expanded(
              child: I2AsyncStateView<I2HamsterDetail>(
                state: widget.controller.hamsterDetailState,
                onRetry: () =>
                    widget.controller.loadHamsterDetail(widget.hamsterId),
                builder: (detail) {
                  final relatedTasks = CareTaskItem.openForHamster(
                    widget.taskController?.listState.data ??
                        const <CareTaskItem>[],
                    widget.hamsterId,
                  );
                  final healthRecords =
                      widget.healthController?.listState.data ??
                      const <HealthRecordItem>[];
                  final children = <Widget>[
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                child: Text(i2SexLabel(detail.hamster.sex)),
                              ),
                              title: Text(detail.hamster.displayName),
                              subtitle: Text(
                                i2LifecycleLabel(
                                  detail.hamster.lifecycleStatus,
                                ),
                              ),
                            ),
                            I2InfoTile(
                              label: '品系',
                              value: detail.hamster.varietyCode ?? '—',
                            ),
                            I2InfoTile(
                              label: '出生日期',
                              value: i2DateLabel(detail.hamster.birthDate),
                            ),
                            I2InfoTile(
                              label: '当前笼盒',
                              value:
                                  detail.hamster.currentEnclosureId ?? '未分配',
                            ),
                            I2InfoTile(
                              label: '备注',
                              value: detail.hamster.notes ?? '—',
                            ),
                          ],
                        ),
                      ),
                      if (widget.onOpenPedigree != null ||
                          widget.onOpenHealth != null) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (widget.onOpenPedigree != null)
                              OutlinedButton.icon(
                                key: const Key('hamster-open-pedigree'),
                                onPressed: widget.onOpenPedigree,
                                icon: const Icon(Icons.account_tree_outlined),
                                label: const Text('谱系'),
                              ),
                            if (widget.onOpenHealth != null)
                              OutlinedButton.icon(
                                key: const Key('hamster-open-health'),
                                onPressed: widget.onOpenHealth,
                                icon: const Icon(
                                  Icons.health_and_safety_outlined,
                                ),
                                label: const Text('健康快捷记录'),
                              ),
                          ],
                        ),
                      ],
                      if (widget.taskController != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          '护理待办',
                          key: const Key('hamster-care-tasks-title'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (relatedTasks.isEmpty)
                          const Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              title: Text('暂无与此个体相关的待办'),
                            ),
                          )
                        else
                          for (final task in relatedTasks)
                            Card(
                              key: Key('hamster-care-task-${task.id}'),
                              color: task.isOverdue
                                  ? const Color(0xffffe8e5)
                                  : null,
                              child: ListTile(
                                title: Text(task.displayTitle),
                                subtitle: Text(
                                  '${taskTypeLabel(task.taskType)} · '
                                  '${task.isOverdue ? '已逾期 · ' : ''}'
                                  '${i2DateTimeLabel(task.scheduledAt)}',
                                ),
                                trailing: widget.controller.canWrite
                                    ? TextButton(
                                        key: Key(
                                          'hamster-complete-task-${task.id}',
                                        ),
                                        onPressed: () => _completeTask(task),
                                        child: const Text('完成'),
                                      )
                                    : null,
                              ),
                            ),
                      ],
                      if (widget.healthController != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '近期健康',
                              key: const Key('hamster-health-title'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (widget.onOpenHealth != null)
                              TextButton(
                                onPressed: widget.onOpenHealth,
                                child: const Text('全部'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (healthRecords.isEmpty)
                          const Text('暂无健康记录')
                        else
                          for (final record in healthRecords.take(3))
                            ListTile(
                              dense: true,
                              key: Key(
                                'hamster-health-preview-${record.id}',
                              ),
                              leading: const Icon(
                                Icons.health_and_safety_outlined,
                              ),
                              title: Text(record.typeLabel),
                              subtitle: Text(
                                [
                                  i2DateTimeLabel(record.observedAt),
                                  if (record.notes != null &&
                                      record.notes!.isNotEmpty)
                                    record.notes!,
                                ].join(' · '),
                              ),
                            ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '体重历史',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (widget.onAddWeight != null)
                            I2WriteButton(
                              enabled: widget.controller.canWrite,
                              label: '录入',
                              icon: Icons.monitor_weight_outlined,
                              onPressed: widget.onAddWeight,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (detail.weights.isEmpty)
                        const Text('暂无体重记录')
                      else
                        ...detail.weights.map((weight) {
                          final flags = evaluateWeightFlags(weight);
                          final abnormal = flags.isNotEmpty;
                          return ListTile(
                            dense: true,
                            tileColor: abnormal
                                ? const Color(0xffffe8e5)
                                : null,
                            leading: Icon(
                              Icons.monitor_weight_outlined,
                              color: abnormal
                                  ? const Color(0xffb6534a)
                                  : null,
                            ),
                            title: Text(
                              '${weight.weightG} g'
                              '${abnormal ? ' · 异常' : ''}',
                              style: TextStyle(
                                color: abnormal
                                    ? const Color(0xffb6534a)
                                    : null,
                                fontWeight: abnormal ? FontWeight.w700 : null,
                              ),
                            ),
                            subtitle: Text(
                              '${i2DateTimeLabel(weight.recordedAt)} · ${weight.source}'
                              '${weight.measurementKind == 'individual' ? '' : ' · ${weight.measurementKind}'}'
                              '${flags.isEmpty ? '' : ' · ${flags.join(', ')}'}',
                            ),
                            trailing: Text(
                              weight.changeFromPreviousG == null
                                  ? ''
                                  : '${weight.changeFromPreviousG! >= 0 ? '+' : ''}${weight.changeFromPreviousG} g',
                              style: TextStyle(
                                color: (weight.changeFromPreviousG ?? 0) < 0
                                    ? const Color(0xffb6534a)
                                    : null,
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 16),
                      Text(
                        '历史窝次',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (detail.litters.isEmpty)
                        const Text('暂无关联窝次')
                      else
                        ...detail.litters.map(
                          (litter) => Card(
                            child: ListTile(
                              title: Text(
                                '${i2DateLabel(litter.bornAt)} · ${i2LitterStateLabel(litter.state)}',
                              ),
                              subtitle: Text(
                                '初始 ${litter.initialAliveCount} 只 · 当前 ${litter.currentManagedCount} 只',
                              ),
                            ),
                          ),
                        ),
                  ];
                  // SingleChildScrollView keeps all sections mounted (care/health
                  // previews are short; avoids lazy ListView eliding offscreen keys).
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LitterListPage extends StatelessWidget {
  const LitterListPage({super.key, required this.controller});

  final I2Controller controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('窝次')),
      body: Column(
        children: [
          I2OfflineBanner(
            offline: controller.offline,
            lastSyncLabel: controller.lastSyncLabel,
          ),
          Expanded(
            child: I2AsyncStateView<I2Snapshot>(
              state: controller.snapshotState,
              onRetry: controller.retry,
              builder: (snapshot) => snapshot.litters.isEmpty
                  ? const I2StateMessage(
                      icon: Icons.groups_outlined,
                      message: '暂无窝次记录',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: snapshot.litters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final litter = snapshot.litters[index];
                        return Card(
                          child: ListTile(
                            title: Text(i2LitterStateLabel(litter.state)),
                            subtitle: Text(
                              '${i2DateLabel(litter.bornAt)} · '
                              '初始 ${litter.initialAliveCount} 只 · '
                              '当前 ${litter.currentManagedCount} 只',
                            ),
                            trailing: Chip(label: Text(litter.state)),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    ),
  );
}

class HamsterEditorPage extends StatefulWidget {
  const HamsterEditorPage({
    super.key,
    required this.controller,
    required this.speciesRuleVersionId,
    this.existing,
    this.onSaved,
  });

  final I2Controller controller;
  final String speciesRuleVersionId;
  final I2Hamster? existing;
  final VoidCallback? onSaved;

  @override
  State<HamsterEditorPage> createState() => _HamsterEditorPageState();
}

class _HamsterEditorPageState extends State<HamsterEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _variety;
  late final TextEditingController _notes;
  String _sex = 'unknown';

  @override
  void initState() {
    super.initState();
    final value = widget.existing;
    _code = TextEditingController(text: value?.internalCode);
    _name = TextEditingController(text: value?.name);
    _variety = TextEditingController(text: value?.varietyCode);
    _notes = TextEditingController(text: value?.notes);
    _sex = value?.sex ?? 'unknown';
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _variety.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!widget.controller.canWrite) {
      await widget.controller.saveDraft(
        I2Draft(
          id: 'hamster-form-${DateTime.now().microsecondsSinceEpoch}',
          kind: 'hamster',
          payload: {
            'internal_code': _code.text.trim(),
            'name': _name.text.trim(),
          },
        ),
      );
      return;
    }
    if (widget.existing == null) {
      await widget.controller.createHamster(
        I2HamsterDraft(
          internalCode: _code.text.trim(),
          name: _name.text.trim().isEmpty ? null : _name.text.trim(),
          speciesRuleVersionId: widget.speciesRuleVersionId,
          sex: _sex,
          sourceType: 'introduced',
          varietyCode: _variety.text.trim().isEmpty
              ? null
              : _variety.text.trim(),
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        ),
      );
    } else {
      await widget.controller.updateHamster(
        widget.existing!.id,
        widget.existing!.version,
        I2HamsterUpdate(
          internalCode: _code.text.trim(),
          name: _name.text.trim(),
          varietyCode: _variety.text.trim(),
          sex: _sex,
          notes: _notes.text.trim(),
        ),
      );
    }
    if (mounted && widget.controller.actionState.status == I2AsyncStatus.data) {
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.existing == null ? '编辑建档 · A02' : '编辑仓鼠'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _code,
            decoration: const InputDecoration(labelText: '内部编号 *'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? '请填写内部编号' : null,
          ),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: '昵称'),
          ),
          TextFormField(
            controller: _variety,
            decoration: const InputDecoration(labelText: '品系'),
          ),
          DropdownButtonFormField<String>(
            initialValue: _sex,
            decoration: const InputDecoration(labelText: '性别'),
            items: const [
              DropdownMenuItem(value: 'unknown', child: Text('待定')),
              DropdownMenuItem(value: 'male', child: Text('公')),
              DropdownMenuItem(value: 'female', child: Text('母')),
            ],
            onChanged: widget.controller.canWrite
                ? (value) => setState(() => _sex = value!)
                : null,
          ),
          TextFormField(
            controller: _notes,
            decoration: const InputDecoration(labelText: '备注'),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          I2WriteButton(
            enabled: widget.controller.canWrite,
            label: '保存',
            icon: Icons.save_outlined,
            onPressed: _save,
          ),
          if (widget.controller.offline)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('当前为离线只读，保存内容会进入本地草稿。'),
            ),
        ],
      ),
    ),
  );
}

class BatchHamsterEditorPage extends StatefulWidget {
  const BatchHamsterEditorPage({
    super.key,
    required this.controller,
    required this.speciesRuleVersionId,
    this.onSaved,
  });

  final I2Controller controller;
  final String speciesRuleVersionId;
  final VoidCallback? onSaved;

  @override
  State<BatchHamsterEditorPage> createState() => _BatchHamsterEditorPageState();
}

class _BatchHamsterEditorPageState extends State<BatchHamsterEditorPage> {
  final _codes = TextEditingController();
  final _namePrefix = TextEditingController();
  String _sex = 'unknown';

  @override
  void dispose() {
    _codes.dispose();
    _namePrefix.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final codes = _codes.text
        .split(RegExp(r'[\s,，;；]+'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    if (codes.isEmpty) return;
    await widget.controller.createHamsters(
      codes
          .map(
            (code) => I2HamsterDraft(
              internalCode: code,
              name: _namePrefix.text.trim().isEmpty
                  ? null
                  : '${_namePrefix.text.trim()}$code',
              speciesRuleVersionId: widget.speciesRuleVersionId,
              sex: _sex,
              sourceType: 'born_here',
            ),
          )
          .toList(),
    );
    if (mounted && widget.controller.actionState.status == I2AsyncStatus.data) {
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('批量建档 · A03')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _codes,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: '内部编号 *',
            hintText: '可用换行、逗号或分号分隔',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _namePrefix,
          decoration: const InputDecoration(labelText: '公共昵称前缀（可选）'),
        ),
        DropdownButtonFormField<String>(
          initialValue: _sex,
          decoration: const InputDecoration(labelText: '公共性别'),
          items: const [
            DropdownMenuItem(value: 'unknown', child: Text('待定')),
            DropdownMenuItem(value: 'male', child: Text('公')),
            DropdownMenuItem(value: 'female', child: Text('母')),
          ],
          onChanged: widget.controller.canWrite
              ? (value) => setState(() => _sex = value!)
              : null,
        ),
        const SizedBox(height: 20),
        I2WriteButton(
          enabled: widget.controller.canWrite,
          label: '逐只确认并提交',
          icon: Icons.playlist_add,
          onPressed: _save,
        ),
      ],
    ),
  );
}

class WeightEntryPage extends StatefulWidget {
  const WeightEntryPage({
    super.key,
    required this.controller,
    required this.hamsterId,
    this.onSaved,
  });

  final I2Controller controller;
  final String hamsterId;
  final VoidCallback? onSaved;

  @override
  State<WeightEntryPage> createState() => _WeightEntryPageState();
}

class _WeightEntryPageState extends State<WeightEntryPage> {
  final _weight = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = num.tryParse(_weight.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入大于 0 的克值')),
      );
      return;
    }
    await widget.controller.createWeight(
      I2WeightDraft(
        hamsterId: widget.hamsterId,
        weightG: value,
        recordedAt: DateTime.now(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      ),
    );
    if (mounted && widget.controller.actionState.status == I2AsyncStatus.data) {
      final latest = widget.controller.weightState.data;
      final alert = latest != null &&
              latest.isNotEmpty &&
              latest.first.alertFlags.isNotEmpty;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alert ? '已保存 $value g（检测到体重异常）' : '已保存 $value g',
          ),
        ),
      );
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('录入体重')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '单位：克（g）。服务端会快照上次体重差；客户端会标记掉重/过低。',
          style: TextStyle(color: Color(0xff6c7774), fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '体重（g） *',
            helperText: '必须 > 0',
          ),
        ),
        TextField(
          controller: _notes,
          decoration: const InputDecoration(labelText: '备注'),
        ),
        const SizedBox(height: 20),
        I2WriteButton(
          enabled: widget.controller.canWrite,
          label: '保存体重',
          icon: Icons.save_outlined,
          onPressed: _save,
        ),
      ],
    ),
  );
}
