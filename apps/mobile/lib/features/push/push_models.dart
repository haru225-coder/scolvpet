class PushDevice {
  const PushDevice({
    required this.id,
    required this.platform,
    required this.provider,
    required this.token,
    this.deviceName,
    this.appVersion,
    required this.enabled,
    required this.lastSeenAt,
    required this.version,
  });

  final String id;
  final String platform;
  final String provider;
  final String token;
  final String? deviceName;
  final String? appVersion;
  final bool enabled;
  final DateTime lastSeenAt;
  final int version;

  String get platformLabel => switch (platform) {
    'ios' => 'iOS',
    'android' => 'Android',
    'web' => 'Web',
    _ => platform,
  };

  String get tokenPreview {
    if (token.length <= 12) return token;
    return '…${token.substring(token.length - 8)}';
  }

  factory PushDevice.fromJson(Map<String, dynamic> json) => PushDevice(
    id: json['id'] as String? ?? '',
    platform: json['platform'] as String? ?? 'unknown',
    provider: json['provider'] as String? ?? 'log',
    token: json['token'] as String? ?? '',
    deviceName: json['device_name'] as String?,
    appVersion: json['app_version'] as String?,
    enabled: json['enabled'] as bool? ?? true,
    lastSeenAt:
        DateTime.tryParse(json['last_seen_at'] as String? ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    version: (json['version'] as num?)?.toInt() ?? 1,
  );
}

class PushMessage {
  const PushMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.status,
    this.targetDeviceId,
    required this.provider,
    this.providerMessageId,
    required this.attemptCount,
    this.lastError,
    this.sentAt,
    required this.version,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String status;
  final String? targetDeviceId;
  final String provider;
  final String? providerMessageId;
  final int attemptCount;
  final String? lastError;
  final DateTime? sentAt;
  final int version;
  final DateTime createdAt;

  String get statusLabel => switch (status) {
    'queued' => '排队中',
    'sending' => '发送中',
    'sent' => '已发送',
    'failed' => '失败',
    'dead_letter' => '死信',
    _ => status,
  };

  bool get isSent => status == 'sent';

  factory PushMessage.fromJson(Map<String, dynamic> json) => PushMessage(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    data: json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : const {},
    status: json['status'] as String? ?? 'queued',
    targetDeviceId: json['target_device_id'] as String?,
    provider: json['provider'] as String? ?? 'log',
    providerMessageId: json['provider_message_id'] as String?,
    attemptCount: (json['attempt_count'] as num?)?.toInt() ?? 0,
    lastError: json['last_error'] as String?,
    sentAt: DateTime.tryParse(json['sent_at'] as String? ?? '')?.toUtc(),
    version: (json['version'] as num?)?.toInt() ?? 1,
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
}

class PushDeviceDraft {
  const PushDeviceDraft({
    required this.token,
    this.platform = 'unknown',
    this.provider = 'log',
    this.deviceName,
    this.appVersion,
  });

  final String token;
  final String platform;
  final String provider;
  final String? deviceName;
  final String? appVersion;
}

class PushMessageDraft {
  const PushMessageDraft({
    required this.title,
    required this.body,
    this.data = const {},
    this.targetDeviceId,
  });

  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? targetDeviceId;
}
