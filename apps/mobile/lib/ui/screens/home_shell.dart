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
    final pages = [
      HomeOverviewPage(
        state: widget.services.state,
        controller: widget.services.i2Controller,
        taskController: widget.services.taskController,
        onOpenHamsters: () => _goTab(1),
        onOpenEnclosures: _openEnclosures,
        onOpenBreeding: () => _goTab(3),
        onOpenLitters: _openLitters,
        onOpenDataCenter: _openDataCenter,
        onOpenTasks: _openTasks,
        onOpenCalendar: _openCalendar,
        onCreateHamster: () => _openHamsterEditor(),
        onOpenBatchWeight: _openBatchWeight,
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
      AssistantPage(
        controller: _assistantController,
        i2Controller: widget.services.i2Controller,
        taskController: widget.services.taskController,
        onOpenTasks: _openTasks,
        onCreateTask: _canWrite(AppCapability.writeTask)
            ? () {
                final snapshot = widget.services.i2Controller.snapshotState.data;
                Navigator.of(context).push<void>(
                  iosPageRoute(
                    builder: (_) => TaskComposerPage(
                      controller: widget.services.taskController,
                      canWrite: true,
                      organizationId: widget.services.state.organization?.id,
                      hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
                      enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
                    ),
                  ),
                );
              }
            : null,
        onOpenHamsters: () => _goTab(1),
        onOpenHamsterDetail: _openHamsterDetail,
        onOpenEnclosures: _openEnclosures,
        onOpenEnclosureDetail: _openEnclosureDetail,
        onOpenGrowth: _openGrowth,
        onOpenDataCenter: _openDataCenter,
        onOpenTaskDraft: _canWrite(AppCapability.writeTask)
            ? (draft) {
                final snapshot = widget.services.i2Controller.snapshotState.data;
                Navigator.of(context).push<void>(
                  iosPageRoute(
                    builder: (_) => TaskComposerPage(
                      controller: widget.services.taskController,
                      canWrite: true,
                      organizationId: widget.services.state.organization?.id,
                      hamsters: snapshot?.hamsters ?? const <I2Hamster>[],
                      enclosures: snapshot?.enclosures ?? const <I2Enclosure>[],
                      initialDraft: draft,
                    ),
                  ),
                );
              }
            : null,
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
      _MinePage(
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
        onOpenAssistant: () => _goTab(2),
        onOpenStud: () {
          Navigator.of(context).push<void>(
            iosPageRoute(
              builder: (_) => StudHubPage(
                controller: StudController(repository: widget.services.studRepository),
              ),
            ),
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
          destinations: const [
            NavigationDestination(
              icon: BearNavIcon(asset: BearAssets.icToday),
              selectedIcon: BearNavIcon(
                asset: BearAssets.icToday,
                selected: true,
              ),
              label: '今日',
            ),
            NavigationDestination(
              icon: BearNavIcon(asset: BearAssets.icHamster),
              selectedIcon: BearNavIcon(
                asset: BearAssets.icHamster,
                selected: true,
              ),
              label: '仓鼠',
            ),
            NavigationDestination(
              icon: Icon(CupertinoIcons.sparkles),
              selectedIcon: Icon(CupertinoIcons.sparkles),
              label: '管家',
            ),
            NavigationDestination(
              icon: BearNavIcon(asset: BearAssets.icBreeding),
              selectedIcon: BearNavIcon(
                asset: BearAssets.icBreeding,
                selected: true,
              ),
              label: '繁育',
            ),
            NavigationDestination(
              icon: BearNavIcon(asset: BearAssets.icMine),
              selectedIcon: BearNavIcon(
                asset: BearAssets.icMine,
                selected: true,
              ),
              label: '我的',
            ),
          ],
        ),
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
    this.onOpenPaywall,
    this.onOpenPublicSite,
    this.onOpenAssistant,
    this.onOpenStud,
  });

  final AppState state;
  final VoidCallback? onOpenDataCenter;
  final VoidCallback? onOpenMembers;
  final VoidCallback? onOpenCrm;
  final VoidCallback? onOpenContracts;
  final VoidCallback? onOpenAccounting;
  final VoidCallback? onOpenTodayWidget;
  final VoidCallback? onOpenGenetic;
  final VoidCallback? onOpenPaywall;
  final VoidCallback? onOpenPublicSite;
  final VoidCallback? onOpenAssistant;
  final VoidCallback? onOpenStud;

  @override
  Widget build(BuildContext context) {
    final organization = state.organization;
    return BearSoftBackdrop(
      child: BearPageEntrance(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            0,
            12,
            0,
            IosMetrics.bottomSafePadding,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: IosMetrics.pagePadding,
              ),
              child: IosLargeTitle(
                '我的',
                subtitle:
                    '${organization?.name ?? '熊舍'} · ${memberRoleLabel(state.currentMemberRole)}',
                trailing: const BearMascot(size: 44, mood: BearMood.happy),
              ),
            ),
            const SizedBox(height: 12),
            IosGroupedSection(
              header: const IosSectionHeader('数据'),
              children: [
                IosListTile(
                  leading: const BearIconTile(
                    asset: BearAssets.icData,
                    size: 32,
                    padding: 4,
                  ),
                  title: '数据中心',
                  subtitle: state.hasCapability(AppCapability.writeImport)
                      ? '整理、导入和备份你的资料'
                      : '只读浏览 · 导入与备份操作仅舍主可用',
                  onTap: onOpenDataCenter,
                ),
              ],
            ),
            if (onOpenMembers != null ||
                onOpenCrm != null ||
                onOpenContracts != null ||
                onOpenAccounting != null) ...[
              const SizedBox(height: 20),
              IosGroupedSection(
                header: const IosSectionHeader('经营'),
                children: [
                  if (onOpenMembers != null)
                    IosListTile(
                      key: const Key('mine-open-members'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.person_2_fill,
                        semanticLabel: '成员与权限',
                        size: 32,
                        padding: 4,
                      ),
                      title: '成员与权限',
                      subtitle: state.hasCapability(AppCapability.manageMembers)
                          ? '邀请繁育员 / 饲养员 / 客服 / 访客'
                          : '只读浏览 · 成员邀请与角色调整仅舍主可用',
                      onTap: onOpenMembers,
                    ),
                  if (onOpenCrm != null)
                    IosListTile(
                      key: const Key('mine-open-crm'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.person_2_square_stack_fill,
                        semanticLabel: '客户与交付',
                        size: 32,
                        padding: 4,
                      ),
                      title: '客户与交付',
                      subtitle: state.hasCapability(AppCapability.writeCrm)
                          ? '意向客户 · 预订 · 交付交接'
                          : '只读浏览 · 当前角色没有客户写入权限',
                      onTap: onOpenCrm,
                    ),
                  if (onOpenContracts != null)
                    IosListTile(
                      key: const Key('mine-open-contracts'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.doc_text_fill,
                        semanticLabel: '合同与回执',
                        size: 32,
                        padding: 4,
                      ),
                      title: '合同与回执',
                      subtitle:
                          state.hasCapability(AppCapability.writeDocuments)
                          ? '模板 · 草稿签发 · 复制分享'
                          : '只读浏览 · 可预览和输出已生成单据',
                      onTap: onOpenContracts,
                    ),
                  if (onOpenAccounting != null)
                    IosListTile(
                      key: const Key('mine-open-accounting'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.money_yen_circle_fill,
                        semanticLabel: '财务收支',
                        size: 32,
                        padding: 4,
                      ),
                      title: '财务收支',
                      subtitle:
                          state.hasCapability(AppCapability.writeAccounting)
                          ? '记账 · 分类 · 本月汇总'
                          : '只读浏览 · 记账与分类维护仅舍主可用',
                      onTap: onOpenAccounting,
                    ),
                ],
              ),
            ],
            if (onOpenTodayWidget != null ||
                onOpenGenetic != null ||
                onOpenPaywall != null) ...[
              const SizedBox(height: 20),
              IosGroupedSection(
                header: const IosSectionHeader('工具'),
                children: [
                  if (onOpenTodayWidget != null)
                    IosListTile(
                      key: const Key('mine-open-today-widget'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.square_grid_2x2,
                        semanticLabel: '今日待办组件',
                        size: 32,
                        padding: 4,
                      ),
                      title: '今日待办组件',
                      subtitle: '桌面小组件 · 预览与同步',
                      onTap: onOpenTodayWidget,
                    ),
                  if (onOpenGenetic != null)
                    IosListTile(
                      key: const Key('mine-open-genetic'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.lab_flask_solid,
                        semanticLabel: '遗传推算',
                        size: 32,
                        padding: 4,
                      ),
                      title: '遗传推算',
                      subtitle: '配对概率与本窝记录',
                      onTap: onOpenGenetic,
                    ),
                  if (onOpenPaywall != null)
                    IosListTile(
                      key: const Key('mine-open-paywall'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.checkmark_seal,
                        semanticLabel: '套餐与权益',
                        size: 32,
                        padding: 4,
                      ),
                      title: '套餐与权益',
                      subtitle: '查看方案、用量和功能范围',
                      onTap: onOpenPaywall,
                    ),
                ],
              ),
            ],
            if (onOpenPublicSite != null ||
                onOpenAssistant != null ||
                onOpenStud != null) ...[
              const SizedBox(height: 20),
              IosGroupedSection(
                header: const IosSectionHeader('增长'),
                children: [
                  if (onOpenPublicSite != null)
                    IosListTile(
                      key: const Key('mine-open-public-site'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.globe,
                        semanticLabel: '公开主页',
                        size: 32,
                        padding: 4,
                      ),
                      title: '公开主页',
                      subtitle: '轻量展示 · 发布链接',
                      onTap: onOpenPublicSite,
                    ),
                  if (onOpenAssistant != null)
                    IosListTile(
                      key: const Key('mine-open-assistant'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.sparkles,
                        semanticLabel: '问问管家',
                        size: 32,
                        padding: 4,
                      ),
                      title: '问问管家',
                      subtitle: '用一句话找到你的记录',
                      onTap: onOpenAssistant,
                    ),
                  if (onOpenStud != null)
                    IosListTile(
                      key: const Key('mine-open-stud'),
                      leading: const BearGlyphTile(
                        icon: CupertinoIcons.arrow_right_arrow_left,
                        semanticLabel: '配对合作',
                        size: 32,
                        padding: 4,
                      ),
                      title: '配对合作',
                      subtitle: '管理借配与合作记录',
                      onTap: onOpenStud,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            IosGroupedSection(
              header: const IosSectionHeader('系统'),
              children: [
                IosListTile(
                  leading: const BearGlyphTile(
                    icon: CupertinoIcons.settings,
                    semanticLabel: '物种规则',
                    size: 32,
                    padding: 4,
                  ),
                  title: '物种规则',
                  subtitle: state.ownerRules.isEmpty
                      ? '等待首次设置'
                      : '当前 ${state.ownerRules.length} 个版本',
                  onTap: () => Navigator.of(
                    context,
                  ).push(iosPageRoute(builder: (_) => RulePage(state: state))),
                ),
                IosListTile(
                  leading: BearGlyphTile(
                    icon: state.offline
                        ? CupertinoIcons.exclamationmark_triangle
                        : CupertinoIcons.cloud,
                    semanticLabel: state.offline ? '离线' : '在线',
                    size: 32,
                    padding: 4,
                    selected: state.offline,
                  ),
                  title: '离线状态',
                  subtitle: state.offline
                      ? '离线只读 · 联网后重新提交/再操作'
                      : '在线 · 最近数据已同步',
                  showChevron: false,
                ),
              ],
            ),
            const SizedBox(height: 20),
            IosGroupedSection(
              children: [
                IosListTile(
                  leading: const BearGlyphTile(
                    icon: CupertinoIcons.square_arrow_left,
                    semanticLabel: '退出登录',
                    size: 32,
                    padding: 4,
                    selected: true,
                  ),
                  title: '退出登录',
                  destructive: true,
                  showChevron: false,
                  onTap: () => state.logout(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: IosMetrics.pagePadding),
              child: _MineFooter(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MineFooter extends StatelessWidget {
  const _MineFooter();

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Column(
      children: [
        const BearMascot(size: 48, mood: BearMood.sleepy),
        const SizedBox(height: 8),
        Text(
          '熊舍管家 · 可爱认真地管好每一只小仓鼠',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: palette.secondaryLabel),
        ),
      ],
    );
  }
}
