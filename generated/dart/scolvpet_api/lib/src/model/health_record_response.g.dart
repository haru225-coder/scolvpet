// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$HealthRecordResponseCWProxy {
  HealthRecordResponse data(HealthRecord? data);

  HealthRecordResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecordResponse call({HealthRecord? data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfHealthRecordResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfHealthRecordResponse.copyWith.fieldName(...)`
class _$HealthRecordResponseCWProxyImpl
    implements _$HealthRecordResponseCWProxy {
  const _$HealthRecordResponseCWProxyImpl(this._value);

  final HealthRecordResponse _value;

  @override
  HealthRecordResponse data(HealthRecord? data) => this(data: data);

  @override
  HealthRecordResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `HealthRecordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// HealthRecordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  HealthRecordResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return HealthRecordResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as HealthRecord?,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $HealthRecordResponseCopyWith on HealthRecordResponse {
  /// Returns a callable class that can be used as follows: `instanceOfHealthRecordResponse.copyWith(...)` or like so:`instanceOfHealthRecordResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$HealthRecordResponseCWProxy get copyWith =>
      _$HealthRecordResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthRecordResponse _$HealthRecordResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('HealthRecordResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = HealthRecordResponse(
    data: $checkedConvert(
      'data',
      (v) =>
          v == null ? null : HealthRecord.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$HealthRecordResponseToJson(
  HealthRecordResponse instance,
) => <String, dynamic>{
  'data': instance.data?.toJson(),
  'meta': instance.meta.toJson(),
};
