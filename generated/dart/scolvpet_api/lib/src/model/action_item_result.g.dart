// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_item_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ActionItemResultCWProxy {
  ActionItemResult pupIdentityId(String pupIdentityId);

  ActionItemResult status(BatchItemStatus status);

  ActionItemResult enclosureStayId(String? enclosureStayId);

  ActionItemResult error(ErrorObject? error);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionItemResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionItemResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionItemResult call({
    String pupIdentityId,
    BatchItemStatus status,
    String? enclosureStayId,
    ErrorObject? error,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfActionItemResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfActionItemResult.copyWith.fieldName(...)`
class _$ActionItemResultCWProxyImpl implements _$ActionItemResultCWProxy {
  const _$ActionItemResultCWProxyImpl(this._value);

  final ActionItemResult _value;

  @override
  ActionItemResult pupIdentityId(String pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  ActionItemResult status(BatchItemStatus status) => this(status: status);

  @override
  ActionItemResult enclosureStayId(String? enclosureStayId) =>
      this(enclosureStayId: enclosureStayId);

  @override
  ActionItemResult error(ErrorObject? error) => this(error: error);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ActionItemResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ActionItemResult(...).copyWith(id: 12, name: "My name")
  /// ````
  ActionItemResult call({
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? enclosureStayId = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return ActionItemResult(
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as BatchItemStatus,
      enclosureStayId: enclosureStayId == const $CopyWithPlaceholder()
          ? _value.enclosureStayId
          // ignore: cast_nullable_to_non_nullable
          : enclosureStayId as String?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as ErrorObject?,
    );
  }
}

extension $ActionItemResultCopyWith on ActionItemResult {
  /// Returns a callable class that can be used as follows: `instanceOfActionItemResult.copyWith(...)` or like so:`instanceOfActionItemResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ActionItemResultCWProxy get copyWith => _$ActionItemResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActionItemResult _$ActionItemResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ActionItemResult',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['pup_identity_id', 'status']);
        final val = ActionItemResult(
          pupIdentityId: $checkedConvert('pup_identity_id', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$BatchItemStatusEnumMap, v),
          ),
          enclosureStayId: $checkedConvert(
            'enclosure_stay_id',
            (v) => v as String?,
          ),
          error: $checkedConvert(
            'error',
            (v) => v == null
                ? null
                : ErrorObject.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'pupIdentityId': 'pup_identity_id',
        'enclosureStayId': 'enclosure_stay_id',
      },
    );

Map<String, dynamic> _$ActionItemResultToJson(ActionItemResult instance) =>
    <String, dynamic>{
      'pup_identity_id': instance.pupIdentityId,
      'status': _$BatchItemStatusEnumMap[instance.status]!,
      'enclosure_stay_id': ?instance.enclosureStayId,
      'error': ?instance.error?.toJson(),
    };

const _$BatchItemStatusEnumMap = {
  BatchItemStatus.succeeded: 'succeeded',
  BatchItemStatus.failed: 'failed',
  BatchItemStatus.skipped: 'skipped',
  BatchItemStatus.succeededWithWarning: 'succeeded_with_warning',
  BatchItemStatus.succeededWithException: 'succeeded_with_exception',
};
