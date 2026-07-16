// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individualize_mapping.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndividualizeMappingCWProxy {
  IndividualizeMapping pupIdentityId(String pupIdentityId);

  IndividualizeMapping hamster(Hamster hamster);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeMapping(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeMapping(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeMapping call({String pupIdentityId, Hamster hamster});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndividualizeMapping.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndividualizeMapping.copyWith.fieldName(...)`
class _$IndividualizeMappingCWProxyImpl
    implements _$IndividualizeMappingCWProxy {
  const _$IndividualizeMappingCWProxyImpl(this._value);

  final IndividualizeMapping _value;

  @override
  IndividualizeMapping pupIdentityId(String pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  IndividualizeMapping hamster(Hamster hamster) => this(hamster: hamster);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeMapping(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeMapping(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeMapping call({
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? hamster = const $CopyWithPlaceholder(),
  }) {
    return IndividualizeMapping(
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as String,
      hamster: hamster == const $CopyWithPlaceholder()
          ? _value.hamster
          // ignore: cast_nullable_to_non_nullable
          : hamster as Hamster,
    );
  }
}

extension $IndividualizeMappingCopyWith on IndividualizeMapping {
  /// Returns a callable class that can be used as follows: `instanceOfIndividualizeMapping.copyWith(...)` or like so:`instanceOfIndividualizeMapping.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndividualizeMappingCWProxy get copyWith =>
      _$IndividualizeMappingCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualizeMapping _$IndividualizeMappingFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'IndividualizeMapping',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['pup_identity_id', 'hamster']);
    final val = IndividualizeMapping(
      pupIdentityId: $checkedConvert('pup_identity_id', (v) => v as String),
      hamster: $checkedConvert(
        'hamster',
        (v) => Hamster.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'pupIdentityId': 'pup_identity_id'},
);

Map<String, dynamic> _$IndividualizeMappingToJson(
  IndividualizeMapping instance,
) => <String, dynamic>{
  'pup_identity_id': instance.pupIdentityId,
  'hamster': instance.hamster.toJson(),
};
