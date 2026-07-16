// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_job_list_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BackupJobListResponseCWProxy {
  BackupJobListResponse data(List<BackupJob> data);

  BackupJobListResponse page(PageInfo page);

  BackupJobListResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackupJobListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackupJobListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BackupJobListResponse call({
    List<BackupJob> data,
    PageInfo page,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBackupJobListResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBackupJobListResponse.copyWith.fieldName(...)`
class _$BackupJobListResponseCWProxyImpl
    implements _$BackupJobListResponseCWProxy {
  const _$BackupJobListResponseCWProxyImpl(this._value);

  final BackupJobListResponse _value;

  @override
  BackupJobListResponse data(List<BackupJob> data) => this(data: data);

  @override
  BackupJobListResponse page(PageInfo page) => this(page: page);

  @override
  BackupJobListResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackupJobListResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackupJobListResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  BackupJobListResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return BackupJobListResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<BackupJob>,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as PageInfo,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $BackupJobListResponseCopyWith on BackupJobListResponse {
  /// Returns a callable class that can be used as follows: `instanceOfBackupJobListResponse.copyWith(...)` or like so:`instanceOfBackupJobListResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BackupJobListResponseCWProxy get copyWith =>
      _$BackupJobListResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupJobListResponse _$BackupJobListResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BackupJobListResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'page', 'meta']);
  final val = BackupJobListResponse(
    data: $checkedConvert(
      'data',
      (v) => (v as List<dynamic>)
          .map((e) => BackupJob.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    page: $checkedConvert(
      'page',
      (v) => PageInfo.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$BackupJobListResponseToJson(
  BackupJobListResponse instance,
) => <String, dynamic>{
  'data': instance.data.map((e) => e.toJson()).toList(),
  'page': instance.page.toJson(),
  'meta': instance.meta.toJson(),
};
