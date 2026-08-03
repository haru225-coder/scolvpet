part of '../screens.dart';

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
    this.onLogout,
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

  /// Full logout including controller resets; falls back to [AppState.logout]
  /// when the shell does not inject one (widget tests).
  final Future<void> Function()? onLogout;

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
                organization?.name ?? '熊舍',
                subtitle: memberRoleLabel(state.currentMemberRole),
                trailing: const BearMascot(size: 44, mood: BearMood.happy),
              ),
            ),
            const SizedBox(height: 12),
            IosGroupedSection(
              header: const IosSectionHeader('数据'),
              children: [
                IosListTile(
                  leading: const BearGlyphTile(
                    icon: CupertinoIcons.square_stack_3d_up_fill,
                    semanticLabel: '数据中心',
                    size: 32,
                    padding: 4,
                  ),
                  title: '数据中心',
                  subtitle: state.hasCapability(AppCapability.writeImport)
                      ? '导入与用量（导出/备份入口已收起）'
                      : '只读浏览 · 导入操作仅舍主可用',
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
                        semanticLabel: '这两只会生出什么',
                        size: 32,
                        padding: 4,
                      ),
                      title: '这两只会生出什么',
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
                  onTap: () => (onLogout ?? state.logout)(),
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
