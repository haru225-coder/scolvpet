part of '../screens.dart';

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
          if (!state.hasCapability(AppCapability.manageMembers)) ...[
            const IosBanner(
              icon: CupertinoIcons.lock_shield,
              color: IosColors.systemOrange,
              text: '当前角色可查看物种规则，复制和维护规则仅由舍主完成。',
            ),
            const SizedBox(height: 16),
          ],
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
              onCopy:
                  state.offline ||
                      !state.hasCapability(AppCapability.manageMembers)
                  ? null
                  : () async {
                      await state.copyRule(rule);
                      if (context.mounted) {
                        showIosMessage(context, '已复制为熊舍规则');
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule, required this.owner, this.onCopy});

  final SpeciesRuleVersion rule;
  final bool owner;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final speciesLabel = switch (rule.speciesCode.toLowerCase()) {
      'mesocricetus_auratus' || 'syrian_hamster' => '金丝熊',
      _ => '仓鼠繁育规则',
    };
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: palette.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(color: palette.separator),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    speciesLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IosStatusBadge(
                  label: owner ? '熊舍版本 ${rule.version}' : '系统模板',
                  color: owner ? palette.accent : IosColors.systemTeal,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '孕期 ${rule.gestationMinDays} 至 ${rule.gestationMaxDays} 天 · 配对 ${rule.pairingMaxMinutes ?? '-'} 分钟',
              style: TextStyle(color: palette.secondaryLabel),
            ),
            if (!owner)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(CupertinoIcons.doc_on_doc, size: 16),
                  label: const Text('复制'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => BearEmptyCard(
    title: label,
    subtitle: '可以从系统模板复制一份开始',
    mood: BearMood.sleepy,
    illustration: BearAssets.emptyList,
  );
}
