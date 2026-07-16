// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_processing_retry_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MediaProcessingRetryRequestCWProxy {
  MediaProcessingRetryRequest scope(MediaProcessingRetryRequestScopeEnum scope);

  MediaProcessingRetryRequest variantIds(Set<String>? variantIds);

  MediaProcessingRetryRequest reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaProcessingRetryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaProcessingRetryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaProcessingRetryRequest call({
    MediaProcessingRetryRequestScopeEnum scope,
    Set<String>? variantIds,
    String reason,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfMediaProcessingRetryRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfMediaProcessingRetryRequest.copyWith.fieldName(...)`
class _$MediaProcessingRetryRequestCWProxyImpl
    implements _$MediaProcessingRetryRequestCWProxy {
  const _$MediaProcessingRetryRequestCWProxyImpl(this._value);

  final MediaProcessingRetryRequest _value;

  @override
  MediaProcessingRetryRequest scope(
    MediaProcessingRetryRequestScopeEnum scope,
  ) => this(scope: scope);

  @override
  MediaProcessingRetryRequest variantIds(Set<String>? variantIds) =>
      this(variantIds: variantIds);

  @override
  MediaProcessingRetryRequest reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `MediaProcessingRetryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// MediaProcessingRetryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  MediaProcessingRetryRequest call({
    Object? scope = const $CopyWithPlaceholder(),
    Object? variantIds = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return MediaProcessingRetryRequest(
      scope: scope == const $CopyWithPlaceholder()
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as MediaProcessingRetryRequestScopeEnum,
      variantIds: variantIds == const $CopyWithPlaceholder()
          ? _value.variantIds
          // ignore: cast_nullable_to_non_nullable
          : variantIds as Set<String>?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $MediaProcessingRetryRequestCopyWith on MediaProcessingRetryRequest {
  /// Returns a callable class that can be used as follows: `instanceOfMediaProcessingRetryRequest.copyWith(...)` or like so:`instanceOfMediaProcessingRetryRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MediaProcessingRetryRequestCWProxy get copyWith =>
      _$MediaProcessingRetryRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaProcessingRetryRequest _$MediaProcessingRetryRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'MediaProcessingRetryRequest',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['scope', 'reason']);
    final val = MediaProcessingRetryRequest(
      scope: $checkedConvert(
        'scope',
        (v) => $enumDecode(_$MediaProcessingRetryRequestScopeEnumEnumMap, v),
      ),
      variantIds: $checkedConvert(
        'variant_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toSet(),
      ),
      reason: $checkedConvert('reason', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'variantIds': 'variant_ids'},
);

Map<String, dynamic> _$MediaProcessingRetryRequestToJson(
  MediaProcessingRetryRequest instance,
) => <String, dynamic>{
  'scope': _$MediaProcessingRetryRequestScopeEnumEnumMap[instance.scope]!,
  'variant_ids': ?instance.variantIds?.toList(),
  'reason': instance.reason,
};

const _$MediaProcessingRetryRequestScopeEnumEnumMap = {
  MediaProcessingRetryRequestScopeEnum.failedVariants: 'failed_variants',
  MediaProcessingRetryRequestScopeEnum.videoTranscode: 'video_transcode',
  MediaProcessingRetryRequestScopeEnum.imageDerivatives: 'image_derivatives',
};
