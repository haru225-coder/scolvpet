import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/api_client.dart';
import '../../core/api_error.dart';
import 'paywall_models.dart';

abstract interface class PaywallRepository {
  Future<List<PlanCatalogEntry>> listCatalog();
  Future<EntitlementSnapshot> current();
  Future<EntitlementCheckResult> check({String? feature, String? metric});
  Future<EntitlementSnapshot> sandboxActivate(String planCode);
}

class PaywallRepositoryException implements Exception {
  const PaywallRepositoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

String paywallErrorMessage(Object error) => apiErrorMessage(
  error,
  fallback: '权益请求失败',
  mapLocal: (e) => e is PaywallRepositoryException ? e.message : null,
);

class MemoryPaywallRepository implements PaywallRepository {
  String _planCode = 'free';
  String _source = 'system';
  final Map<String, double> _usage;

  MemoryPaywallRepository({Map<String, double>? usage})
    : _usage =
          usage ??
          {
            'active_hamsters': 12,
            'active_litters': 3,
            'enclosures': 8,
            'media_bytes': 50 * 1024 * 1024,
          };

  @override
  Future<List<PlanCatalogEntry>> listCatalog() async => defaultPlanCatalog();

  @override
  Future<EntitlementSnapshot> current() async => _snapshot();

  @override
  Future<EntitlementCheckResult> check({
    String? feature,
    String? metric,
  }) async {
    final snap = _snapshot();
    if (feature != null && feature.isNotEmpty) {
      final f = snap.features.cast<EntitlementFeature?>().firstWhere(
        (e) => e?.code == feature,
        orElse: () => null,
      );
      if (f == null) {
        return EntitlementCheckResult(
          allowed: false,
          enforcement: snap.enforcement,
          planCode: snap.planCode,
          feature: feature,
          reason: '未知功能码',
        );
      }
      if (f.allowed) {
        return EntitlementCheckResult(
          allowed: true,
          enforcement: snap.enforcement,
          planCode: snap.planCode,
          feature: feature,
        );
      }
      return EntitlementCheckResult(
        allowed: true, // soft
        enforcement: snap.enforcement,
        planCode: snap.planCode,
        feature: feature,
        reason: '软门禁：建议升级以正式启用',
      );
    }
    if (metric != null && metric.isNotEmpty) {
      final lim = snap.limits.cast<EntitlementLimit?>().firstWhere(
        (e) => e?.metric == metric,
        orElse: () => null,
      );
      if (lim == null || lim.limit == null) {
        return EntitlementCheckResult(
          allowed: true,
          enforcement: snap.enforcement,
          planCode: snap.planCode,
          metric: metric,
        );
      }
      if (!lim.over) {
        return EntitlementCheckResult(
          allowed: true,
          enforcement: snap.enforcement,
          planCode: snap.planCode,
          metric: metric,
        );
      }
      return EntitlementCheckResult(
        allowed: true,
        enforcement: snap.enforcement,
        planCode: snap.planCode,
        metric: metric,
        reason: '软门禁：已超限，可继续使用但建议升级',
      );
    }
    throw const PaywallRepositoryException('feature 或 metric 至少填一项');
  }

  @override
  Future<EntitlementSnapshot> sandboxActivate(String planCode) async {
    if (planCode != 'free' && planCode != 'pro') {
      throw const PaywallRepositoryException('未知套餐');
    }
    _planCode = planCode;
    _source = 'sandbox';
    return _snapshot();
  }

  EntitlementSnapshot _snapshot() {
    final isPro = _planCode == 'pro';
    final limits = <EntitlementLimit>[
      _limit('active_hamsters', '在养仓鼠', isPro ? 500 : 30, 'count'),
      _limit('active_litters', '活跃窝次', isPro ? 200 : 15, 'count'),
      _limit('enclosures', '笼盒', isPro ? 300 : 25, 'count'),
      if (!isPro)
        _limit('media_bytes', '媒体占用', 200 * 1024 * 1024, 'bytes')
      else
        EntitlementLimit(
          code: 'limit.media_bytes',
          metric: 'media_bytes',
          title: '媒体占用',
          used: _usage['media_bytes'] ?? 0,
          over: false,
          unit: 'bytes',
        ),
    ];
    final over = limits.any((l) => l.over);
    return EntitlementSnapshot(
      planCode: _planCode,
      planTitle: isPro ? '专业版' : '免费版',
      enforcement: 'soft',
      source: _source,
      effectiveAt: DateTime.now().toUtc(),
      features: [
        const EntitlementFeature(
          code: 'feature.genetic_simulator',
          title: '遗传模拟',
          description: 'A/B/C 配对概率',
          allowed: true,
        ),
        const EntitlementFeature(
          code: 'feature.server_push',
          title: '服务端推送',
          description: '设备令牌与测试推送',
          allowed: true,
        ),
        EntitlementFeature(
          code: 'feature.advanced_export',
          title: '高级导出',
          description: '扩展数据集导出',
          allowed: isPro,
        ),
        EntitlementFeature(
          code: 'feature.unlimited_media',
          title: '媒体扩容',
          description: '更高媒体存储上限',
          allowed: isPro,
        ),
      ],
      limits: limits,
      overLimit: over,
      paywallHint: over
          ? '部分用量已超过当前套餐建议上限，可升级专业版。'
          : (isPro ? null : '免费版可完整使用核心繁育流程；扩繁可升级专业版。'),
    );
  }

  EntitlementLimit _limit(
    String metric,
    String title,
    double limit,
    String unit,
  ) {
    final used = _usage[metric] ?? 0;
    return EntitlementLimit(
      code: 'limit.$metric',
      metric: metric,
      title: title,
      limit: limit,
      used: used,
      remaining: limit - used,
      over: used > limit,
      unit: unit,
    );
  }
}

class DefaultApiPaywallRepository implements PaywallRepository {
  DefaultApiPaywallRepository({required this.client});

  final ApiClient client;
  final _uuid = const Uuid();
  String _key() => 'ent-${_uuid.v4()}';

  Map<String, dynamic> _data(Response<Map<String, dynamic>> response) {
    final data = response.data?['data'];
    if (data is! Map) {
      throw const PaywallRepositoryException('响应为空');
    }
    return Map<String, dynamic>.from(data);
  }

  List<Map<String, dynamic>> _listData(
    Response<Map<String, dynamic>> response,
  ) {
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<List<PlanCatalogEntry>> listCatalog() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/entitlements/catalog',
    );
    final items = _listData(response).map(PlanCatalogEntry.fromJson).toList();
    return items.isEmpty ? defaultPlanCatalog() : items;
  }

  @override
  Future<EntitlementSnapshot> current() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '/entitlements/current',
    );
    return EntitlementSnapshot.fromJson(_data(response));
  }

  @override
  Future<EntitlementCheckResult> check({
    String? feature,
    String? metric,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/entitlements/check',
      data: {
        if (feature != null) 'feature': feature,
        if (metric != null) 'metric': metric,
      },
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return EntitlementCheckResult.fromJson(_data(response));
  }

  @override
  Future<EntitlementSnapshot> sandboxActivate(String planCode) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '/entitlements/sandbox/activate',
      data: {'plan_code': planCode},
      options: Options(headers: {'Idempotency-Key': _key()}),
    );
    return EntitlementSnapshot.fromJson(_data(response));
  }
}
