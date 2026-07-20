part of '../screens.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.services,
  });

  final AppServices services;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  late final GrowthController _growthController;
  late final AssistantController _assistantController;

  void _goTab(int value) {
    if (value == index) return;
    HapticFeedback.selectionClick();
    setState(() => index = value);
  }

  /// P0-1: AI 移出底栏，保留可达入口（push，非一级 Tab）。
  void _openAssistant() {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => AssistantPage(
          controller: _assistantController,
          i2Controller: widget.services.i2Controller,
          taskController: widget.services.taskController,
          onOpenTasks: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _openTasks();
          },
          onCreateTask: _canWrite(AppCapability.writeTask)
              ? () {
                  final snapshot =
                      widget.services.i2Controller.snapshotState.data;
                  Navigator.of(context).push<void>(
                    iosPageRoute(
                      builder: (_) => TaskComposerPage(
                        controller: widget.services.taskController,
                        canWrite: true,
                        organizationId: widget.services.state.organization?.id,
                        hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
                        enclosures:
                            snapshot?.enclosures ?? const <I2Enclosure>[],
                      ),
                    ),
                  );
                }
              : null,
          onOpenHamsters: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _goTab(1);
          },
          onOpenHamsterDetail: (hamster) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _openHamsterDetail(hamster);
          },
          onOpenEnclosures: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _openEnclosures();
          },
          onOpenEnclosureDetail: (enclosure) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _openEnclosureDetail(enclosure);
          },
          onOpenGrowth: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _openGrowth();
          },
          onOpenDataCenter: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _openDataCenter();
          },
          onOpenTaskDraft: _canWrite(AppCapability.writeTask)
              ? (draft) {
                  final snapshot =
                      widget.services.i2Controller.snapshotState.data;
                  Navigator.of(context).push<void>(
                    iosPageRoute(
                      builder: (_) => TaskComposerPage(
                        controller: widget.services.taskController,
                        canWrite: true,
                        organizationId: widget.services.state.organization?.id,
                        hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
                        enclosures:
                            snapshot?.enclosures ?? const <I2Enclosure>[],
                        initialDraft: draft,
                      ),
                    ),
                  );
                }
              : null,
        ),
      ),
    );
  }

  /// P0-1: 「我的」移出底栏，Account 菜单 push 可达；能力不删。
  void _openAccount() {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (pageContext) => Scaffold(
          appBar: AppBar(
            key: const Key('account-app-bar'),
            title: const Text('账号'),
            leading: IconButton(
              key: const Key('account-back'),
              tooltip: '返回',
              icon: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.of(pageContext).pop(),
            ),
          ),
          body: _buildMinePage(),
        ),
      ),
    );
  }

  Widget _buildMinePage() {
    return _MinePage(
      state: widget.services.state,
      onOpenDataCenter: _openDataCenter,
      onOpenMembers: () {
        Navigator.of(context).push<void>(
          iosPageRoute(
            builder: (_) => MemberListPage(
              controller: MemberController(
                repository: widget.services.memberRepository,
                currentRole: widget.services.state.currentMemberRole,
              ),
            ),
          ),
        );
      },
      onOpenCrm: _openCrm,
      onOpenContracts: _openContracts,
      onOpenAccounting: () {
        Navigator.of(context).push<void>(
          iosPageRoute(
            builder: (_) => AccountingHubPage(
              controller: AccountingController(
                repository: widget.services.accountingRepository,
              ),
              canWrite: _canWrite(AppCapability.writeAccounting),
            ),
          ),
        );
      },
      onOpenTodayWidget: widget.services.todayWidgetPublisher == null
          ? null
          : () {
              Navigator.of(context).push<void>(
                iosPageRoute(
                  builder: (_) => TodayWidgetPreviewPage(
                    taskController: widget.services.taskController,
                    publisher: widget.services.todayWidgetPublisher!,
                  ),
                ),
              );
            },
      onOpenGenetic: () => _openGeneticHub(),
      onOpenPaywall: () {
        Navigator.of(context).push<void>(
          iosPageRoute(
            builder: (_) => PaywallPage(
              controller: PaywallController(
                repository: widget.services.paywallRepository,
              ),
            ),
          ),
        );
      },
      onOpenPublicSite: () {
        Navigator.of(context).push<void>(
          iosPageRoute(
            builder: (_) => PublicSiteEditorPage(
              controller: PublicSiteController(
                repository: widget.services.publicSiteRepository,
              ),
            ),
          ),
        );
      },
      onOpenAssistant: _openAssistant,
      onOpenStud: () {
        Navigator.of(context).push<void>(
          iosPageRoute(
            builder: (_) => StudHubPage(
              controller: StudController(repository: widget.services.studRepository),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _growthController = GrowthController(repository: widget.services.growthRepository);
    _assistantController = AssistantController(
      repository: widget.services.assistantRepository,
    );
    widget.services.i2Controller.setWritePermission(
      widget.services.state.hasCapability(AppCapability.writeHamster),
    );
    widget.services.i2Controller.restore();
    widget.services.breedingController.refresh();
    widget.services.taskController.initializeNotifications().then((_) {
      return widget.services.taskController.refresh();
    });
  }

  @override
  void dispose() {
    _growthController.dispose();
    _assistantController.dispose();
    super.dispose();
  }

  String? get _speciesRuleVersionId =>
      widget.services.state.ownerRules.isEmpty ? null : widget.services.state.ownerRules.first.id;

  bool _canWrite(String capability) =>
      !widget.services.state.offline && widget.services.state.hasCapability(capability);

  void _showWriteRestricted(String action) {
    final message = widget.services.state.offline || widget.services.i2Controller.offline
        ? '当前离线，只能查看已同步记录'
        : '${memberRoleLabel(widget.services.state.currentMemberRole)}可查看记录，但没有$action权限';
    showIosMessage(context, message);
  }

  bool _requireWrite(String capability, String action) {
    if (_canWrite(capability)) return true;
    _showWriteRestricted(action);
    return false;
  }

  void _showMissingRule() {
    showIosMessage(context, '请先在“我的 → 物种规则”复制熊舍规则');
  }

  Future<void> _openHamsterEditor({I2Hamster? existing}) async {
    if (!_requireWrite(AppCapability.writeHamster, '编辑仓鼠档案')) return;
    final speciesRuleVersionId = _speciesRuleVersionId;
    if (speciesRuleVersionId == null) {
      _showMissingRule();
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => HamsterEditorPage(
          controller: widget.services.i2Controller,
          speciesRuleVersionId: speciesRuleVersionId,
          existing: existing,
          onSaved: () => Navigator.of(pageContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '仓鼠档案已保存');
    await widget.services.i2Controller.retry();
    if (existing != null) {
      await widget.services.i2Controller.loadHamsterDetail(existing.id);
    }
  }

  Future<void> _openBatchHamsterEditor() async {
    if (!_requireWrite(AppCapability.writeHamster, '批量建档')) return;
    final speciesRuleVersionId = _speciesRuleVersionId;
    if (speciesRuleVersionId == null) {
      _showMissingRule();
      return;
    }
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => BatchHamsterEditorPage(
          controller: widget.services.i2Controller,
          speciesRuleVersionId: speciesRuleVersionId,
          onSaved: () => Navigator.of(pageContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '仓鼠档案已保存');
    await widget.services.i2Controller.retry();
  }

  Future<void> _openWeightEntry(String hamsterId) async {
    if (!_requireWrite(AppCapability.writeWeight, '记录体重')) return;
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => WeightEntryPage(
          controller: widget.services.i2Controller,
          hamsterId: hamsterId,
          onSaved: () => Navigator.of(pageContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '体重已保存');
    await widget.services.i2Controller.loadHamsterDetail(hamsterId);
    await widget.services.i2Controller.retry();
  }

  Future<void> _openBatchWeight() async {
    if (!_requireWrite(AppCapability.writeWeight, '批量称重')) return;
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => WeightBatchPage(
          controller: widget.services.i2Controller,
          onSaved: () => Navigator.of(pageContext).pop(true),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '体重已保存');
    await widget.services.i2Controller.retry();
  }

  void _openGeneticHub({GeneticHubPrefill? prefill}) {
    final hamsters =
        widget.services.i2Controller.snapshotState.data?.hamsters ?? const <I2Hamster>[];
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => GeneticHubPage(
          controller: GeneticController(repository: widget.services.geneticRepository),
          hamsters: hamsters,
          breedingController: widget.services.breedingController,
          ruleVersionId: _speciesRuleVersionId,
          prefill: prefill,
        ),
      ),
    );
  }

  Future<void> _openHamsterDetail(I2Hamster hamster) async {
    final canEditHamster = _canWrite(AppCapability.writeHamster);
    final canWriteWeight = _canWrite(AppCapability.writeWeight);
    final healthController = HealthController(
      repository: widget.services.healthRepository,
      taskRepository: widget.services.taskController.repository,
    );
    await Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (detailContext) => HamsterDetailPage(
          controller: widget.services.i2Controller,
          hamsterId: hamster.id,
          taskController: widget.services.taskController,
          healthController: healthController,
          onEdit: canEditHamster
              ? () {
                  final current =
                      widget.services.i2Controller.hamsterDetailState.data?.hamster ??
                      hamster;
                  _openHamsterEditor(existing: current);
                }
              : null,
          onAddWeight: canWriteWeight
              ? () => _openWeightEntry(hamster.id)
              : null,
          onOpenGenetic: () async {
            final current =
                widget.services.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            final all =
                widget.services.i2Controller.snapshotState.data?.hamsters ??
                const <I2Hamster>[];
            final mate = await showMatePickerSheet(
              context: detailContext,
              self: current,
              allHamsters: all,
            );
            if (mate == null) return;
            if (!context.mounted) return;
            _openGeneticHub(prefill: prefillForPair(current, mate));
          },
          onOpenPedigree: () {
            final current =
                widget.services.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            Navigator.of(detailContext).push<void>(
              iosPageRoute(
                builder: (_) => PedigreePage(
                  controller: PedigreeController(
                    repository: widget.services.pedigreeRepository,
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
                widget.services.i2Controller.hamsterDetailState.data?.hamster ?? hamster;
            Navigator.of(detailContext)
                .push<void>(
                  iosPageRoute(
                    builder: (_) => HealthQuickPage(
                      controller: healthController,
                      hamsterId: current.id,
                      hamsterLabel: current.displayName,
                      canWrite: _canWrite(AppCapability.writeHealth),
                    ),
                  ),
                )
                .then((_) => healthController.loadForHamster(current.id));
          },
        ),
      ),
    );
    healthController.dispose();
    await widget.services.i2Controller.retry();
    await widget.services.taskController.refresh();
  }

  Future<void> _openEnclosureAction(
    I2Enclosure enclosure, {
    required bool cleaning,
  }) async {
    if (!_requireWrite(AppCapability.writeEnclosure, '管理笼舍')) return;
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (pageContext) => cleaning
            ? EnclosureCarePage(
                controller: widget.services.i2Controller,
                enclosureId: enclosure.id,
                enclosureVersion: enclosure.version,
                onSaved: () => Navigator.of(pageContext).pop(true),
              )
            : MoveHamsterPage(
                controller: widget.services.i2Controller,
                enclosureId: enclosure.id,
                enclosureVersion: enclosure.version,
                onSaved: () => Navigator.of(pageContext).pop(true),
              ),
      ),
    );
    if (saved == true && mounted) {
      showIosMessage(context, cleaning ? '清洁记录已保存' : '移笼 / 入住已提交');
    }
    await widget.services.i2Controller.loadEnclosureDetail(enclosure.id);
    await widget.services.i2Controller.loadCleaningHistory(enclosure.id);
    await widget.services.i2Controller.retry();
  }

  Future<void> _openEnclosureDetail(I2Enclosure enclosure) async {
    await Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => EnclosureDetailPage(
          controller: widget.services.i2Controller,
          enclosureId: enclosure.id,
          canWrite: _canWrite(AppCapability.writeEnclosure),
          onMove: () {
            final current =
                widget.services.i2Controller.enclosureDetailState.data?.enclosure ??
                enclosure;
            _openEnclosureAction(current, cleaning: false);
          },
          onCare: () {
            final current =
                widget.services.i2Controller.enclosureDetailState.data?.enclosure ??
                enclosure;
            _openEnclosureAction(current, cleaning: true);
          },
        ),
      ),
    );
    await widget.services.i2Controller.retry();
  }

  void _openLitters() {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => LitterBoardListPage(
          controller: widget.services.litterBoardController,
          enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
          canWrite: _canWrite(AppCapability.writeLitter),
          offline: widget.services.state.offline || widget.services.i2Controller.offline,
          lastSyncLabel: widget.services.i2Controller.lastSyncLabel,
        ),
      ),
    );
  }

  void _openDataCenter() {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => DataCenterPage(
          i2Controller: widget.services.i2Controller,
          repository: widget.services.dataCenterRepository,
          canWrite: _canWrite(AppCapability.writeImport),
          onOpenMediaLibrary: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _goTab(1);
          },
          onOpenPublicShares: () {
            Navigator.of(context).push<void>(
              iosPageRoute(
                builder: (_) => PublicSiteEditorPage(
                  controller: PublicSiteController(
                    repository: widget.services.publicSiteRepository,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openTasks() {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => TaskListPage(
          controller: widget.services.taskController,
          canWrite: _canWrite(AppCapability.writeTask),
          offline: widget.services.state.offline || widget.services.i2Controller.offline,
          organizationId: widget.services.state.organization?.id,
          hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
          enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
        ),
      ),
    );
  }

  void _openGrowth() {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => GrowthHubPage(
          controller: _growthController,
          hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
          onOpenCrm: _openCrm,
          canWrite: _canWrite(AppCapability.writeGrowth),
        ),
      ),
    );
  }

  void _openCalendar() {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => CalendarMonthPage(
          taskController: widget.services.taskController,
          breedingController: widget.services.breedingController,
          i2Controller: widget.services.i2Controller,
        ),
      ),
    );
  }

  void _openEnclosures() {
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => EnclosureGridPage(
          controller: widget.services.i2Controller,
          onOpenDetail: _openEnclosureDetail,
          canWrite: _canWrite(AppCapability.writeEnclosure),
          onCreate: _openEnclosureEditor,
        ),
      ),
    );
  }

  Future<void> _openEnclosureEditor() async {
    if (!_requireWrite(AppCapability.writeEnclosure, '新增笼舍')) return;
    final saved = await Navigator.of(context).push<bool>(
      iosPageRoute(
        builder: (_) => EnclosureEditorPage(
          controller: widget.services.i2Controller,
          canWrite: _canWrite(AppCapability.writeEnclosure),
        ),
      ),
    );
    if (saved == true && mounted) showIosMessage(context, '笼盒已添加');
  }

  void _openCrm() {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => CrmHubPage(
          controller: CrmController(repository: widget.services.crmRepository),
          hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
          canWrite: _canWrite(AppCapability.writeCrm),
          onOpenDocuments: (handover, contact, hamster) {
            _openContracts(
              launchContext: ContractsLaunchContext(
                contactId: handover.contactId,
                contactName: contact?.name ?? handover.contactName,
                handoverId: handover.id,
                hamsterId: handover.hamsterId,
                hamsterName: hamster?.displayName ?? handover.hamsterName,
              ),
            );
          },
        ),
      ),
    );
  }

  void _openContracts({ContractsLaunchContext? launchContext}) {
    final snapshot = widget.services.i2Controller.snapshotState.data;
    Navigator.of(context).push<void>(
      iosPageRoute(
        builder: (_) => ContractsHubPage(
          controller: ContractsController(
            repository: widget.services.contractsRepository,
          ),
          crmController: CrmController(repository: widget.services.crmRepository),
          hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
          launchContext: launchContext,
          canWrite: _canWrite(AppCapability.writeDocuments),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // P0-1 Shell: 5 → 3 底栏。管家 / 我的 改为 push 可达，不删能力。
    final pages = [
      HomeOverviewPage(
        state: widget.services.state,
        controller: widget.services.i2Controller,
        taskController: widget.services.taskController,
        onOpenHamsters: () => _goTab(1),
        onOpenEnclosures: _openEnclosures,
        onOpenBreeding: () => _goTab(2),
        onOpenLitters: _openLitters,
        onOpenDataCenter: _openDataCenter,
        onOpenTasks: _openTasks,
        onOpenCalendar: _openCalendar,
        onCreateHamster: () => _openHamsterEditor(),
        onOpenBatchWeight: _openBatchWeight,
        onOpenAccount: _openAccount,
        onOpenAssistant: _openAssistant,
      ),
      HamsterListPage(
        controller: widget.services.i2Controller,
        onOpenDetail: _openHamsterDetail,
        onCreate: _canWrite(AppCapability.writeHamster)
            ? () => _openHamsterEditor()
            : null,
        onBatchCreate: _canWrite(AppCapability.writeHamster)
            ? _openBatchHamsterEditor
            : null,
        onOpenLitters: _openLitters,
      ),
      AnimatedBuilder(
        animation: widget.services.i2Controller,
        builder: (context, _) {
          final snapshot = widget.services.i2Controller.snapshotState.data;
          return BreedingHubPage(
            controller: widget.services.breedingController,
            hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
            enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
            ruleVersionId: _speciesRuleVersionId,
            onOpenLitters: _openLitters,
            canWrite: _canWrite(AppCapability.writeBreeding),
            geneticRepository: widget.services.geneticRepository,
            onOpenGenetic: _openGeneticHub,
          );
        },
      ),
    ];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: index, children: pages),
      ),
      bottomNavigationBar: IosTabBarChrome(
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: _goTab,
          animationDuration: IosMetrics.spring,
          // 视觉草稿 3 主导航：家 / 仓鼠爪印 / 心形（窝巢语义，线性 icon）
          destinations: const [
            NavigationDestination(
              icon: Icon(CupertinoIcons.house),
              selectedIcon: Icon(CupertinoIcons.house_fill),
              label: '工作台',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.paw),
              selectedIcon: Icon(CupertinoIcons.paw_solid),
              label: '仓鼠',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.heart),
              selectedIcon: Icon(CupertinoIcons.heart_fill),
              label: '繁育',
            ),
          ],
        ),
      ),
    );
  }
}
