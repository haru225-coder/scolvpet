// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'litter_member_one_of.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LitterMemberOneOfCWProxy {
  LitterMemberOneOf memberType(Object? memberType);

  LitterMemberOneOf hamsterId(Object? hamsterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterMemberOneOf(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterMemberOneOf(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterMemberOneOf call({Object? memberType, Object? hamsterId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLitterMemberOneOf.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLitterMemberOneOf.copyWith.fieldName(...)`
class _$LitterMemberOneOfCWProxyImpl implements _$LitterMemberOneOfCWProxy {
  const _$LitterMemberOneOfCWProxyImpl(this._value);

  final LitterMemberOneOf _value;

  @override
  LitterMemberOneOf memberType(Object? memberType) =>
      this(memberType: memberType);

  @override
  LitterMemberOneOf hamsterId(Object? hamsterId) => this(hamsterId: hamsterId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LitterMemberOneOf(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LitterMemberOneOf(...).copyWith(id: 12, name: "My name")
  /// ````
  LitterMemberOneOf call({
    Object? memberType = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
  }) {
    return LitterMemberOneOf(
      memberType: memberType == const $CopyWithPlaceholder()
          ? _value.memberType
          // ignore: cast_nullable_to_non_nullable
          : memberType as Object?,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as Object?,
    );
  }
}

extension $LitterMemberOneOfCopyWith on LitterMemberOneOf {
  /// Returns a callable class that can be used as follows: `instanceOfLitterMemberOneOf.copyWith(...)` or like so:`instanceOfLitterMemberOneOf.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LitterMemberOneOfCWProxy get copyWith =>
      _$LitterMemberOneOfCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LitterMemberOneOf _$LitterMemberOneOfFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LitterMemberOneOf',
      json,
      ($checkedConvert) {
        final val = LitterMemberOneOf(
          memberType: $checkedConvert('member_type', (v) => v),
          hamsterId: $checkedConvert('hamster_id', (v) => v),
        );
        return val;
      },
      fieldKeyMap: const {
        'memberType': 'member_type',
        'hamsterId': 'hamster_id',
      },
    );

Map<String, dynamic> _$LitterMemberOneOfToJson(LitterMemberOneOf instance) =>
    <String, dynamic>{
      'member_type': ?instance.memberType,
      'hamster_id': ?instance.hamsterId,
    };
