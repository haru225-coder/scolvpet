// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individualization_eligibility_blocker.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndividualizationEligibilityBlockerCWProxy {
  IndividualizationEligibilityBlocker code(
    IndividualizationEligibilityBlockerCodeEnum code,
  );

  IndividualizationEligibilityBlocker message(String message);

  IndividualizationEligibilityBlocker pupIdentityIds(
    Set<String> pupIdentityIds,
  );

  IndividualizationEligibilityBlocker recoveryActions(
    List<RecoveryAction> recoveryActions,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizationEligibilityBlocker(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizationEligibilityBlocker(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizationEligibilityBlocker call({
    IndividualizationEligibilityBlockerCodeEnum code,
    String message,
    Set<String> pupIdentityIds,
    List<RecoveryAction> recoveryActions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndividualizationEligibilityBlocker.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndividualizationEligibilityBlocker.copyWith.fieldName(...)`
class _$IndividualizationEligibilityBlockerCWProxyImpl
    implements _$IndividualizationEligibilityBlockerCWProxy {
  const _$IndividualizationEligibilityBlockerCWProxyImpl(this._value);

  final IndividualizationEligibilityBlocker _value;

  @override
  IndividualizationEligibilityBlocker code(
    IndividualizationEligibilityBlockerCodeEnum code,
  ) => this(code: code);

  @override
  IndividualizationEligibilityBlocker message(String message) =>
      this(message: message);

  @override
  IndividualizationEligibilityBlocker pupIdentityIds(
    Set<String> pupIdentityIds,
  ) => this(pupIdentityIds: pupIdentityIds);

  @override
  IndividualizationEligibilityBlocker recoveryActions(
    List<RecoveryAction> recoveryActions,
  ) => this(recoveryActions: recoveryActions);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizationEligibilityBlocker(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizationEligibilityBlocker(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizationEligibilityBlocker call({
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? pupIdentityIds = const $CopyWithPlaceholder(),
    Object? recoveryActions = const $CopyWithPlaceholder(),
  }) {
    return IndividualizationEligibilityBlocker(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as IndividualizationEligibilityBlockerCodeEnum,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      pupIdentityIds: pupIdentityIds == const $CopyWithPlaceholder()
          ? _value.pupIdentityIds
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityIds as Set<String>,
      recoveryActions: recoveryActions == const $CopyWithPlaceholder()
          ? _value.recoveryActions
          // ignore: cast_nullable_to_non_nullable
          : recoveryActions as List<RecoveryAction>,
    );
  }
}

extension $IndividualizationEligibilityBlockerCopyWith
    on IndividualizationEligibilityBlocker {
  /// Returns a callable class that can be used as follows: `instanceOfIndividualizationEligibilityBlocker.copyWith(...)` or like so:`instanceOfIndividualizationEligibilityBlocker.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndividualizationEligibilityBlockerCWProxy get copyWith =>
      _$IndividualizationEligibilityBlockerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualizationEligibilityBlocker
_$IndividualizationEligibilityBlockerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'IndividualizationEligibilityBlocker',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'code',
            'message',
            'pup_identity_ids',
            'recovery_actions',
          ],
        );
        final val = IndividualizationEligibilityBlocker(
          code: $checkedConvert(
            'code',
            (v) => $enumDecode(
              _$IndividualizationEligibilityBlockerCodeEnumEnumMap,
              v,
            ),
          ),
          message: $checkedConvert('message', (v) => v as String),
          pupIdentityIds: $checkedConvert(
            'pup_identity_ids',
            (v) => (v as List<dynamic>).map((e) => e as String).toSet(),
          ),
          recoveryActions: $checkedConvert(
            'recovery_actions',
            (v) => (v as List<dynamic>)
                .map((e) => RecoveryAction.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'pupIdentityIds': 'pup_identity_ids',
        'recoveryActions': 'recovery_actions',
      },
    );

Map<String, dynamic> _$IndividualizationEligibilityBlockerToJson(
  IndividualizationEligibilityBlocker instance,
) => <String, dynamic>{
  'code': _$IndividualizationEligibilityBlockerCodeEnumEnumMap[instance.code]!,
  'message': instance.message,
  'pup_identity_ids': instance.pupIdentityIds.toList(),
  'recovery_actions': instance.recoveryActions.map((e) => e.toJson()).toList(),
};

const _$IndividualizationEligibilityBlockerCodeEnumEnumMap = {
  IndividualizationEligibilityBlockerCodeEnum.LITTER_STATE_NOT_READY:
      'LITTER_STATE_NOT_READY',
  IndividualizationEligibilityBlockerCodeEnum.COUNT_MISMATCH: 'COUNT_MISMATCH',
  IndividualizationEligibilityBlockerCodeEnum.PUP_NOT_WEANED: 'PUP_NOT_WEANED',
  IndividualizationEligibilityBlockerCodeEnum.SEX_RECHECK_REQUIRED:
      'SEX_RECHECK_REQUIRED',
  IndividualizationEligibilityBlockerCodeEnum.ENCLOSURE_REQUIRED:
      'ENCLOSURE_REQUIRED',
  IndividualizationEligibilityBlockerCodeEnum.ENCLOSURE_CONFLICT:
      'ENCLOSURE_CONFLICT',
  IndividualizationEligibilityBlockerCodeEnum.ALREADY_INDIVIDUALIZED:
      'ALREADY_INDIVIDUALIZED',
};
