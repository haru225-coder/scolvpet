// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_center_summary_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DataCenterSummaryResponseDataCWProxy {
  DataCenterSummaryResponseData recentImports(List<ImportJob> recentImports);

  DataCenterSummaryResponseData recentExports(List<ExportJob> recentExports);

  DataCenterSummaryResponseData recentBackups(List<BackupJob> recentBackups);

  DataCenterSummaryResponseData usage(List<UsageMetric> usage);

  DataCenterSummaryResponseData usageStatus(
    DataCenterSummaryResponseDataUsageStatusEnum usageStatus,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCenterSummaryResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCenterSummaryResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCenterSummaryResponseData call({
    List<ImportJob> recentImports,
    List<ExportJob> recentExports,
    List<BackupJob> recentBackups,
    List<UsageMetric> usage,
    DataCenterSummaryResponseDataUsageStatusEnum usageStatus,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDataCenterSummaryResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDataCenterSummaryResponseData.copyWith.fieldName(...)`
class _$DataCenterSummaryResponseDataCWProxyImpl
    implements _$DataCenterSummaryResponseDataCWProxy {
  const _$DataCenterSummaryResponseDataCWProxyImpl(this._value);

  final DataCenterSummaryResponseData _value;

  @override
  DataCenterSummaryResponseData recentImports(List<ImportJob> recentImports) =>
      this(recentImports: recentImports);

  @override
  DataCenterSummaryResponseData recentExports(List<ExportJob> recentExports) =>
      this(recentExports: recentExports);

  @override
  DataCenterSummaryResponseData recentBackups(List<BackupJob> recentBackups) =>
      this(recentBackups: recentBackups);

  @override
  DataCenterSummaryResponseData usage(List<UsageMetric> usage) =>
      this(usage: usage);

  @override
  DataCenterSummaryResponseData usageStatus(
    DataCenterSummaryResponseDataUsageStatusEnum usageStatus,
  ) => this(usageStatus: usageStatus);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DataCenterSummaryResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DataCenterSummaryResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  DataCenterSummaryResponseData call({
    Object? recentImports = const $CopyWithPlaceholder(),
    Object? recentExports = const $CopyWithPlaceholder(),
    Object? recentBackups = const $CopyWithPlaceholder(),
    Object? usage = const $CopyWithPlaceholder(),
    Object? usageStatus = const $CopyWithPlaceholder(),
  }) {
    return DataCenterSummaryResponseData(
      recentImports: recentImports == const $CopyWithPlaceholder()
          ? _value.recentImports
          // ignore: cast_nullable_to_non_nullable
          : recentImports as List<ImportJob>,
      recentExports: recentExports == const $CopyWithPlaceholder()
          ? _value.recentExports
          // ignore: cast_nullable_to_non_nullable
          : recentExports as List<ExportJob>,
      recentBackups: recentBackups == const $CopyWithPlaceholder()
          ? _value.recentBackups
          // ignore: cast_nullable_to_non_nullable
          : recentBackups as List<BackupJob>,
      usage: usage == const $CopyWithPlaceholder()
          ? _value.usage
          // ignore: cast_nullable_to_non_nullable
          : usage as List<UsageMetric>,
      usageStatus: usageStatus == const $CopyWithPlaceholder()
          ? _value.usageStatus
          // ignore: cast_nullable_to_non_nullable
          : usageStatus as DataCenterSummaryResponseDataUsageStatusEnum,
    );
  }
}

extension $DataCenterSummaryResponseDataCopyWith
    on DataCenterSummaryResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfDataCenterSummaryResponseData.copyWith(...)` or like so:`instanceOfDataCenterSummaryResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DataCenterSummaryResponseDataCWProxy get copyWith =>
      _$DataCenterSummaryResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCenterSummaryResponseData _$DataCenterSummaryResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'DataCenterSummaryResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'recent_imports',
        'recent_exports',
        'recent_backups',
        'usage',
        'usage_status',
      ],
    );
    final val = DataCenterSummaryResponseData(
      recentImports: $checkedConvert(
        'recent_imports',
        (v) => (v as List<dynamic>)
            .map((e) => ImportJob.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      recentExports: $checkedConvert(
        'recent_exports',
        (v) => (v as List<dynamic>)
            .map((e) => ExportJob.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      recentBackups: $checkedConvert(
        'recent_backups',
        (v) => (v as List<dynamic>)
            .map((e) => BackupJob.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      usage: $checkedConvert(
        'usage',
        (v) => (v as List<dynamic>)
            .map((e) => UsageMetric.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      usageStatus: $checkedConvert(
        'usage_status',
        (v) => $enumDecode(
          _$DataCenterSummaryResponseDataUsageStatusEnumEnumMap,
          v,
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'recentImports': 'recent_imports',
    'recentExports': 'recent_exports',
    'recentBackups': 'recent_backups',
    'usageStatus': 'usage_status',
  },
);

Map<String, dynamic> _$DataCenterSummaryResponseDataToJson(
  DataCenterSummaryResponseData instance,
) => <String, dynamic>{
  'recent_imports': instance.recentImports.map((e) => e.toJson()).toList(),
  'recent_exports': instance.recentExports.map((e) => e.toJson()).toList(),
  'recent_backups': instance.recentBackups.map((e) => e.toJson()).toList(),
  'usage': instance.usage.map((e) => e.toJson()).toList(),
  'usage_status':
      _$DataCenterSummaryResponseDataUsageStatusEnumEnumMap[instance
          .usageStatus]!,
};

const _$DataCenterSummaryResponseDataUsageStatusEnumEnumMap = {
  DataCenterSummaryResponseDataUsageStatusEnum.current: 'current',
  DataCenterSummaryResponseDataUsageStatusEnum.updating: 'updating',
  DataCenterSummaryResponseDataUsageStatusEnum.delayed: 'delayed',
};
