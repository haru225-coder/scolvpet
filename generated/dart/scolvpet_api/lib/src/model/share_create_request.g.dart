// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ShareCreateRequestCWProxy {
  ShareCreateRequest subjectType(ShareCreateRequestSubjectTypeEnum subjectType);

  ShareCreateRequest subjectId(String subjectId);

  ShareCreateRequest fields(Set<SharePublicField> fields);

  ShareCreateRequest mediaIds(Set<String> mediaIds);

  ShareCreateRequest expiresAt(DateTime? expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareCreateRequest call({
    ShareCreateRequestSubjectTypeEnum subjectType,
    String subjectId,
    Set<SharePublicField> fields,
    Set<String> mediaIds,
    DateTime? expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfShareCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfShareCreateRequest.copyWith.fieldName(...)`
class _$ShareCreateRequestCWProxyImpl implements _$ShareCreateRequestCWProxy {
  const _$ShareCreateRequestCWProxyImpl(this._value);

  final ShareCreateRequest _value;

  @override
  ShareCreateRequest subjectType(
    ShareCreateRequestSubjectTypeEnum subjectType,
  ) => this(subjectType: subjectType);

  @override
  ShareCreateRequest subjectId(String subjectId) => this(subjectId: subjectId);

  @override
  ShareCreateRequest fields(Set<SharePublicField> fields) =>
      this(fields: fields);

  @override
  ShareCreateRequest mediaIds(Set<String> mediaIds) => this(mediaIds: mediaIds);

  @override
  ShareCreateRequest expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareCreateRequest call({
    Object? subjectType = const $CopyWithPlaceholder(),
    Object? subjectId = const $CopyWithPlaceholder(),
    Object? fields = const $CopyWithPlaceholder(),
    Object? mediaIds = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return ShareCreateRequest(
      subjectType: subjectType == const $CopyWithPlaceholder()
          ? _value.subjectType
          // ignore: cast_nullable_to_non_nullable
          : subjectType as ShareCreateRequestSubjectTypeEnum,
      subjectId: subjectId == const $CopyWithPlaceholder()
          ? _value.subjectId
          // ignore: cast_nullable_to_non_nullable
          : subjectId as String,
      fields: fields == const $CopyWithPlaceholder()
          ? _value.fields
          // ignore: cast_nullable_to_non_nullable
          : fields as Set<SharePublicField>,
      mediaIds: mediaIds == const $CopyWithPlaceholder()
          ? _value.mediaIds
          // ignore: cast_nullable_to_non_nullable
          : mediaIds as Set<String>,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
    );
  }
}

extension $ShareCreateRequestCopyWith on ShareCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfShareCreateRequest.copyWith(...)` or like so:`instanceOfShareCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ShareCreateRequestCWProxy get copyWith =>
      _$ShareCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareCreateRequest _$ShareCreateRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ShareCreateRequest',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'subject_type',
            'subject_id',
            'fields',
            'media_ids',
          ],
        );
        final val = ShareCreateRequest(
          subjectType: $checkedConvert(
            'subject_type',
            (v) => $enumDecode(_$ShareCreateRequestSubjectTypeEnumEnumMap, v),
          ),
          subjectId: $checkedConvert('subject_id', (v) => v as String),
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
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'subjectType': 'subject_type',
        'subjectId': 'subject_id',
        'mediaIds': 'media_ids',
        'expiresAt': 'expires_at',
      },
    );

Map<String, dynamic> _$ShareCreateRequestToJson(
  ShareCreateRequest instance,
) => <String, dynamic>{
  'subject_type':
      _$ShareCreateRequestSubjectTypeEnumEnumMap[instance.subjectType]!,
  'subject_id': instance.subjectId,
  'fields': instance.fields.map((e) => _$SharePublicFieldEnumMap[e]!).toList(),
  'media_ids': instance.mediaIds.toList(),
  'expires_at': ?instance.expiresAt?.toIso8601String(),
};

const _$ShareCreateRequestSubjectTypeEnumEnumMap = {
  ShareCreateRequestSubjectTypeEnum.hamster: 'hamster',
  ShareCreateRequestSubjectTypeEnum.litter: 'litter',
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
