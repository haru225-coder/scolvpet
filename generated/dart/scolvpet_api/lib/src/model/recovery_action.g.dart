// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovery_action.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RecoveryActionCWProxy {
  RecoveryAction action(String action);

  RecoveryAction label(String label);

  RecoveryAction method(RecoveryActionMethodEnum method);

  RecoveryAction path(String path);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecoveryAction(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecoveryAction(...).copyWith(id: 12, name: "My name")
  /// ````
  RecoveryAction call({
    String action,
    String label,
    RecoveryActionMethodEnum method,
    String path,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRecoveryAction.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRecoveryAction.copyWith.fieldName(...)`
class _$RecoveryActionCWProxyImpl implements _$RecoveryActionCWProxy {
  const _$RecoveryActionCWProxyImpl(this._value);

  final RecoveryAction _value;

  @override
  RecoveryAction action(String action) => this(action: action);

  @override
  RecoveryAction label(String label) => this(label: label);

  @override
  RecoveryAction method(RecoveryActionMethodEnum method) =>
      this(method: method);

  @override
  RecoveryAction path(String path) => this(path: path);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RecoveryAction(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RecoveryAction(...).copyWith(id: 12, name: "My name")
  /// ````
  RecoveryAction call({
    Object? action = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
  }) {
    return RecoveryAction(
      action: action == const $CopyWithPlaceholder()
          ? _value.action
          // ignore: cast_nullable_to_non_nullable
          : action as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as RecoveryActionMethodEnum,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
    );
  }
}

extension $RecoveryActionCopyWith on RecoveryAction {
  /// Returns a callable class that can be used as follows: `instanceOfRecoveryAction.copyWith(...)` or like so:`instanceOfRecoveryAction.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RecoveryActionCWProxy get copyWith => _$RecoveryActionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecoveryAction _$RecoveryActionFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RecoveryAction', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['action', 'label', 'method', 'path'],
      );
      final val = RecoveryAction(
        action: $checkedConvert('action', (v) => v as String),
        label: $checkedConvert('label', (v) => v as String),
        method: $checkedConvert(
          'method',
          (v) => $enumDecode(_$RecoveryActionMethodEnumEnumMap, v),
        ),
        path: $checkedConvert('path', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RecoveryActionToJson(RecoveryAction instance) =>
    <String, dynamic>{
      'action': instance.action,
      'label': instance.label,
      'method': _$RecoveryActionMethodEnumEnumMap[instance.method]!,
      'path': instance.path,
    };

const _$RecoveryActionMethodEnumEnumMap = {
  RecoveryActionMethodEnum.GET: 'GET',
  RecoveryActionMethodEnum.POST: 'POST',
  RecoveryActionMethodEnum.PUT: 'PUT',
  RecoveryActionMethodEnum.PATCH: 'PATCH',
  RecoveryActionMethodEnum.DELETE: 'DELETE',
};
