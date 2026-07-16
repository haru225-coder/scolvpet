// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_share_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicShareResponseDataCWProxy {
  PublicShareResponseData shareId(String shareId);

  PublicShareResponseData subjectType(
    PublicShareResponseDataSubjectTypeEnum subjectType,
  );

  PublicShareResponseData display(Map<String, Object> display);

  PublicShareResponseData media(List<MediaVariant> media);

  PublicShareResponseData expiresAt(DateTime? expiresAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicShareResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicShareResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicShareResponseData call({
    String shareId,
    PublicShareResponseDataSubjectTypeEnum subjectType,
    Map<String, Object> display,
    List<MediaVariant> media,
    DateTime? expiresAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicShareResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicShareResponseData.copyWith.fieldName(...)`
class _$PublicShareResponseDataCWProxyImpl
    implements _$PublicShareResponseDataCWProxy {
  const _$PublicShareResponseDataCWProxyImpl(this._value);

  final PublicShareResponseData _value;

  @override
  PublicShareResponseData shareId(String shareId) => this(shareId: shareId);

  @override
  PublicShareResponseData subjectType(
    PublicShareResponseDataSubjectTypeEnum subjectType,
  ) => this(subjectType: subjectType);

  @override
  PublicShareResponseData display(Map<String, Object> display) =>
      this(display: display);

  @override
  PublicShareResponseData media(List<MediaVariant> media) => this(media: media);

  @override
  PublicShareResponseData expiresAt(DateTime? expiresAt) =>
      this(expiresAt: expiresAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicShareResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicShareResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicShareResponseData call({
    Object? shareId = const $CopyWithPlaceholder(),
    Object? subjectType = const $CopyWithPlaceholder(),
    Object? display = const $CopyWithPlaceholder(),
    Object? media = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
  }) {
    return PublicShareResponseData(
      shareId: shareId == const $CopyWithPlaceholder()
          ? _value.shareId
          // ignore: cast_nullable_to_non_nullable
          : shareId as String,
      subjectType: subjectType == const $CopyWithPlaceholder()
          ? _value.subjectType
          // ignore: cast_nullable_to_non_nullable
          : subjectType as PublicShareResponseDataSubjectTypeEnum,
      display: display == const $CopyWithPlaceholder()
          ? _value.display
          // ignore: cast_nullable_to_non_nullable
          : display as Map<String, Object>,
      media: media == const $CopyWithPlaceholder()
          ? _value.media
          // ignore: cast_nullable_to_non_nullable
          : media as List<MediaVariant>,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime?,
    );
  }
}

extension $PublicShareResponseDataCopyWith on PublicShareResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfPublicShareResponseData.copyWith(...)` or like so:`instanceOfPublicShareResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicShareResponseDataCWProxy get copyWith =>
      _$PublicShareResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicShareResponseData _$PublicShareResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PublicShareResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['share_id', 'subject_type', 'display', 'media'],
    );
    final val = PublicShareResponseData(
      shareId: $checkedConvert('share_id', (v) => v as String),
      subjectType: $checkedConvert(
        'subject_type',
        (v) => $enumDecode(_$PublicShareResponseDataSubjectTypeEnumEnumMap, v),
      ),
      display: $checkedConvert(
        'display',
        (v) =>
            (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
      ),
      media: $checkedConvert(
        'media',
        (v) => (v as List<dynamic>)
            .map((e) => MediaVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      expiresAt: $checkedConvert(
        'expires_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'shareId': 'share_id',
    'subjectType': 'subject_type',
    'expiresAt': 'expires_at',
  },
);

Map<String, dynamic> _$PublicShareResponseDataToJson(
  PublicShareResponseData instance,
) => <String, dynamic>{
  'share_id': instance.shareId,
  'subject_type':
      _$PublicShareResponseDataSubjectTypeEnumEnumMap[instance.subjectType]!,
  'display': instance.display,
  'media': instance.media.map((e) => e.toJson()).toList(),
  'expires_at': ?instance.expiresAt?.toIso8601String(),
};

const _$PublicShareResponseDataSubjectTypeEnumEnumMap = {
  PublicShareResponseDataSubjectTypeEnum.hamster: 'hamster',
  PublicShareResponseDataSubjectTypeEnum.litter: 'litter',
};
