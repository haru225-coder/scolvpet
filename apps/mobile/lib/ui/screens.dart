import 'package:flutter/material.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

import '../core/app_state.dart';
import '../features/i2/i2.dart';
import '../features/i6/data_center.dart';
import '../features/breeding/breeding.dart';
import '../features/litter/litter.dart';
import '../features/calendar/calendar.dart';
import '../features/health/health.dart';
import '../features/accounting/accounting.dart';
import '../features/contracts/contracts.dart';
import '../features/crm/crm.dart';
import '../features/genetic/genetic.dart';
import '../features/home_widget/home_widget.dart';
import '../features/members/members.dart';
import '../features/assistant/assistant.dart';
import '../features/miniprogram/miniprogram.dart';
import '../features/paywall/paywall.dart';
import '../features/pedigree/pedigree.dart';
import '../features/public_site/public_site.dart';
import '../features/push/push.dart';
import '../features/shell/home_overview.dart';
import '../features/tasks/tasks.dart';
import '../features/weight/weight_batch_page.dart';

const _accent = Color(0xffc77852);
const _ink = Color(0xff1f2928);
const _muted = Color(0xff6c7774);
const _depth = Color(0xffdce5e3);

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.state});

  final AppState state;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final controller = TextEditingController(text: '+8613800138000');

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
          children: [
            const _BrandPanel(),
            const SizedBox(height: 48),
            const Text(
              '中国大陆手机号',
              style: TextStyle(color: _muted, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '+8613800138000'),
            ),
            const SizedBox(height: 20),
            _PrimaryButton(
              label: '获取验证码',
              icon: Icons.sms_outlined,
              onPressed: () async {
                await widget.state.requestCode(controller.text.trim());
                if (!context.mounted) return;
                if (widget.state.phase == AppPhase.code) setState(() {});
              },
            ),
            if (widget.state.lastError != null)
              _ErrorText(widget.state.lastError!),
            const SizedBox(height: 16),
            const Text(
              '首次登录会创建个人熊舍',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class CodeScreen extends StatefulWidget {
  const CodeScreen({super.key, required this.state});

  final AppState state;

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('输入验证码'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '已发送至 ${widget.state.phone ?? ''}',
            style: const TextStyle(color: _muted),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            maxLength: 6,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '验证码',
              counterText: '',
            ),
          ),
          const SizedBox(height: 16),
          _PrimaryButton(
            label: '验证并登录',
            icon: Icons.login,
            onPressed: () async {
              await widget.state.login(controller.text.trim());
              if (!context.mounted) return;
              setState(() {});
            },
          ),
          if (widget.state.lastError != null)
            _ErrorText(widget.state.lastError!),
        ],
      ),
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key, required this.state});

  final AppState state;

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final TextEditingController nameController;
  bool importLater = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.state.organization?.name == '我的熊舍'
          ? ''
          : widget.state.organization?.name,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.state.offline;
    return Scaffold(
      appBar: AppBar(title: const Text('创建个人熊舍')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('首版为单舍主账号', style: TextStyle(color: _muted)),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            enabled: !disabled,
            decoration: const InputDecoration(
              labelText: '熊舍名称',
              hintText: '例如：雪团熊舍',
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '首次设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: _depth,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.rule_folder_outlined,
                    color: Color(0xff43635f),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.state.systemRules.isEmpty ? '系统规则加载中' : '金丝熊基础规则',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('稍后建档'),
                icon: Icon(Icons.edit_note),
              ),
              ButtonSegment(
                value: false,
                label: Text('CSV 迁移'),
                icon: Icon(Icons.upload_file),
              ),
            ],
            selected: {importLater},
            onSelectionChanged: disabled
                ? null
                : (value) => setState(() => importLater = value.first),
          ),
          const SizedBox(height: 28),
          _PrimaryButton(
            label: '继续进入熊舍',
            icon: Icons.arrow_forward,
            onPressed: disabled
                ? null
                : () async {
                    await widget.state.completeSetup(
                      nameController.text.trim().isEmpty
                          ? '我的熊舍'
                          : nameController.text.trim(),
                    );
                    if (!context.mounted) return;
                    setState(() {});
                  },
          ),
          if (widget.state.offline) const _OfflineBanner(),
          if (widget.state.lastError != null)
            _ErrorText(widget.state.lastError!),
        ],
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.state,
    required this.i2Controller,
    required this.breedingController,
    required this.litterBoardController,
    required this.taskController,
    required this.pedigreeRepository,
    required this.healthRepository,
    required this.memberRepository,
    required this.crmRepository,
    required this.contractsRepository,
    required this.accountingRepository,
    required this.geneticRepository,
    required this.pushRepository,
    required this.paywallRepository,
    required this.publicSiteRepository,
    required this.miniprogramRepository,
    required this.assistantRepository,
    this.todayWidgetPublisher,
  });

  final AppState state;
  final I2Controller i2Controller;
  final BreedingController breedingController;
  final LitterBoardController litterBoardController;
  final TaskController taskController;
  final PedigreeRepository pedigreeRepository;
  final HealthRepository healthRepository;
  final MemberRepository memberRepository;
  final CrmRepository crmRepository;
  final ContractsRepository contractsRepository;
  final AccountingRepository accountingRepository;
  final GeneticRepository geneticRepository;
  final PushRepository pushRepository;
  final PaywallRepository paywallRepository;
  final PublicSiteRepository publicSiteRepository;
  final MiniprogramRepository miniprogramRepository;
  final AssistantRepository assistantRepository;
  final TodayWidgetPublisher? todayWidgetPublisher;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    widget.i2Controller.restore();
    widget.breedingController.refresh();
    widget.taskController.initializeNotifications().then((_) {
      return widget.taskController.refresh();
    });
  }

  String? get _speciesRuleVersionId =>
      widget.state.ownerRules.isEmpty ? null : widget.state.ownerRules.first.id;

  void _showMissingRule() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('请先在“我的 → 物种规则”复制熊舍规则')));
  }

  Future<void> _openHamsterEditor({I2Hamster? existing}) async {
    final speciesRuleVersionId = _speciesRuleVersionId;
    if (speciesRuleVersionId == null) {
      _showMissingRule();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (pageContext) => HamsterEditorPage(
          controller: widget.i2Controller,
          speciesRuleVersionId: speciesRuleVersionId,
          existing: existing,
          onSaved: () => Navigator.of(pageContext).pop(),
        ),
      ),
    );
    await widget.i2Controller.retry();
    if (existing != null) {
      await widget.i2Controller.loadHamsterDetail(existing.id);
    }
  }

  Future<void> _openBatchHamsterEditor() async {
    final speciesRuleVersionId = _speciesRuleVersionId;
    if (speciesRuleVersionId == null) {
      _showMissingRule();
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (pageContext) => BatchHamsterEditorPage(
          controller: widget.i2Controller,
          speciesRuleVersionId: speciesRuleVersionId,
          onSaved: () => Navigator.of(pageContext).pop(),
        ),
      ),
    );
    await widget.i2Controller.retry();
  }

  Future<void> _openWeightEntry(String hamsterId) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (pageContext) => WeightEntryPage(
          controller: widget.i2Controller,
          hamsterId: hamsterId,
          onSaved: () => Navigator.of(pageContext).pop(),
        ),
      ),
    );
    await widget.i2Controller.loadHamsterDetail(hamsterId);
    await widget.i2Controller.retry();
  }

  Future<void> _openBatchWeight() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (pageContext) => WeightBatchPage(
          controller: widget.i2Controller,
          onSaved: () => Navigator.of(pageContext).pop(),
        ),
      ),
    );
    await widget.i2Controller.retry();
  }

  Future<void> _openHamsterDetail(I2Hamster hamster) async {
    final healthController = HealthController(
      repository: widget.healthRepository,
      taskRepository: widget.taskController.repository,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (detailContext) => HamsterDetailPage(
          controller: widget.i2Controller,
          hamsterId: hamster.id,
          taskController: widget.taskController,
          healthController: healthController,
          onEdit: () {
            final current =
                widget.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            _openHamsterEditor(existing: current);
          },
          onAddWeight: () => _openWeightEntry(hamster.id),
          onOpenPedigree: () {
            final current =
                widget.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            Navigator.of(detailContext).push<void>(
              MaterialPageRoute(
                builder: (_) => PedigreePage(
                  controller: PedigreeController(
                    repository: widget.pedigreeRepository,
                  ),
                  hamsterId: current.id,
                  hamsterLabel: current.displayName,
                  generations: 3,
                ),
              ),
            );
          },
          onOpenHealth: () {
            final current =
                widget.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            Navigator.of(detailContext).push<void>(
              MaterialPageRoute(
                builder: (_) => HealthQuickPage(
                  controller: healthController,
                  hamsterId: current.id,
                  hamsterLabel: current.displayName,
                  canWrite:
                      !widget.state.offline && widget.i2Controller.canWrite,
                ),
              ),
            ).then((_) => healthController.loadForHamster(current.id));
          },
        ),
      ),
    );
    healthController.dispose();
    await widget.i2Controller.retry();
    await widget.taskController.refresh();
  }

  Future<void> _openEnclosureAction(
    I2Enclosure enclosure, {
    required bool cleaning,
  }) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (pageContext) => cleaning
            ? EnclosureCarePage(
                controller: widget.i2Controller,
                enclosureId: enclosure.id,
                enclosureVersion: enclosure.version,
                onSaved: () => Navigator.of(pageContext).pop(),
              )
            : MoveHamsterPage(
                controller: widget.i2Controller,
                enclosureId: enclosure.id,
                enclosureVersion: enclosure.version,
                onSaved: () => Navigator.of(pageContext).pop(),
              ),
      ),
    );
    await widget.i2Controller.loadEnclosureDetail(enclosure.id);
    await widget.i2Controller.loadCleaningHistory(enclosure.id);
    await widget.i2Controller.retry();
  }

  Future<void> _openEnclosureDetail(I2Enclosure enclosure) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => EnclosureDetailPage(
          controller: widget.i2Controller,
          enclosureId: enclosure.id,
          onMove: () {
            final current =
                widget.i2Controller.enclosureDetailState.data?.enclosure ??
                enclosure;
            _openEnclosureAction(current, cleaning: false);
          },
          onCare: () {
            final current =
                widget.i2Controller.enclosureDetailState.data?.enclosure ??
                enclosure;
            _openEnclosureAction(current, cleaning: true);
          },
        ),
      ),
    );
    await widget.i2Controller.retry();
  }

  void _openLitters() {
    final snapshot = widget.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LitterBoardListPage(
          controller: widget.litterBoardController,
          enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
          canWrite: !widget.state.offline && widget.i2Controller.canWrite,
          offline: widget.state.offline || widget.i2Controller.offline,
          lastSyncLabel: widget.i2Controller.lastSyncLabel,
        ),
      ),
    );
  }

  void _openDataCenter() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => DataCenterPage(i2Controller: widget.i2Controller),
      ),
    );
  }

  void _openTasks() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TaskListPage(
          controller: widget.taskController,
          canWrite: !widget.state.offline && widget.i2Controller.canWrite,
          offline: widget.state.offline || widget.i2Controller.offline,
        ),
      ),
    );
  }

  void _openCalendar() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CalendarMonthPage(
          taskController: widget.taskController,
          breedingController: widget.breedingController,
          i2Controller: widget.i2Controller,
        ),
      ),
    );
  }

  void _goTab(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeOverviewPage(
        state: widget.state,
        controller: widget.i2Controller,
        taskController: widget.taskController,
        onOpenHamsters: () => _goTab(1),
        onOpenEnclosures: () => _goTab(2),
        onOpenBreeding: () => _goTab(3),
        onOpenLitters: _openLitters,
        onOpenDataCenter: _openDataCenter,
        onOpenTasks: _openTasks,
        onOpenCalendar: _openCalendar,
        onCreateHamster: () => _openHamsterEditor(),
        onOpenBatchWeight: _openBatchWeight,
      ),
      HamsterListPage(
        controller: widget.i2Controller,
        onOpenDetail: _openHamsterDetail,
        onCreate: () => _openHamsterEditor(),
        onBatchCreate: _openBatchHamsterEditor,
        onOpenLitters: _openLitters,
      ),
      EnclosureGridPage(
        controller: widget.i2Controller,
        onOpenDetail: _openEnclosureDetail,
      ),
      AnimatedBuilder(
        animation: widget.i2Controller,
        builder: (context, _) {
          final snapshot = widget.i2Controller.snapshotState.data;
          return BreedingHubPage(
            controller: widget.breedingController,
            hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
            enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
            ruleVersionId: _speciesRuleVersionId,
            onOpenLitters: _openLitters,
            canWrite: !widget.state.offline && widget.i2Controller.canWrite,
          );
        },
      ),
      _MinePage(
        state: widget.state,
        onOpenDataCenter: _openDataCenter,
        onOpenMembers: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => MemberListPage(
                controller: MemberController(
                  repository: widget.memberRepository,
                  currentRole: 'owner',
                ),
              ),
            ),
          );
        },
        onOpenCrm: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => CrmHubPage(
                controller: CrmController(repository: widget.crmRepository),
              ),
            ),
          );
        },
        onOpenContracts: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => ContractsHubPage(
                controller: ContractsController(
                  repository: widget.contractsRepository,
                ),
              ),
            ),
          );
        },
        onOpenAccounting: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => AccountingHubPage(
                controller: AccountingController(
                  repository: widget.accountingRepository,
                ),
              ),
            ),
          );
        },
        onOpenTodayWidget: widget.todayWidgetPublisher == null
            ? null
            : () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => TodayWidgetPreviewPage(
                      taskController: widget.taskController,
                      publisher: widget.todayWidgetPublisher!,
                    ),
                  ),
                );
              },
        onOpenGenetic: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => GeneticHubPage(
                controller: GeneticController(
                  repository: widget.geneticRepository,
                ),
              ),
            ),
          );
        },
        onOpenPush: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => PushSettingsPage(
                controller: PushController(
                  repository: widget.pushRepository,
                ),
              ),
            ),
          );
        },
        onOpenPaywall: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => PaywallPage(
                controller: PaywallController(
                  repository: widget.paywallRepository,
                ),
              ),
            ),
          );
        },
        onOpenPublicSite: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => PublicSiteEditorPage(
                controller: PublicSiteController(
                  repository: widget.publicSiteRepository,
                ),
              ),
            ),
          );
        },
        onOpenMiniprogram: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => MiniprogramHubPage(
                controller: MiniprogramController(
                  repository: widget.miniprogramRepository,
                ),
              ),
            ),
          );
        },
        onOpenAssistant: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => AssistantPage(
                controller: AssistantController(
                  repository: widget.assistantRepository,
                ),
              ),
            ),
          );
        },
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _goTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: '今日',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: '仓鼠',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: '笼舍',
          ),
          NavigationDestination(
            icon: Icon(Icons.sync_alt),
            selectedIcon: Icon(Icons.sync_alt),
            label: '繁育',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class RulePage extends StatelessWidget {
  const RulePage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('物种规则')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle(title: '当前熊舍规则'),
          if (state.ownerRules.isEmpty)
            const _EmptyState(label: '尚未复制规则模板')
          else
            ...state.ownerRules.map(
              (rule) => _RuleCard(rule: rule, owner: true),
            ),
          const SizedBox(height: 24),
          const _SectionTitle(title: '系统模板'),
          ...state.systemRules.map(
            (rule) => _RuleCard(
              rule: rule,
              owner: false,
              onCopy: state.offline
                  ? null
                  : () async {
                      await state.copyRule(rule);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已复制为熊舍规则')),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _MinePage extends StatelessWidget {
  const _MinePage({
    required this.state,
    this.onOpenDataCenter,
    this.onOpenMembers,
    this.onOpenCrm,
    this.onOpenContracts,
    this.onOpenAccounting,
    this.onOpenTodayWidget,
    this.onOpenGenetic,
    this.onOpenPush,
    this.onOpenPaywall,
    this.onOpenPublicSite,
    this.onOpenMiniprogram,
    this.onOpenAssistant,
  });

  final AppState state;
  final VoidCallback? onOpenDataCenter;
  final VoidCallback? onOpenMembers;
  final VoidCallback? onOpenCrm;
  final VoidCallback? onOpenContracts;
  final VoidCallback? onOpenAccounting;
  final VoidCallback? onOpenTodayWidget;
  final VoidCallback? onOpenGenetic;
  final VoidCallback? onOpenPush;
  final VoidCallback? onOpenPaywall;
  final VoidCallback? onOpenPublicSite;
  final VoidCallback? onOpenMiniprogram;
  final VoidCallback? onOpenAssistant;

  @override
  Widget build(BuildContext context) {
    final organization = state.organization;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Text(
          '我的',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(organization?.name ?? '熊舍', style: const TextStyle(color: _muted)),
        const SizedBox(height: 20),
        Card(
          color: _depth,
          child: ListTile(
            contentPadding: const EdgeInsets.all(18),
            leading: const Icon(Icons.storage_outlined),
            title: const Text(
              '数据中心',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: Color(0xff43635f),
              ),
            ),
            subtitle: const Text(
              'CSV 导入 · 导出 · 备份 · 用量',
              style: TextStyle(color: Color(0xff5f7773)),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: onOpenDataCenter,
          ),
        ),
        if (onOpenMembers != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-members'),
              leading: const Icon(Icons.group_outlined),
              title: const Text('成员与权限'),
              subtitle: const Text('邀请繁育员 / 饲养员 / 客服 / 访客'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenMembers,
            ),
          ),
        ],
        if (onOpenCrm != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-crm'),
              leading: const Icon(Icons.handshake_outlined),
              title: const Text('客户与交付'),
              subtitle: const Text('意向客户 · 预订 · 交付交接'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenCrm,
            ),
          ),
        ],
        if (onOpenContracts != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-contracts'),
              leading: const Icon(Icons.description_outlined),
              title: const Text('合同与回执'),
              subtitle: const Text('模板 · 草稿签发 · 复制分享'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenContracts,
            ),
          ),
        ],
        if (onOpenAccounting != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-accounting'),
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('财务收支'),
              subtitle: const Text('记账 · 分类 · 本月汇总'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenAccounting,
            ),
          ),
        ],
        if (onOpenTodayWidget != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-today-widget'),
              leading: const Icon(Icons.widgets_outlined),
              title: const Text('今日待办组件'),
              subtitle: const Text('桌面小组件 · 预览与同步'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenTodayWidget,
            ),
          ),
        ],
        if (onOpenGenetic != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-genetic'),
              leading: const Icon(Icons.biotech_outlined),
              title: const Text('遗传表型与模拟'),
              subtitle: const Text('位点档案 · 配对概率'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenGenetic,
            ),
          ),
        ],
        if (onOpenPush != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-push'),
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('服务端推送'),
              subtitle: const Text('设备令牌 · 测试推送'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenPush,
            ),
          ),
        ],
        if (onOpenPaywall != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-paywall'),
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('套餐与权益'),
              subtitle: const Text('用量上限 · 沙箱升级'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenPaywall,
            ),
          ),
        ],
        if (onOpenPublicSite != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-public-site'),
              leading: const Icon(Icons.language_outlined),
              title: const Text('公开主页'),
              subtitle: const Text('轻量展示 · 发布链接'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenPublicSite,
            ),
          ),
        ],
        if (onOpenMiniprogram != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-miniprogram'),
              leading: const Icon(Icons.smartphone_outlined),
              title: const Text('小程序轻发布'),
              subtitle: const Text('审核链 · 版本发布'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenMiniprogram,
            ),
          ),
        ],
        if (onOpenAssistant != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              key: const Key('mine-open-assistant'),
              leading: const Icon(Icons.smart_toy_outlined),
              title: const Text('AI 只读助手'),
              subtitle: const Text('结构化查询 · 不改数据'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenAssistant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.rule_outlined),
            title: const Text('物种规则'),
            subtitle: Text(
              state.ownerRules.isEmpty
                  ? '等待首次设置'
                  : '当前 ${state.ownerRules.length} 个版本',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => RulePage(state: state))),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.cloud_done_outlined),
            title: const Text('离线状态'),
            subtitle: Text(
              state.offline ? '离线只读 · 联网后重新提交/再操作' : '在线 · 最近数据已同步',
            ),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => state.logout(),
          icon: const Icon(Icons.logout),
          label: const Text('退出登录'),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule, required this.owner, this.onCopy});

  final SpeciesRuleVersion rule;
  final bool owner;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 10),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rule.speciesCode,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Chip(label: Text(owner ? '熊舍 v${rule.version}' : '系统模板')),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '孕期 ${rule.gestationMinDays}–${rule.gestationMaxDays} 天 · 配对 ${rule.pairingMaxMinutes ?? '-'} 分钟',
            style: const TextStyle(color: _muted),
          ),
          if (!owner)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('复制'),
              ),
            ),
        ],
      ),
    ),
  );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: _depth,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '熊舍运营中枢',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xff43635f),
          ),
        ),
        SizedBox(height: 8),
        Text('记录 · 繁育 · 谱系 · 备份', style: TextStyle(color: Color(0xff5f7773))),
      ],
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    icon: Icon(icon),
    label: Text(label),
    style: FilledButton.styleFrom(
      backgroundColor: _accent,
      minimumSize: const Size.fromHeight(52),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 18,
      color: _ink,
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xffc8cecb)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(color: _muted),
    ),
  );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 16),
    child: Text(
      '离线只读，联网后重新提交/再操作',
      style: TextStyle(color: Color(0xffb6534a), fontWeight: FontWeight.w600),
    ),
  );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Text(text, style: const TextStyle(color: Color(0xffb6534a))),
  );
}
