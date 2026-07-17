import 'package:flutter/material.dart';

import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
import 'paywall_controller.dart';
import 'paywall_models.dart';

/// Paywall + entitlement overview (T-P1-08). StoreKit/CN payments deferred.
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
            title: const Text('套餐与权益'),
            actions: [
              IconButton(
                key: const Key('paywall-refresh'),
                onPressed: widget.controller.refreshAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              Text(
                'StoreKit / 中国区支付未接入；可用沙箱切换专业版验证用量门禁与权益展示。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _CurrentCard(
                state: widget.controller.snapshotState,
                onRetry: widget.controller.refreshCurrent,
                onActivatePro: () =>
                    _snack(() => widget.controller.activatePro()),
                onActivateFree: () =>
                    _snack(() => widget.controller.activateFree()),
              ),
              const SizedBox(height: 16),
              Text(
                '套餐对比',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _CatalogSection(state: widget.controller.catalogState),
              const SizedBox(height: 16),
              Text(
                '用量与上限',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _LimitsSection(state: widget.controller.snapshotState),
              const SizedBox(height: 16),
              Text(
                '功能权益',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _FeaturesSection(state: widget.controller.snapshotState),
            ],
          ),
        );
      },
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.state,
    required this.onRetry,
    required this.onActivatePro,
    required this.onActivateFree,
  });

  final I2AsyncState<EntitlementSnapshot> state;
  final VoidCallback onRetry;
  final VoidCallback onActivatePro;
  final VoidCallback onActivateFree;

  @override
  Widget build(BuildContext context) {
    return I2AsyncStateView<EntitlementSnapshot>(
      state: state,
      onRetry: onRetry,
      builder: (snap) {
        return Card(
          color: const Color(0xff2b3634),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      snap.planTitle,
                      key: const Key('paywall-plan-title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(snap.isPro ? 'PRO' : 'FREE'),
                      backgroundColor: const Color(0xffc77852),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '来源 ${snap.source} · 门禁 ${snap.enforcement}',
                  style: const TextStyle(color: Color(0xffe7eeec)),
                ),
                if (snap.paywallHint != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    snap.paywallHint!,
                    style: const TextStyle(color: Color(0xffffe0c2)),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!snap.isPro)
                      FilledButton(
                        key: const Key('paywall-activate-pro'),
                        onPressed: onActivatePro,
                        child: const Text('沙箱升级专业版'),
                      )
                    else
                      OutlinedButton(
                        key: const Key('paywall-activate-free'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        onPressed: onActivateFree,
                        child: const Text('回到免费版'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CatalogSection extends StatelessWidget {
  const _CatalogSection({required this.state});

  final I2AsyncState<List<PlanCatalogEntry>> state;

  @override
  Widget build(BuildContext context) {
    final items = state.data ?? defaultPlanCatalog();
    return Column(
      children: [
        for (final plan in items) ...[
          Card(
            child: ListTile(
              key: Key('paywall-catalog-${plan.code}'),
              title: Text(plan.title),
              subtitle: Text('${plan.description}\n${plan.priceHint}'),
              isThreeLine: true,
              trailing: plan.highlight
                  ? const Icon(Icons.star, color: Color(0xffc77852))
                  : null,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _LimitsSection extends StatelessWidget {
  const _LimitsSection({required this.state});

  final I2AsyncState<EntitlementSnapshot> state;

  @override
  Widget build(BuildContext context) {
    final snap = state.data;
    if (snap == null) {
      return const I2StateMessage(
        icon: Icons.data_usage_outlined,
        message: '加载用量上限…',
      );
    }
    return Column(
      children: [
        for (final lim in snap.limits) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(lim.title)),
                      Text(
                        '${lim.usedLabel} / ${lim.limitLabel}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: lim.over ? Colors.redAccent : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: lim.limit == null ? 0 : lim.progress.clamp(0.0, 1.0),
                    color: lim.over
                        ? Colors.redAccent
                        : const Color(0xffc77852),
                    backgroundColor: const Color(0xffe7eeec),
                  ),
                  if (lim.over)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        '已超过建议上限（软门禁，不阻断业务）',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.state});

  final I2AsyncState<EntitlementSnapshot> state;

  @override
  Widget build(BuildContext context) {
    final snap = state.data;
    if (snap == null) return const SizedBox.shrink();
    return Column(
      children: [
        for (final f in snap.features) ...[
          Card(
            child: ListTile(
              key: Key('paywall-feature-${f.code}'),
              leading: Icon(
                f.allowed ? Icons.check_circle : Icons.lock_outline,
                color: f.allowed ? Colors.green : Colors.orange,
              ),
              title: Text(f.title),
              subtitle: Text(f.description),
              trailing: Text(f.allowed ? '可用' : '升级'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
