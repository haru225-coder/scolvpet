class PlanCatalogEntry {
  const PlanCatalogEntry({
    required this.code,
    required this.title,
    required this.description,
    required this.priceHint,
    required this.enforcement,
    this.highlight = false,
  });

  final String code;
  final String title;
  final String description;
  final String priceHint;
  final String enforcement;
  final bool highlight;

  factory PlanCatalogEntry.fromJson(Map<String, dynamic> json) =>
      PlanCatalogEntry(
        code: json['code'] as String? ?? 'free',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        priceHint: json['price_hint'] as String? ?? '',
        enforcement: json['enforcement'] as String? ?? 'soft',
        highlight: json['highlight'] as bool? ?? false,
      );
}

class EntitlementFeature {
  const EntitlementFeature({
    required this.code,
    required this.title,
    required this.description,
    required this.allowed,
  });

  final String code;
  final String title;
  final String description;
  final bool allowed;

  factory EntitlementFeature.fromJson(Map<String, dynamic> json) =>
      EntitlementFeature(
        code: json['code'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        allowed: json['allowed'] as bool? ?? false,
      );
}

class EntitlementLimit {
  const EntitlementLimit({
    required this.code,
    required this.metric,
    required this.title,
    this.limit,
    required this.used,
    this.remaining,
    required this.over,
    required this.unit,
  });

  final String code;
  final String metric;
  final String title;
  final double? limit;
  final double used;
  final double? remaining;
  final bool over;
  final String unit;

  String get usedLabel {
    if (unit == 'bytes') return _formatBytes(used);
    return used == used.roundToDouble()
        ? used.toInt().toString()
        : used.toStringAsFixed(1);
  }

  String get limitLabel {
    if (limit == null) return '不限';
    if (unit == 'bytes') return _formatBytes(limit!);
    return limit == limit!.roundToDouble()
        ? limit!.toInt().toString()
        : limit!.toStringAsFixed(1);
  }

  double get progress {
    if (limit == null || limit! <= 0) return 0;
    return (used / limit!).clamp(0.0, 1.5);
  }

  factory EntitlementLimit.fromJson(Map<String, dynamic> json) =>
      EntitlementLimit(
        code: json['code'] as String? ?? '',
        metric: json['metric'] as String? ?? '',
        title: json['title'] as String? ?? '',
        limit: (json['limit'] as num?)?.toDouble(),
        used: (json['used'] as num?)?.toDouble() ?? 0,
        remaining: (json['remaining'] as num?)?.toDouble(),
        over: json['over'] as bool? ?? false,
        unit: json['unit'] as String? ?? 'count',
      );
}

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.planCode,
    required this.planTitle,
    required this.enforcement,
    required this.source,
    required this.effectiveAt,
    this.expiresAt,
    required this.features,
    required this.limits,
    required this.overLimit,
    this.paywallHint,
  });

  final String planCode;
  final String planTitle;
  final String enforcement;
  final String source;
  final DateTime effectiveAt;
  final DateTime? expiresAt;
  final List<EntitlementFeature> features;
  final List<EntitlementLimit> limits;
  final bool overLimit;
  final String? paywallHint;

  bool get isPro => planCode == 'pro';

  factory EntitlementSnapshot.fromJson(Map<String, dynamic> json) {
    final features = json['features'];
    final limits = json['limits'];
    return EntitlementSnapshot(
      planCode: json['plan_code'] as String? ?? 'free',
      planTitle: json['plan_title'] as String? ?? '免费版',
      enforcement: json['enforcement'] as String? ?? 'soft',
      source: json['source'] as String? ?? 'system',
      effectiveAt:
          DateTime.tryParse(json['effective_at'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '')?.toUtc(),
      features: features is List
          ? features
                .whereType<Map>()
                .map(
                  (e) => EntitlementFeature.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      limits: limits is List
          ? limits
                .whereType<Map>()
                .map(
                  (e) =>
                      EntitlementLimit.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      overLimit: json['over_limit'] as bool? ?? false,
      paywallHint: json['paywall_hint'] as String?,
    );
  }
}

class EntitlementCheckResult {
  const EntitlementCheckResult({
    required this.allowed,
    required this.enforcement,
    required this.planCode,
    this.reason,
    this.feature,
    this.metric,
  });

  final bool allowed;
  final String enforcement;
  final String planCode;
  final String? reason;
  final String? feature;
  final String? metric;

  factory EntitlementCheckResult.fromJson(Map<String, dynamic> json) =>
      EntitlementCheckResult(
        allowed: json['allowed'] as bool? ?? false,
        enforcement: json['enforcement'] as String? ?? 'soft',
        planCode: json['plan_code'] as String? ?? 'free',
        reason: json['reason'] as String?,
        feature: json['feature'] as String?,
        metric: json['metric'] as String?,
      );
}

String _formatBytes(double value) {
  if (value < 1024) return '${value.toStringAsFixed(0)} B';
  if (value < 1024 * 1024) return '${(value / 1024).toStringAsFixed(1)} KB';
  if (value < 1024 * 1024 * 1024) {
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(value / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}

/// Local defaults when offline / memory repository.
List<PlanCatalogEntry> defaultPlanCatalog() => const [
  PlanCatalogEntry(
    code: 'free',
    title: '免费版',
    description: '单舍日常管理与基础数据中心',
    priceHint: '免费',
    enforcement: 'soft',
  ),
  PlanCatalogEntry(
    code: 'pro',
    title: '专业版',
    description: '更高用量与高级导出；适合扩繁',
    priceHint: '沙箱可激活 · 正式支付另接',
    enforcement: 'soft',
    highlight: true,
  ),
];
