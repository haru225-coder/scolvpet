// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_center_summary_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DataCenterSummaryResponseCWProxy {
  DataCenterSummaryResponse data(DataCenterSummaryResponseData data);

  DataCenterSummaryResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCenterSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCenterSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCenterSummaryResponse call({
    DataCenterSummaryResponseData data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDataCenterSummaryResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDataCenterSummaryResponse.copyWith.fieldName(...)`
class _$DataCenterSummaryResponseCWProxyImpl
    implements _$DataCenterSummaryResponseCWProxy {
  const _$DataCenterSummaryResponseCWProxyImpl(this._value);

  final DataCenterSummaryResponse _value;

  @override
  DataCenterSummaryResponse data(DataCenterSummaryResponseData data) =>
      this(data: data);

  @override
  DataCenterSummaryResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCenterSummaryResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCenterSummaryResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCenterSummaryResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return DataCenterSummaryResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as DataCenterSummaryResponseData,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $DataCenterSummaryResponseCopyWith on DataCenterSummaryResponse {
  /// Returns a callable class that can be used as follows: `instanceOfDataCenterSummaryResponse.copyWith(...)` or like so:`instanceOfDataCenterSummaryResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DataCenterSummaryResponseCWProxy get copyWith =>
      _$DataCenterSummaryResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCenterSummaryResponse _$DataCenterSummaryResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DataCenterSummaryResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = DataCenterSummaryResponse(
    data: $checkedConvert(
      'data',
      (v) => DataCenterSummaryResponseData.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$DataCenterSummaryResponseToJson(
  DataCenterSummaryResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
