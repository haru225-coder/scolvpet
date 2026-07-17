class StudListing {
  const StudListing({
    required this.id,
    required this.ownerId,
    required this.sireLabel,
    required this.title,
    required this.feeCents,
    required this.currency,
    this.notes,
    required this.published,
    required this.version,
    required this.updatedAt,
    this.catteryName,
    required this.isMine,
  });

  final String id;
  final String ownerId;
  final String sireLabel;
  final String title;
  final int feeCents;
  final String currency;
  final String? notes;
  final bool published;
  final int version;
  final DateTime updatedAt;
  final String? catteryName;
  final bool isMine;

  String get feeLabel {
    final yuan = feeCents / 100.0;
    return '${yuan.toStringAsFixed(2)} $currency';
  }

  factory StudListing.fromJson(Map<String, dynamic> json) => StudListing(
    id: json['id'] as String? ?? '',
    ownerId: json['owner_id'] as String? ?? '',
    sireLabel: json['sire_label'] as String? ?? '',
    title: json['title'] as String? ?? '',
    feeCents: (json['fee_cents'] as num?)?.toInt() ?? 0,
    currency: json['currency'] as String? ?? 'CNY',
    notes: json['notes'] as String?,
    published: json['published'] as bool? ?? true,
    version: (json['version'] as num?)?.toInt() ?? 1,
    updatedAt:
        DateTime.tryParse(json['updated_at'] as String? ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    catteryName: json['cattery_name'] as String?,
    isMine: json['is_mine'] as bool? ?? false,
  );
}

class StudDeal {
  const StudDeal({
    required this.id,
    this.listingId,
    required this.side,
    required this.status,
    this.myHamsterLabel,
    required this.partnerCatteryName,
    this.partnerContact,
    this.partnerAnimalLabel,
    required this.feeCents,
    required this.currency,
    this.notes,
    this.confirmedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    required this.version,
    required this.updatedAt,
  });

  final String id;
  final String? listingId;
  final String side;
  final String status;
  final String? myHamsterLabel;
  final String partnerCatteryName;
  final String? partnerContact;
  final String? partnerAnimalLabel;
  final int feeCents;
  final String currency;
  final String? notes;
  final DateTime? confirmedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final int version;
  final DateTime updatedAt;

  String get sideLabel => side == 'provider' ? '出借种公' : '借入种公';

  String get statusLabel => switch (status) {
    'draft' => '草稿',
    'requested' => '已申请',
    'confirmed' => '已确认',
    'in_progress' => '进行中',
    'completed' => '已完成',
    'cancelled' => '已取消',
    _ => status,
  };

  String get feeLabel {
    final yuan = feeCents / 100.0;
    return '${yuan.toStringAsFixed(2)} $currency';
  }

  bool get canConfirm => status == 'draft' || status == 'requested';
  bool get canStart => status == 'confirmed';
  bool get canComplete => status == 'in_progress' || status == 'confirmed';
  bool get canCancel =>
      status == 'draft' ||
      status == 'requested' ||
      status == 'confirmed' ||
      status == 'in_progress';

  factory StudDeal.fromJson(Map<String, dynamic> json) => StudDeal(
    id: json['id'] as String? ?? '',
    listingId: json['listing_id'] as String?,
    side: json['side'] as String? ?? 'requester',
    status: json['status'] as String? ?? 'draft',
    myHamsterLabel: json['my_hamster_label'] as String?,
    partnerCatteryName: json['partner_cattery_name'] as String? ?? '',
    partnerContact: json['partner_contact'] as String?,
    partnerAnimalLabel: json['partner_animal_label'] as String?,
    feeCents: (json['fee_cents'] as num?)?.toInt() ?? 0,
    currency: json['currency'] as String? ?? 'CNY',
    notes: json['notes'] as String?,
    confirmedAt: DateTime.tryParse(
      json['confirmed_at'] as String? ?? '',
    )?.toUtc(),
    startedAt: DateTime.tryParse(json['started_at'] as String? ?? '')?.toUtc(),
    completedAt: DateTime.tryParse(
      json['completed_at'] as String? ?? '',
    )?.toUtc(),
    cancelledAt: DateTime.tryParse(
      json['cancelled_at'] as String? ?? '',
    )?.toUtc(),
    version: (json['version'] as num?)?.toInt() ?? 1,
    updatedAt:
        DateTime.tryParse(json['updated_at'] as String? ?? '')?.toUtc() ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
}

class StudListingDraft {
  const StudListingDraft({
    required this.sireLabel,
    required this.title,
    this.feeCents = 0,
    this.currency = 'CNY',
    this.notes,
    this.published = true,
  });

  final String sireLabel;
  final String title;
  final int feeCents;
  final String currency;
  final String? notes;
  final bool published;
}

class StudDealDraft {
  const StudDealDraft({
    this.listingId,
    required this.side,
    required this.partnerCatteryName,
    this.myHamsterLabel,
    this.partnerContact,
    this.partnerAnimalLabel,
    this.feeCents = 0,
    this.currency = 'CNY',
    this.notes,
  });

  final String? listingId;
  final String side;
  final String partnerCatteryName;
  final String? myHamsterLabel;
  final String? partnerContact;
  final String? partnerAnimalLabel;
  final int feeCents;
  final String currency;
  final String? notes;
}
