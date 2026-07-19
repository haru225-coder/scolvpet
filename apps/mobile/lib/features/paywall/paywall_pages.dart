import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'paywall_controller.dart';
import 'paywall_models.dart';

/// 套餐与权益只读概览。正式支付接入前不提供套餐切换操作。
class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key, required this.controller});

  final PaywallController controller;

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final busy =
            widget.controller.catalogState.status == I2AsyncStatus.loading ||
            widget.controller.snapshotState.status == I2AsyncStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: const Text('套餐与权益'),
            actions: [
              IconButton(
                key: const Key('paywall-refresh'),
                tooltip: '刷新权益',
                onPressed: busy ? null : widget.controller.refreshAll,
                icon: const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
            children: [
              const IosModuleIntro(
                icon: CupertinoIcons.star_circle,
                title: '当前方案与可用范围',
                description: '查看当前套餐、用量上限和已经开放的功能权益。',
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: IosBanner(
                  key: Key('paywall-read-only'),
                  icon: CupertinoIcons.lock_shield,
                  color: IosColors.systemOrange,
                  text: '当前页面仅供查看，不会变更套餐或产生扣款。套餐开通方式准备完成后会在这里提供。',
                ),
              ),
              _SnapshotOverview(
                state: widget.controller.snapshotState,
                onRetry: widget.controller.refreshCurrent,
              ),
              const IosSectionHeader('套餐对比'),
              _CatalogSection(
                state: widget.controller.catalogState,
                onRetry: widget.controller.refreshCatalog,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SnapshotOverview extends StatelessWidget {
  const _SnapshotOverview({required this.state, required this.onRetry});

  final I2AsyncState<EntitlementSnapshot> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<EntitlementSnapshot>(
      state: state,
      onRetry: onRetry,
      builder: (snapshot) {
        final features = snapshot.features
            .where(_isPublicEntitlementFeature)
            .toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const IosSectionHeader('当前套餐'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CurrentPlanCard(snapshot: snapshot),
            ),
            const IosSectionHeader('用量与上限'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _LimitsSection(snapshot: snapshot),
            ),
            const IosSectionHeader('功能权益'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FeaturesSection(features: features),
            ),
          ],
        );
      },
    );
  }
}

class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.snapshot});

  final EntitlementSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    return Container(
      key: const Key('paywall-plan-title'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(IosMetrics.largeRadius),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.22),
          width: IosMetrics.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IosGlyph(
                icon: snapshot.isPro
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.heart_fill,
                color: palette.accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  snapshot.planTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IosStatusBadge(
                label: '当前使用',
                color: palette.accent,
                icon: CupertinoIcons.checkmark_circle_fill,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            snapshot.overLimit
                ? '部分用量超过当前方案建议上限，现有记录仍可继续查看与整理。'
                : snapshot.isPro
                ? '已包含更高用量上限与专业功能。'
                : '核心建档、繁育与日常管理功能已经开放。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryLabel,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogSection extends StatelessWidget {
  const _CatalogSection({required this.state, required this.onRetry});

  final I2AsyncState<List<PlanCatalogEntry>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: I2AsyncStateView<List<PlanCatalogEntry>>(
        state: state,
        onRetry: onRetry,
        builder: (items) => IosGroupedSection(
          margin: EdgeInsets.zero,
          children: [
            for (final plan in items)
              IosListTile(
                key: Key('paywall-catalog-${plan.code}'),
                leading: IosGlyph(
                  icon: plan.highlight
                      ? CupertinoIcons.star_fill
                      : CupertinoIcons.heart_fill,
                  color: plan.highlight
                      ? ScolvPalette.of(context).accent
                      : IosColors.systemGreen,
                ),
                title: plan.title,
                subtitle: plan.description,
                trailing: plan.highlight
                    ? Text(
                        '更多权益',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ScolvPalette.of(context).accent,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
                showChevron: false,
              ),
          ],
        ),
      ),
    );
  }
}

class _LimitsSection extends StatelessWidget {
  const _LimitsSection({required this.snapshot});

  final EntitlementSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    if (snapshot.limits.isEmpty) {
      return const IosBanner(
        icon: CupertinoIcons.chart_bar,
        color: IosColors.systemOrange,
        text: '当前套餐暂未返回用量上限，请稍后刷新。',
      );
    }
    return Column(
      children: [
        for (var index = 0; index < snapshot.limits.length; index++) ...[
          _LimitCard(limit: snapshot.limits[index]),
          if (index != snapshot.limits.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({required this.limit});

  final EntitlementLimit limit;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final color = limit.over ? IosColors.systemRed : palette.accent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(IosMetrics.continuousRadius),
        border: Border.all(color: palette.separator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  limit.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                '${limit.usedLabel} / ${limit.limitLabel}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(IosMetrics.pillRadius),
            child: LinearProgressIndicator(
              value: limit.limit == null ? 0 : limit.progress.clamp(0.0, 1.0),
              minHeight: 6,
              color: color,
              backgroundColor: palette.tertiaryFill,
            ),
          ),
          if (limit.over) ...[
            const SizedBox(height: 6),
            const Text(
              '已超过建议上限，现有记录仍可继续查看与整理。',
              style: TextStyle(color: IosColors.systemRed, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.features});

  final List<EntitlementFeature> features;

  @override
  Widget build(BuildContext context) {
    if (features.isEmpty) {
      return const IosBanner(
        icon: CupertinoIcons.checkmark_seal,
        color: IosColors.systemOrange,
        text: '当前套餐暂未返回功能清单，请稍后刷新。',
      );
    }
    return IosGroupedSection(
      margin: EdgeInsets.zero,
      children: [
        for (final feature in features)
          IosListTile(
            key: Key('paywall-feature-${feature.code}'),
            leading: IosGlyph(
              icon: feature.allowed
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.lock_fill,
              color: feature.allowed
                  ? IosColors.systemGreen
                  : IosColors.systemOrange,
            ),
            title: feature.title,
            subtitle: feature.description,
            trailing: Text(
              feature.allowed ? '已开放' : '专业版',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: feature.allowed
                    ? IosColors.systemGreen
                    : IosColors.systemOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            showChevron: false,
          ),
      ],
    );
  }
}

bool _isPublicEntitlementFeature(EntitlementFeature feature) =>
    feature.code != 'feature.server_push' &&
    feature.code != 'feature.miniprogram_publish';
