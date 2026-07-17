class OrganizationMember {
  const OrganizationMember({
    required this.id,
    required this.organizationId,
    this.accountId,
    required this.phone,
    this.displayName,
    required this.role,
    required this.status,
    required this.invitedAt,
    this.acceptedAt,
    this.revokedAt,
    required this.version,
  });

  final String id;
  final String organizationId;
  final String? accountId;
  final String phone;
  final String? displayName;
  final String role;
  final String status;
  final DateTime invitedAt;
  final DateTime? acceptedAt;
  final DateTime? revokedAt;
  final int version;

  bool get isOwner => role == 'owner';
  bool get isActive => status == 'active' || status == 'invited';

  String get title {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return phone;
  }

  factory OrganizationMember.fromJson(Map<String, dynamic> json) {
    return OrganizationMember(
      id: json['id'] as String? ?? '',
      organizationId: json['organization_id'] as String? ?? '',
      accountId: json['account_id'] as String?,
      phone: json['phone'] as String? ?? '',
      displayName: json['display_name'] as String?,
      role: json['role'] as String? ?? 'viewer',
      status: json['status'] as String? ?? 'invited',
      invitedAt:
          DateTime.tryParse(json['invited_at'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      acceptedAt: DateTime.tryParse(
        json['accepted_at'] as String? ?? '',
      )?.toUtc(),
      revokedAt: DateTime.tryParse(
        json['revoked_at'] as String? ?? '',
      )?.toUtc(),
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'organization_id': organizationId,
    'account_id': accountId,
    'phone': phone,
    'display_name': displayName,
    'role': role,
    'status': status,
    'invited_at': invitedAt.toIso8601String(),
    'accepted_at': acceptedAt?.toIso8601String(),
    'revoked_at': revokedAt?.toIso8601String(),
    'version': version,
  };

  OrganizationMember copyWith({
    String? role,
    String? status,
    String? displayName,
    int? version,
    DateTime? revokedAt,
  }) {
    return OrganizationMember(
      id: id,
      organizationId: organizationId,
      accountId: accountId,
      phone: phone,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedAt: invitedAt,
      acceptedAt: acceptedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      version: version ?? this.version,
    );
  }
}

class MemberInviteDraft {
  const MemberInviteDraft({
    required this.phone,
    required this.role,
    this.displayName,
  });

  final String phone;
  final String role;
  final String? displayName;
}
