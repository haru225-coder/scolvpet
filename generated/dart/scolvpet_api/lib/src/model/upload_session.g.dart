// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_session.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UploadSessionCWProxy {
  UploadSession id(String id);

  UploadSession uploadUrl(String uploadUrl);

  UploadSession method(UploadSessionMethodEnum method);

  UploadSession headers(Map<String, String> headers);

  UploadSession objectKey(String? objectKey);

  UploadSession expiresAt(DateTime expiresAt);

  UploadSession version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadSession(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadSession(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadSession call({
    String id,
    String uploadUrl,
    UploadSessionMethodEnum method,
    Map<String, String> headers,
    String? objectKey,
    DateTime expiresAt,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUploadSession.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUploadSession.copyWith.fieldName(...)`
class _$UploadSessionCWProxyImpl implements _$UploadSessionCWProxy {
  const _$UploadSessionCWProxyImpl(this._value);

  final UploadSession _value;

  @override
  UploadSession id(String id) => this(id: id);

  @override
  UploadSession uploadUrl(String uploadUrl) => this(uploadUrl: uploadUrl);

  @override
  UploadSession method(UploadSessionMethodEnum method) => this(method: method);

  @override
  UploadSession headers(Map<String, String> headers) => this(headers: headers);

  @override
  UploadSession objectKey(String? objectKey) => this(objectKey: objectKey);

  @override
  UploadSession expiresAt(DateTime expiresAt) => this(expiresAt: expiresAt);

  @override
  UploadSession version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UploadSession(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UploadSession(...).copyWith(id: 12, name: "My name")
  /// ````
  UploadSession call({
    Object? id = const $CopyWithPlaceholder(),
    Object? uploadUrl = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? headers = const $CopyWithPlaceholder(),
    Object? objectKey = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return UploadSession(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      uploadUrl: uploadUrl == const $CopyWithPlaceholder()
          ? _value.uploadUrl
          // ignore: cast_nullable_to_non_nullable
          : uploadUrl as String,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as UploadSessionMethodEnum,
      headers: headers == const $CopyWithPlaceholder()
          ? _value.headers
          // ignore: cast_nullable_to_non_nullable
          : headers as Map<String, String>,
      objectKey: objectKey == const $CopyWithPlaceholder()
          ? _value.objectKey
          // ignore: cast_nullable_to_non_nullable
          : objectKey as String?,
      expiresAt: expiresAt == const $CopyWithPlaceholder()
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $UploadSessionCopyWith on UploadSession {
  /// Returns a callable class that can be used as follows: `instanceOfUploadSession.copyWith(...)` or like so:`instanceOfUploadSession.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UploadSessionCWProxy get copyWith => _$UploadSessionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadSession _$UploadSessionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UploadSession',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'upload_url',
            'method',
            'headers',
            'expires_at',
            'version',
          ],
        );
        final val = UploadSession(
          id: $checkedConvert('id', (v) => v as String),
          uploadUrl: $checkedConvert('upload_url', (v) => v as String),
          method: $checkedConvert(
            'method',
            (v) => $enumDecode(_$UploadSessionMethodEnumEnumMap, v),
          ),
          headers: $checkedConvert(
            'headers',
            (v) => Map<String, String>.from(v as Map),
          ),
          objectKey: $checkedConvert('object_key', (v) => v as String?),
          expiresAt: $checkedConvert(
            'expires_at',
            (v) => DateTime.parse(v as String),
          ),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'uploadUrl': 'upload_url',
        'objectKey': 'object_key',
        'expiresAt': 'expires_at',
      },
    );

Map<String, dynamic> _$UploadSessionToJson(UploadSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'upload_url': instance.uploadUrl,
      'method': _$UploadSessionMethodEnumEnumMap[instance.method]!,
      'headers': instance.headers,
      'object_key': ?instance.objectKey,
      'expires_at': instance.expiresAt.toIso8601String(),
      'version': instance.version,
    };

const _$UploadSessionMethodEnumEnumMap = {UploadSessionMethodEnum.PUT: 'PUT'};
