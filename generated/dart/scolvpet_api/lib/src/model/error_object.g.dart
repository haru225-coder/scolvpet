// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_object.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ErrorObjectCWProxy {
  ErrorObject code(String code);

  ErrorObject message(String message);

  ErrorObject fieldErrors(List<FieldError> fieldErrors);

  ErrorObject currentVersion(int? currentVersion);

  ErrorObject recoveryActions(List<RecoveryAction> recoveryActions);

  ErrorObject details(Map<String, Object>? details);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ErrorObject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ErrorObject(...).copyWith(id: 12, name: "My name")
  /// ````
  ErrorObject call({
    String code,
    String message,
    List<FieldError> fieldErrors,
    int? currentVersion,
    List<RecoveryAction> recoveryActions,
    Map<String, Object>? details,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfErrorObject.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfErrorObject.copyWith.fieldName(...)`
class _$ErrorObjectCWProxyImpl implements _$ErrorObjectCWProxy {
  const _$ErrorObjectCWProxyImpl(this._value);

  final ErrorObject _value;

  @override
  ErrorObject code(String code) => this(code: code);

  @override
  ErrorObject message(String message) => this(message: message);

  @override
  ErrorObject fieldErrors(List<FieldError> fieldErrors) =>
      this(fieldErrors: fieldErrors);

  @override
  ErrorObject currentVersion(int? currentVersion) =>
      this(currentVersion: currentVersion);

  @override
  ErrorObject recoveryActions(List<RecoveryAction> recoveryActions) =>
      this(recoveryActions: recoveryActions);

  @override
  ErrorObject details(Map<String, Object>? details) => this(details: details);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ErrorObject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ErrorObject(...).copyWith(id: 12, name: "My name")
  /// ````
  ErrorObject call({
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? fieldErrors = const $CopyWithPlaceholder(),
    Object? currentVersion = const $CopyWithPlaceholder(),
    Object? recoveryActions = const $CopyWithPlaceholder(),
    Object? details = const $CopyWithPlaceholder(),
  }) {
    return ErrorObject(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      fieldErrors: fieldErrors == const $CopyWithPlaceholder()
          ? _value.fieldErrors
          // ignore: cast_nullable_to_non_nullable
          : fieldErrors as List<FieldError>,
      currentVersion: currentVersion == const $CopyWithPlaceholder()
          ? _value.currentVersion
          // ignore: cast_nullable_to_non_nullable
          : currentVersion as int?,
      recoveryActions: recoveryActions == const $CopyWithPlaceholder()
          ? _value.recoveryActions
          // ignore: cast_nullable_to_non_nullable
          : recoveryActions as List<RecoveryAction>,
      details: details == const $CopyWithPlaceholder()
          ? _value.details
          // ignore: cast_nullable_to_non_nullable
          : details as Map<String, Object>?,
    );
  }
}

extension $ErrorObjectCopyWith on ErrorObject {
  /// Returns a callable class that can be used as follows: `instanceOfErrorObject.copyWith(...)` or like so:`instanceOfErrorObject.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ErrorObjectCWProxy get copyWith => _$ErrorObjectCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorObject _$ErrorObjectFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ErrorObject',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'code',
        'message',
        'field_errors',
        'recovery_actions',
      ],
    );
    final val = ErrorObject(
      code: $checkedConvert('code', (v) => v as String),
      message: $checkedConvert('message', (v) => v as String),
      fieldErrors: $checkedConvert(
        'field_errors',
        (v) => (v as List<dynamic>)
            .map((e) => FieldError.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      currentVersion: $checkedConvert(
        'current_version',
        (v) => (v as num?)?.toInt(),
      ),
      recoveryActions: $checkedConvert(
        'recovery_actions',
        (v) => (v as List<dynamic>)
            .map((e) => RecoveryAction.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      details: $checkedConvert(
        'details',
        (v) => (v as Map<String, dynamic>?)?.map(
          (k, e) => MapEntry(k, e as Object),
        ),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'fieldErrors': 'field_errors',
    'currentVersion': 'current_version',
    'recoveryActions': 'recovery_actions',
  },
);

Map<String, dynamic> _$ErrorObjectToJson(
  ErrorObject instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'field_errors': instance.fieldErrors.map((e) => e.toJson()).toList(),
  'current_version': ?instance.currentVersion,
  'recovery_actions': instance.recoveryActions.map((e) => e.toJson()).toList(),
  'details': ?instance.details,
};
