// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_meta.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ResponseMetaCWProxy {
  ResponseMeta requestId(String requestId);

  ResponseMeta generatedAt(DateTime generatedAt);

  ResponseMeta timezone(String timezone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResponseMeta(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResponseMeta(...).copyWith(id: 12, name: "My name")
  /// ````
  ResponseMeta call({String requestId, DateTime generatedAt, String timezone});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfResponseMeta.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfResponseMeta.copyWith.fieldName(...)`
class _$ResponseMetaCWProxyImpl implements _$ResponseMetaCWProxy {
  const _$ResponseMetaCWProxyImpl(this._value);

  final ResponseMeta _value;

  @override
  ResponseMeta requestId(String requestId) => this(requestId: requestId);

  @override
  ResponseMeta generatedAt(DateTime generatedAt) =>
      this(generatedAt: generatedAt);

  @override
  ResponseMeta timezone(String timezone) => this(timezone: timezone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ResponseMeta(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ResponseMeta(...).copyWith(id: 12, name: "My name")
  /// ````
  ResponseMeta call({
    Object? requestId = const $CopyWithPlaceholder(),
    Object? generatedAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
  }) {
    return ResponseMeta(
      requestId: requestId == const $CopyWithPlaceholder()
          ? _value.requestId
          // ignore: cast_nullable_to_non_nullable
          : requestId as String,
      generatedAt: generatedAt == const $CopyWithPlaceholder()
          ? _value.generatedAt
          // ignore: cast_nullable_to_non_nullable
          : generatedAt as DateTime,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
    );
  }
}

extension $ResponseMetaCopyWith on ResponseMeta {
  /// Returns a callable class that can be used as follows: `instanceOfResponseMeta.copyWith(...)` or like so:`instanceOfResponseMeta.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ResponseMetaCWProxy get copyWith => _$ResponseMetaCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseMeta _$ResponseMetaFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ResponseMeta',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['request_id', 'generated_at', 'timezone'],
        );
        final val = ResponseMeta(
          requestId: $checkedConvert('request_id', (v) => v as String),
          generatedAt: $checkedConvert(
            'generated_at',
            (v) => DateTime.parse(v as String),
          ),
          timezone: $checkedConvert('timezone', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'requestId': 'request_id',
        'generatedAt': 'generated_at',
      },
    );

Map<String, dynamic> _$ResponseMetaToJson(ResponseMeta instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'generated_at': instance.generatedAt.toIso8601String(),
      'timezone': instance.timezone,
    };
