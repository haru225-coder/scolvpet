// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_job_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExportJobCreateRequestCWProxy {
  ExportJobCreateRequest datasets(
    Set<ExportJobCreateRequestDatasetsEnum> datasets,
  );

  ExportJobCreateRequest format(ExportJobCreateRequestFormatEnum format);

  ExportJobCreateRequest timezone(String timezone);

  ExportJobCreateRequest filters(Map<String, Object>? filters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJobCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJobCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJobCreateRequest call({
    Set<ExportJobCreateRequestDatasetsEnum> datasets,
    ExportJobCreateRequestFormatEnum format,
    String timezone,
    Map<String, Object>? filters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExportJobCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExportJobCreateRequest.copyWith.fieldName(...)`
class _$ExportJobCreateRequestCWProxyImpl
    implements _$ExportJobCreateRequestCWProxy {
  const _$ExportJobCreateRequestCWProxyImpl(this._value);

  final ExportJobCreateRequest _value;

  @override
  ExportJobCreateRequest datasets(
    Set<ExportJobCreateRequestDatasetsEnum> datasets,
  ) => this(datasets: datasets);

  @override
  ExportJobCreateRequest format(ExportJobCreateRequestFormatEnum format) =>
      this(format: format);

  @override
  ExportJobCreateRequest timezone(String timezone) => this(timezone: timezone);

  @override
  ExportJobCreateRequest filters(Map<String, Object>? filters) =>
      this(filters: filters);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExportJobCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExportJobCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ExportJobCreateRequest call({
    Object? datasets = const $CopyWithPlaceholder(),
    Object? format = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? filters = const $CopyWithPlaceholder(),
  }) {
    return ExportJobCreateRequest(
      datasets: datasets == const $CopyWithPlaceholder()
          ? _value.datasets
          // ignore: cast_nullable_to_non_nullable
          : datasets as Set<ExportJobCreateRequestDatasetsEnum>,
      format: format == const $CopyWithPlaceholder()
          ? _value.format
          // ignore: cast_nullable_to_non_nullable
          : format as ExportJobCreateRequestFormatEnum,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      filters: filters == const $CopyWithPlaceholder()
          ? _value.filters
          // ignore: cast_nullable_to_non_nullable
          : filters as Map<String, Object>?,
    );
  }
}

extension $ExportJobCreateRequestCopyWith on ExportJobCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfExportJobCreateRequest.copyWith(...)` or like so:`instanceOfExportJobCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExportJobCreateRequestCWProxy get copyWith =>
      _$ExportJobCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExportJobCreateRequest _$ExportJobCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExportJobCreateRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['datasets', 'format', 'timezone']);
  final val = ExportJobCreateRequest(
    datasets: $checkedConvert(
      'datasets',
      (v) => (v as List<dynamic>)
          .map(
            (e) => $enumDecode(_$ExportJobCreateRequestDatasetsEnumEnumMap, e),
          )
          .toSet(),
    ),
    format: $checkedConvert(
      'format',
      (v) => $enumDecode(_$ExportJobCreateRequestFormatEnumEnumMap, v),
    ),
    timezone: $checkedConvert('timezone', (v) => v as String),
    filters: $checkedConvert(
      'filters',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
  );
  return val;
});

Map<String, dynamic> _$ExportJobCreateRequestToJson(
  ExportJobCreateRequest instance,
) => <String, dynamic>{
  'datasets': instance.datasets
      .map((e) => _$ExportJobCreateRequestDatasetsEnumEnumMap[e]!)
      .toList(),
  'format': _$ExportJobCreateRequestFormatEnumEnumMap[instance.format]!,
  'timezone': instance.timezone,
  'filters': ?instance.filters,
};

const _$ExportJobCreateRequestDatasetsEnumEnumMap = {
  ExportJobCreateRequestDatasetsEnum.hamsters: 'hamsters',
  ExportJobCreateRequestDatasetsEnum.enclosures: 'enclosures',
  ExportJobCreateRequestDatasetsEnum.breeding: 'breeding',
  ExportJobCreateRequestDatasetsEnum.litters: 'litters',
  ExportJobCreateRequestDatasetsEnum.weights: 'weights',
  ExportJobCreateRequestDatasetsEnum.health: 'health',
  ExportJobCreateRequestDatasetsEnum.pedigree: 'pedigree',
};

const _$ExportJobCreateRequestFormatEnumEnumMap = {
  ExportJobCreateRequestFormatEnum.csvZip: 'csv_zip',
  ExportJobCreateRequestFormatEnum.json: 'json',
};
