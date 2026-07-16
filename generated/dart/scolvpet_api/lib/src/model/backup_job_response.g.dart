// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_job_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BackupJobResponseCWProxy {
  BackupJobResponse data(BackupJob data);

  BackupJobResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackupJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackupJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BackupJobResponse call({BackupJob data, ResponseMeta meta});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBackupJobResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBackupJobResponse.copyWith.fieldName(...)`
class _$BackupJobResponseCWProxyImpl implements _$BackupJobResponseCWProxy {
  const _$BackupJobResponseCWProxyImpl(this._value);

  final BackupJobResponse _value;

  @override
  BackupJobResponse data(BackupJob data) => this(data: data);

  @override
  BackupJobResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackupJobResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackupJobResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BackupJobResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return BackupJobResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as BackupJob,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $BackupJobResponseCopyWith on BackupJobResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBackupJobResponse.copyWith(...)` or like so:`instanceOfBackupJobResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BackupJobResponseCWProxy get copyWith =>
      _$BackupJobResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupJobResponse _$BackupJobResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BackupJobResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['data', 'meta']);
      final val = BackupJobResponse(
        data: $checkedConvert(
          'data',
          (v) => BackupJob.fromJson(v as Map<String, dynamic>),
        ),
        meta: $checkedConvert(
          'meta',
          (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$BackupJobResponseToJson(BackupJobResponse instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'meta': instance.meta.toJson(),
    };
