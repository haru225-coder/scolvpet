// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revoke_share_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RevokeShareRequestCWProxy {
  RevokeShareRequest reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevokeShareRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevokeShareRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RevokeShareRequest call({String reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRevokeShareRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRevokeShareRequest.copyWith.fieldName(...)`
class _$RevokeShareRequestCWProxyImpl implements _$RevokeShareRequestCWProxy {
  const _$RevokeShareRequestCWProxyImpl(this._value);

  final RevokeShareRequest _value;

  @override
  RevokeShareRequest reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevokeShareRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevokeShareRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RevokeShareRequest call({Object? reason = const $CopyWithPlaceholder()}) {
    return RevokeShareRequest(
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $RevokeShareRequestCopyWith on RevokeShareRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRevokeShareRequest.copyWith(...)` or like so:`instanceOfRevokeShareRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RevokeShareRequestCWProxy get copyWith =>
      _$RevokeShareRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevokeShareRequest _$RevokeShareRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RevokeShareRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['reason']);
      final val = RevokeShareRequest(
        reason: $checkedConvert('reason', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$RevokeShareRequestToJson(RevokeShareRequest instance) =>
    <String, dynamic>{'reason': instance.reason};
