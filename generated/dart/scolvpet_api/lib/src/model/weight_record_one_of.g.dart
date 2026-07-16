// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_record_one_of.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WeightRecordOneOfCWProxy {
  WeightRecordOneOf pupIdentityId(Object? pupIdentityId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordOneOf(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordOneOf(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordOneOf call({Object? pupIdentityId});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWeightRecordOneOf.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWeightRecordOneOf.copyWith.fieldName(...)`
class _$WeightRecordOneOfCWProxyImpl implements _$WeightRecordOneOfCWProxy {
  const _$WeightRecordOneOfCWProxyImpl(this._value);

  final WeightRecordOneOf _value;

  @override
  WeightRecordOneOf pupIdentityId(Object? pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WeightRecordOneOf(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WeightRecordOneOf(...).copyWith(id: 12, name: "My name")
  /// ````
  WeightRecordOneOf call({
    Object? pupIdentityId = const $CopyWithPlaceholder(),
  }) {
    return WeightRecordOneOf(
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as Object?,
    );
  }
}

extension $WeightRecordOneOfCopyWith on WeightRecordOneOf {
  /// Returns a callable class that can be used as follows: `instanceOfWeightRecordOneOf.copyWith(...)` or like so:`instanceOfWeightRecordOneOf.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WeightRecordOneOfCWProxy get copyWith =>
      _$WeightRecordOneOfCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeightRecordOneOf _$WeightRecordOneOfFromJson(Map<String, dynamic> json) =>
    $checkedCreate('WeightRecordOneOf', json, ($checkedConvert) {
      final val = WeightRecordOneOf(
        pupIdentityId: $checkedConvert('pup_identity_id', (v) => v),
      );
      return val;
    }, fieldKeyMap: const {'pupIdentityId': 'pup_identity_id'});

Map<String, dynamic> _$WeightRecordOneOfToJson(WeightRecordOneOf instance) =>
    <String, dynamic>{'pup_identity_id': ?instance.pupIdentityId};
