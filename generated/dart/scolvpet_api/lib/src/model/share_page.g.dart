// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_page.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SharePageCWProxy {
  SharePage id(String id);

  SharePage ownerId(String ownerId);

  SharePage subjectType(SharePageSubjectTypeEnum subjectType);

  SharePage subjectId(String subjectId);

  SharePage status(ShareStatus status);

  SharePage fields(Set<SharePublicField> fields);

  SharePage mediaIds(Set<String> mediaIds);

  SharePage publicUrl(String publicUrl);

  SharePage expiresAt(DateTime? expiresAt);

  SharePage revokedAt(DateTime? revokedAt);

  SharePage version(int version);

  SharePage createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SharePage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SharePage(...).copyWith(id: 12, name: "My name")
  /// ````
  SharePage call({
    String id,
    String ownerId,
    SharePageSubjectTypeEnum subjectType,
    String subjectId,
    ShareStatus status,
    Set<SharePublicField> fields,
    Set<String> mediaIds,
    String publicUrl,
    DateTime? expiresAt,
    DateTime? revokedAt,
    int version,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSharePage.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSharePage.copyWith.fieldName(...)`
class _$SharePageCWProxyImpl implements _$SharePageCWProxy {
  const _$SharePageCWProxyImpl(this._value);

  final SharePage _value;

  @override
  SharePage id(String id) => this(id: id);

  @override
  SharePage ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  SharePage subjectType(SharePageSubjectTypeEnum subjectType) =>
      this(subjectType: subjectType);

  @override
  SharePage subjectId(String subjectId) => this(subjectId: subjectId);

  @override
  SharePage status(ShareStatus status) => this(status: status);

  @override
  SharePage fields(Set<SharePublicField> fields) => this(fields: fields);

  @override
  SharePage mediaIds(Set<String> mediaIds) => this(mediaIds: mediaIds);

  @override
  SharePage publicUrl(String publicUrl) => this(publicUrl: publicUrl);

  @override
  SharePage expiresAt(DateTime? expiresAt) => this(expiresAt: expiresAt);

  @override
  SharePage revokedAt(DateTime? revokedAt) => this(revokedAt: revokedAt);

  @override
  SharePage version(int version) => this(version: version);

  @override
  SharePage createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SharePage(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SharePage(...).copyWith(id: 12, name: "My name")
  /// ````
  SharePage call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? subjectType = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? fields = const $CopyWithPlaceholder(),
    Object? mediaIds = const $CopyWithPlaceholder(),
    Object? publicUrl = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? revokedAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return SharePage(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      subjectType: subjectType == const $CopyWithPlaceholder()
          ? _value.subjectType
          // ignore: cast_nullable_to_non_nullable
          : subjectType as SharePageSubjectTypeEnum,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ShareStatus,
      fields: fields == const $CopyWithPlaceholder()
          ? _value.fields
          // ignore: cast_nullable_to_non_nullable
          : fields as Set<SharePublicField>,
      mediaIds: mediaIds == const $CopyWithPlaceholder()
          ? _value.mediaIds
          // ignore: cast_nullable_to_non_nullable
          : mediaIds as Set<String>,
      publicUrl: publicUrl == const $CopyWithPlaceholder()
          ? _value.publicUrl
          // ignore: cast_nullable_to_non_nullable
          : publicUrl as String,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
      revokedAt: revokedAt == const $CopyWithPlaceholder()
          ? _value.revokedAt
          // ignore: cast_nullable_to_non_nullable
          : revokedAt as DateTime?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $SharePageCopyWith on SharePage {
  /// Returns a callable class that can be used as follows: `instanceOfSharePage.copyWith(...)` or like so:`instanceOfSharePage.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SharePageCWProxy get copyWith => _$SharePageCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SharePage _$SharePageFromJson(Map<String, dynamic> json) => $checkedCreate(
  'SharePage',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'owner_id',
        'subject_type',
        'subject_id',
        'status',
        'fields',
        'media_ids',
        'public_url',
        'version',
        'created_at',
      ],
    );
    final val = SharePage(
      id: $checkedConvert('id', (v) => v as String),
      ownerId: $checkedConvert('owner_id', (v) => v as String),
      subjectType: $checkedConvert(
        'subject_type',
        (v) => $enumDecode(_$SharePageSubjectTypeEnumEnumMap, v),
      ),
      subjectId: $checkedConvert('subject_id', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$ShareStatusEnumMap, v),
      ),
      fields: $checkedConvert(
        'fields',
        (v) => (v as List<dynamic>)
            .map((e) => $enumDecode(_$SharePublicFieldEnumMap, e))
            .toSet(),
      ),
      mediaIds: $checkedConvert(
        'media_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
      ),
      publicUrl: $checkedConvert('public_url', (v) => v as String),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      revokedAt: $checkedConvert(
        'revoked_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      version: $checkedConvert('version', (v) => (v as num).toInt()),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'ownerId': 'owner_id',
    'subjectType': 'subject_type',
    'subjectId': 'subject_id',
    'mediaIds': 'media_ids',
    'publicUrl': 'public_url',
    'expiresAt': 'expires_at',
    'revokedAt': 'revoked_at',
    'createdAt': 'created_at',
  },
);

Map<String, dynamic> _$SharePageToJson(SharePage instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'subject_type': _$SharePageSubjectTypeEnumEnumMap[instance.subjectType]!,
  'subject_id': instance.subjectId,
  'status': _$ShareStatusEnumMap[instance.status]!,
  'fields': instance.fields.map((e) => _$SharePublicFieldEnumMap[e]!).toList(),
  'media_ids': instance.mediaIds.toList(),
  'public_url': instance.publicUrl,
  'expires_at': ?instance.expiresAt?.toIso8601String(),
  'revoked_at': ?instance.revokedAt?.toIso8601String(),
  'version': instance.version,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$SharePageSubjectTypeEnumEnumMap = {
  SharePageSubjectTypeEnum.hamster: 'hamster',
  SharePageSubjectTypeEnum.litter: 'litter',
};

const _$ShareStatusEnumMap = {
  ShareStatus.active: 'active',
  ShareStatus.expired: 'expired',
  ShareStatus.revoked: 'revoked',
};

const _$SharePublicFieldEnumMap = {
  SharePublicField.name: 'name',
  SharePublicField.cover: 'cover',
  SharePublicField.sex: 'sex',
  SharePublicField.birthDate: 'birth_date',
  SharePublicField.variety: 'variety',
  SharePublicField.pedigreeSummary: 'pedigree_summary',
  SharePublicField.litterCode: 'litter_code',
  SharePublicField.bornAt: 'born_at',
  SharePublicField.parents: 'parents',
  SharePublicField.memberCount: 'member_count',
};
