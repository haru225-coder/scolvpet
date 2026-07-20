class CrmContact {
  const CrmContact({
    required this.id,
    required this.name,
    this.phone,
    this.wechat,
    this.notes,
    required this.status,
    required this.version,
  });

  final String id;
  final String name;
  final String? phone;
  final String? wechat;
  final String? notes;
  final String status;
  final int version;

  String get statusLabel => switch (status) {
    'lead' => '意向',
    'active' => '客户',
    'archived' => '归档',
    _ => status,
  };

  factory CrmContact.fromJson(Map<String, dynamic> json) => CrmContact(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    phone: json['phone'] as String?,
    wechat: json['wechat'] as String?,
    notes: json['notes'] as String?,
    status: json['status'] as String? ?? 'lead',
    version: (json['version'] as num?)?.toInt() ?? 1,
  );
}

class CrmReservation {
  const CrmReservation({
    required this.id,
    required this.contactId,
    this.hamsterId,
    required this.title,
    required this.status,
    required this.reservedAt,
    this.notes,
    required this.version,
    this.contactName,
    this.hamsterName,
  });

  final String id;
  final String contactId;
  final String? hamsterId;
  final String title;
  final String status;
  final DateTime reservedAt;
  final String? notes;
  final int version;
  final String? contactName;
  final String? hamsterName;

  String get statusLabel => switch (status) {
    'held' => '锁定中',
    'confirmed' => '已确认',
    'cancelled' => '已取消',
    'handed_over' => '已交付',
    _ => status,
  };

  /// 预订创建时间（公开主页与后台创建共用 reserved_at）。
  String get reservedLabel => _crmDateTimeLabel(reservedAt);

  bool get isOpen => status == 'held' || status == 'confirmed';

  factory CrmReservation.fromJson(Map<String, dynamic> json) => CrmReservation(
    id: json['id'] as String? ?? '',
    contactId: json['contact_id'] as String? ?? '',
    hamsterId: json['hamster_id'] as String?,
    title: json['title'] as String? ?? '预订',
    status: json['status'] as String? ?? 'held',
    reservedAt:
        DateTime.tryParse(json['reserved_at'] as String? ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    notes: json['notes'] as String?,
    version: (json['version'] as num?)?.toInt() ?? 1,
    contactName: json['contact_name'] as String?,
    hamsterName: json['hamster_name'] as String?,
  );
}

class CrmHandover {
  const CrmHandover({
    required this.id,
    required this.contactId,
    this.reservationId,
    this.hamsterId,
    required this.status,
    required this.scheduledAt,
    this.completedAt,
    this.notes,
    required this.version,
    this.contactName,
    this.hamsterName,
  });

  final String id;
  final String contactId;
  final String? reservationId;
  final String? hamsterId;
  final String status;
  final DateTime scheduledAt;
  final DateTime? completedAt;
  final String? notes;
  final int version;
  final String? contactName;
  final String? hamsterName;

  String get statusLabel => switch (status) {
    'scheduled' => '待交付',
    'completed' => '已完成',
    'cancelled' => '已取消',
    _ => status,
  };

  bool get isOpen => status == 'scheduled';

  String get scheduledLabel => _crmDateTimeLabel(scheduledAt);

  String? get completedLabel =>
      completedAt == null ? null : _crmDateTimeLabel(completedAt!);

  factory CrmHandover.fromJson(Map<String, dynamic> json) => CrmHandover(
    id: json['id'] as String? ?? '',
    contactId: json['contact_id'] as String? ?? '',
    reservationId: json['reservation_id'] as String?,
    hamsterId: json['hamster_id'] as String?,
    status: json['status'] as String? ?? 'scheduled',
    scheduledAt:
        DateTime.tryParse(json['scheduled_at'] as String? ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    completedAt: DateTime.tryParse(
      json['completed_at'] as String? ?? '',
    )?.toUtc(),
    notes: json['notes'] as String?,
    version: (json['version'] as num?)?.toInt() ?? 1,
    contactName: json['contact_name'] as String?,
    hamsterName: json['hamster_name'] as String?,
  );
}

class CrmContactDraft {
  const CrmContactDraft({
    required this.name,
    this.phone,
    this.wechat,
    this.notes,
    this.status = 'lead',
  });

  final String name;
  final String? phone;
  final String? wechat;
  final String? notes;
  final String status;
}

class CrmReservationDraft {
  const CrmReservationDraft({
    required this.contactId,
    required this.title,
    this.hamsterId,
    this.notes,
  });

  final String contactId;
  final String title;
  final String? hamsterId;
  final String? notes;
}

class CrmHandoverDraft {
  const CrmHandoverDraft({
    required this.contactId,
    this.reservationId,
    this.hamsterId,
    this.notes,
    this.scheduledAt,
  });

  final String contactId;
  final String? reservationId;
  final String? hamsterId;
  final String? notes;
  final DateTime? scheduledAt;
}

String _crmDateTimeLabel(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
