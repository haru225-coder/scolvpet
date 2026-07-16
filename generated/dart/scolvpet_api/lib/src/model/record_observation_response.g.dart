// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_observation_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecordObservationResponseCWProxy {
  RecordObservationResponse data(RecordObservationResponseData data);

  RecordObservationResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecordObservationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecordObservationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordObservationResponse call({
    RecordObservationResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecordObservationResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecordObservationResponse.copyWith.fieldName(...)`
class _$RecordObservationResponseCWProxyImpl
    implements _$RecordObservationResponseCWProxy {
  const _$RecordObservationResponseCWProxyImpl(this._value);

  final RecordObservationResponse _value;

  @override
  RecordObservationResponse data(RecordObservationResponseData data) =>
      this(data: data);

  @override
  RecordObservationResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecordObservationResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecordObservationResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  RecordObservationResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return RecordObservationResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as RecordObservationResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $RecordObservationResponseCopyWith on RecordObservationResponse {
  /// Returns a callable class that can be used as follows: `instanceOfRecordObservationResponse.copyWith(...)` or like so:`instanceOfRecordObservationResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecordObservationResponseCWProxy get copyWith =>
      _$RecordObservationResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordObservationResponse _$RecordObservationResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RecordObservationResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = RecordObservationResponse(
    data: $checkedConvert(
      'data',
      (v) => RecordObservationResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$RecordObservationResponseToJson(
  RecordObservationResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
