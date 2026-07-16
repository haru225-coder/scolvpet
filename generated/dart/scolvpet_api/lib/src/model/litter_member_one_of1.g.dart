// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_member_one_of1.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterMemberOneOf1CWProxy {
  LitterMemberOneOf1 memberType(Object? memberType);

  LitterMemberOneOf1 pupIdentityId(Object? pupIdentityId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterMemberOneOf1(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterMemberOneOf1(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterMemberOneOf1 call({Object? memberType, Object? pupIdentityId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterMemberOneOf1.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterMemberOneOf1.copyWith.fieldName(...)`
class _$LitterMemberOneOf1CWProxyImpl implements _$LitterMemberOneOf1CWProxy {
  const _$LitterMemberOneOf1CWProxyImpl(this._value);

  final LitterMemberOneOf1 _value;

  @override
  LitterMemberOneOf1 memberType(Object? memberType) =>
      this(memberType: memberType);

  @override
  LitterMemberOneOf1 pupIdentityId(Object? pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterMemberOneOf1(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterMemberOneOf1(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterMemberOneOf1 call({
    Object? memberType = const $CopyWithPlaceholder(),
    Object? pupIdentityId = const $CopyWithPlaceholder(),
  }) {
    return LitterMemberOneOf1(
      memberType: memberType == const $CopyWithPlaceholder()
          ? _value.memberType
          // ignore: cast_nullable_to_non_nullable
          : memberType as Object?,
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as Object?,
    );
  }
}

extension $LitterMemberOneOf1CopyWith on LitterMemberOneOf1 {
  /// Returns a callable class that can be used as follows: `instanceOfLitterMemberOneOf1.copyWith(...)` or like so:`instanceOfLitterMemberOneOf1.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterMemberOneOf1CWProxy get copyWith =>
      _$LitterMemberOneOf1CWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterMemberOneOf1 _$LitterMemberOneOf1FromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LitterMemberOneOf1',
      json,
      ($checkedConvert) {
        final val = LitterMemberOneOf1(
          memberType: $checkedConvert('member_type', (v) => v),
          pupIdentityId: $checkedConvert('pup_identity_id', (v) => v),
        );
        return val;
      },
      fieldKeyMap: const {
        'memberType': 'member_type',
        'pupIdentityId': 'pup_identity_id',
      },
    );

Map<String, dynamic> _$LitterMemberOneOf1ToJson(LitterMemberOneOf1 instance) =>
    <String, dynamic>{
      'member_type': ?instance.memberType,
      'pup_identity_id': ?instance.pupIdentityId,
    };
