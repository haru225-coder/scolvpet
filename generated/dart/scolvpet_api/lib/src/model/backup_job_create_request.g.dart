// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_job_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BackupJobCreateRequestCWProxy {
  BackupJobCreateRequest includeMediaManifest(
    BackupJobCreateRequestIncludeMediaManifestEnum includeMediaManifest,
  );

  BackupJobCreateRequest includeChecksums(
    BackupJobCreateRequestIncludeChecksumsEnum includeChecksums,
  );

  BackupJobCreateRequest timezone(String timezone);

  BackupJobCreateRequest encryptionHint(String? encryptionHint);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackupJobCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackupJobCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BackupJobCreateRequest call({
    BackupJobCreateRequestIncludeMediaManifestEnum includeMediaManifest,
    BackupJobCreateRequestIncludeChecksumsEnum includeChecksums,
    String timezone,
    String? encryptionHint,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfBackupJobCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfBackupJobCreateRequest.copyWith.fieldName(...)`
class _$BackupJobCreateRequestCWProxyImpl
    implements _$BackupJobCreateRequestCWProxy {
  const _$BackupJobCreateRequestCWProxyImpl(this._value);

  final BackupJobCreateRequest _value;

  @override
  BackupJobCreateRequest includeMediaManifest(
    BackupJobCreateRequestIncludeMediaManifestEnum includeMediaManifest,
  ) => this(includeMediaManifest: includeMediaManifest);

  @override
  BackupJobCreateRequest includeChecksums(
    BackupJobCreateRequestIncludeChecksumsEnum includeChecksums,
  ) => this(includeChecksums: includeChecksums);

  @override
  BackupJobCreateRequest timezone(String timezone) => this(timezone: timezone);

  @override
  BackupJobCreateRequest encryptionHint(String? encryptionHint) =>
      this(encryptionHint: encryptionHint);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `BackupJobCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// BackupJobCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  BackupJobCreateRequest call({
    Object? includeMediaManifest = const $CopyWithPlaceholder(),
    Object? includeChecksums = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? encryptionHint = const $CopyWithPlaceholder(),
  }) {
    return BackupJobCreateRequest(
      includeMediaManifest: includeMediaManifest == const $CopyWithPlaceholder()
          ? _value.includeMediaManifest
          // ignore: cast_nullable_to_non_nullable
          : includeMediaManifest
                as BackupJobCreateRequestIncludeMediaManifestEnum,
      includeChecksums: includeChecksums == const $CopyWithPlaceholder()
          ? _value.includeChecksums
          // ignore: cast_nullable_to_non_nullable
          : includeChecksums as BackupJobCreateRequestIncludeChecksumsEnum,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      encryptionHint: encryptionHint == const $CopyWithPlaceholder()
          ? _value.encryptionHint
          // ignore: cast_nullable_to_non_nullable
          : encryptionHint as String?,
    );
  }
}

extension $BackupJobCreateRequestCopyWith on BackupJobCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfBackupJobCreateRequest.copyWith(...)` or like so:`instanceOfBackupJobCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BackupJobCreateRequestCWProxy get copyWith =>
      _$BackupJobCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackupJobCreateRequest _$BackupJobCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'BackupJobCreateRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'include_media_manifest',
        'include_checksums',
        'timezone',
      ],
    );
    final val = BackupJobCreateRequest(
      includeMediaManifest: $checkedConvert(
        'include_media_manifest',
        (v) => $enumDecode(
          _$BackupJobCreateRequestIncludeMediaManifestEnumEnumMap,
          v,
        ),
      ),
      includeChecksums: $checkedConvert(
        'include_checksums',
        (v) =>
            $enumDecode(_$BackupJobCreateRequestIncludeChecksumsEnumEnumMap, v),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String),
      encryptionHint: $checkedConvert('encryption_hint', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'includeMediaManifest': 'include_media_manifest',
    'includeChecksums': 'include_checksums',
    'encryptionHint': 'encryption_hint',
  },
);

Map<String, dynamic> _$BackupJobCreateRequestToJson(
  BackupJobCreateRequest instance,
) => <String, dynamic>{
  'include_media_manifest':
      _$BackupJobCreateRequestIncludeMediaManifestEnumEnumMap[instance
          .includeMediaManifest]!,
  'include_checksums':
      _$BackupJobCreateRequestIncludeChecksumsEnumEnumMap[instance
          .includeChecksums]!,
  'timezone': instance.timezone,
  'encryption_hint': ?instance.encryptionHint,
};

const _$BackupJobCreateRequestIncludeMediaManifestEnumEnumMap = {
  BackupJobCreateRequestIncludeMediaManifestEnum.true_: 'true',
};

const _$BackupJobCreateRequestIncludeChecksumsEnumEnumMap = {
  BackupJobCreateRequestIncludeChecksumsEnum.true_: 'true',
};
