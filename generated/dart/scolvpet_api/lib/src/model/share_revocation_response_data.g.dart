// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_revocation_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ShareRevocationResponseDataCWProxy {
  ShareRevocationResponseData share(SharePage share);

  ShareRevocationResponseData revokedAt(DateTime revokedAt);

  ShareRevocationResponseData cacheInvalidation(
    ShareRevocationResponseDataCacheInvalidation cacheInvalidation,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareRevocationResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareRevocationResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareRevocationResponseData call({
    SharePage share,
    DateTime revokedAt,
    ShareRevocationResponseDataCacheInvalidation cacheInvalidation,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfShareRevocationResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfShareRevocationResponseData.copyWith.fieldName(...)`
class _$ShareRevocationResponseDataCWProxyImpl
    implements _$ShareRevocationResponseDataCWProxy {
  const _$ShareRevocationResponseDataCWProxyImpl(this._value);

  final ShareRevocationResponseData _value;

  @override
  ShareRevocationResponseData share(SharePage share) => this(share: share);

  @override
  ShareRevocationResponseData revokedAt(DateTime revokedAt) =>
      this(revokedAt: revokedAt);

  @override
  ShareRevocationResponseData cacheInvalidation(
    ShareRevocationResponseDataCacheInvalidation cacheInvalidation,
  ) => this(cacheInvalidation: cacheInvalidation);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ShareRevocationResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ShareRevocationResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  ShareRevocationResponseData call({
    Object? share = const $CopyWithPlaceholder(),
    Object? revokedAt = const $CopyWithPlaceholder(),
    Object? cacheInvalidation = const $CopyWithPlaceholder(),
  }) {
    return ShareRevocationResponseData(
      share: share == const $CopyWithPlaceholder()
          ? _value.share
          // ignore: cast_nullable_to_non_nullable
          : share as SharePage,
      revokedAt: revokedAt == const $CopyWithPlaceholder()
          ? _value.revokedAt
          // ignore: cast_nullable_to_non_nullable
          : revokedAt as DateTime,
      cacheInvalidation: cacheInvalidation == const $CopyWithPlaceholder()
          ? _value.cacheInvalidation
          // ignore: cast_nullable_to_non_nullable
          : cacheInvalidation as ShareRevocationResponseDataCacheInvalidation,
    );
  }
}

extension $ShareRevocationResponseDataCopyWith on ShareRevocationResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfShareRevocationResponseData.copyWith(...)` or like so:`instanceOfShareRevocationResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ShareRevocationResponseDataCWProxy get copyWith =>
      _$ShareRevocationResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareRevocationResponseData _$ShareRevocationResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'ShareRevocationResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['share', 'revoked_at', 'cache_invalidation'],
    );
    final val = ShareRevocationResponseData(
      share: $checkedConvert(
        'share',
        (v) => SharePage.fromJson(v as Map<String, dynamic>),
      ),
      revokedAt: $checkedConvert(
        'revoked_at',
        (v) => DateTime.parse(v as String),
      ),
      cacheInvalidation: $checkedConvert(
        'cache_invalidation',
        (v) => ShareRevocationResponseDataCacheInvalidation.fromJson(
          v as Map<String, dynamic>,
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'revokedAt': 'revoked_at',
    'cacheInvalidation': 'cache_invalidation',
  },
);

Map<String, dynamic> _$ShareRevocationResponseDataToJson(
  ShareRevocationResponseData instance,
) => <String, dynamic>{
  'share': instance.share.toJson(),
  'revoked_at': instance.revokedAt.toIso8601String(),
  'cache_invalidation': instance.cacheInvalidation.toJson(),
};
