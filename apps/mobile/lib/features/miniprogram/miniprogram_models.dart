class MiniprogramConfig {
  const MiniprogramConfig({
    this.id,
    required this.displayName,
    this.appId,
    this.boundPublicSlug,
    required this.enabled,
    this.version = 0,
    this.updatedAt,
    this.pipelineNote,
  });

  final String? id;
  final String displayName;
  final String? appId;
  final String? boundPublicSlug;
  final bool enabled;
  final int version;
  final DateTime? updatedAt;
  final String? pipelineNote;

  factory MiniprogramConfig.fromJson(Map<String, dynamic> json) =>
      MiniprogramConfig(
        id: json['id'] as String?,
        displayName: json['display_name'] as String? ?? '熊舍小程序',
        appId: json['app_id'] as String?,
        boundPublicSlug: json['bound_public_slug'] as String?,
        enabled: json['enabled'] as bool? ?? true,
        version: (json['version'] as num?)?.toInt() ?? 0,
        updatedAt: DateTime.tryParse(
          json['updated_at'] as String? ?? '',
        )?.toUtc(),
        pipelineNote: json['pipeline_note'] as String?,
      );
}

class MiniprogramRelease {
  const MiniprogramRelease({
    required this.id,
    required this.versionLabel,
    required this.status,
    required this.title,
    this.summary,
    this.publicSlug,
    this.auditNote,
    this.submittedAt,
    this.auditedAt,
    this.publishedAt,
    this.rolledBackAt,
    required this.version,
    required this.createdAt,
  });

  final String id;
  final String versionLabel;
  final String status;
  final String title;
  final String? summary;
  final String? publicSlug;
  final String? auditNote;
  final DateTime? submittedAt;
  final DateTime? auditedAt;
  final DateTime? publishedAt;
  final DateTime? rolledBackAt;
  final int version;
  final DateTime createdAt;

  String get statusLabel => switch (status) {
    'draft' => '草稿',
    'submitted' => '已提交',
    'auditing' => '审核中',
    'approved' => '已通过',
    'rejected' => '已驳回',
    'published' => '已发布',
    'rolled_back' => '已回滚',
    _ => status,
  };

  bool get canSubmit => status == 'draft' || status == 'rejected';
  bool get canAudit => status == 'submitted' || status == 'auditing';
  bool get canPublish => status == 'approved';
  bool get canRollback => status == 'published';

  factory MiniprogramRelease.fromJson(Map<String, dynamic> json) =>
      MiniprogramRelease(
        id: json['id'] as String? ?? '',
        versionLabel: json['version_label'] as String? ?? '',
        status: json['status'] as String? ?? 'draft',
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String?,
        publicSlug: json['public_slug'] as String?,
        auditNote: json['audit_note'] as String?,
        submittedAt: DateTime.tryParse(
          json['submitted_at'] as String? ?? '',
        )?.toUtc(),
        auditedAt: DateTime.tryParse(
          json['audited_at'] as String? ?? '',
        )?.toUtc(),
        publishedAt: DateTime.tryParse(
          json['published_at'] as String? ?? '',
        )?.toUtc(),
        rolledBackAt: DateTime.tryParse(
          json['rolled_back_at'] as String? ?? '',
        )?.toUtc(),
        version: (json['version'] as num?)?.toInt() ?? 1,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '')?.toUtc() ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
}

class MiniprogramConfigDraft {
  const MiniprogramConfigDraft({
    required this.displayName,
    this.appId,
    this.boundPublicSlug,
    this.enabled = true,
  });

  final String displayName;
  final String? appId;
  final String? boundPublicSlug;
  final bool enabled;
}

class MiniprogramReleaseDraft {
  const MiniprogramReleaseDraft({
    required this.versionLabel,
    required this.title,
    this.summary,
    this.publicSlug,
  });

  final String versionLabel;
  final String title;
  final String? summary;
  final String? publicSlug;
}
