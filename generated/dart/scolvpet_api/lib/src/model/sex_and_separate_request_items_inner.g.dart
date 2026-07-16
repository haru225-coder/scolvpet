// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sex_and_separate_request_items_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SexAndSeparateRequestItemsInnerCWProxy {
  SexAndSeparateRequestItemsInner pupIdentityId(String pupIdentityId);

  SexAndSeparateRequestItemsInner sex(Sex sex);

  SexAndSeparateRequestItemsInner sexConfidence(num? sexConfidence);

  SexAndSeparateRequestItemsInner destinationEnclosureId(
    String destinationEnclosureId,
  );

  SexAndSeparateRequestItemsInner requiresRecheck(bool requiresRecheck);

  SexAndSeparateRequestItemsInner notes(String? notes);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SexAndSeparateRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SexAndSeparateRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  SexAndSeparateRequestItemsInner call({
    String pupIdentityId,
    Sex sex,
    num? sexConfidence,
    String destinationEnclosureId,
    bool requiresRecheck,
    String? notes,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSexAndSeparateRequestItemsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSexAndSeparateRequestItemsInner.copyWith.fieldName(...)`
class _$SexAndSeparateRequestItemsInnerCWProxyImpl
    implements _$SexAndSeparateRequestItemsInnerCWProxy {
  const _$SexAndSeparateRequestItemsInnerCWProxyImpl(this._value);

  final SexAndSeparateRequestItemsInner _value;

  @override
  SexAndSeparateRequestItemsInner pupIdentityId(String pupIdentityId) =>
      this(pupIdentityId: pupIdentityId);

  @override
  SexAndSeparateRequestItemsInner sex(Sex sex) => this(sex: sex);

  @override
  SexAndSeparateRequestItemsInner sexConfidence(num? sexConfidence) =>
      this(sexConfidence: sexConfidence);

  @override
  SexAndSeparateRequestItemsInner destinationEnclosureId(
    String destinationEnclosureId,
  ) => this(destinationEnclosureId: destinationEnclosureId);

  @override
  SexAndSeparateRequestItemsInner requiresRecheck(bool requiresRecheck) =>
      this(requiresRecheck: requiresRecheck);

  @override
  SexAndSeparateRequestItemsInner notes(String? notes) => this(notes: notes);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SexAndSeparateRequestItemsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SexAndSeparateRequestItemsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  SexAndSeparateRequestItemsInner call({
    Object? pupIdentityId = const $CopyWithPlaceholder(),
    Object? sex = const $CopyWithPlaceholder(),
    Object? sexConfidence = const $CopyWithPlaceholder(),
    Object? destinationEnclosureId = const $CopyWithPlaceholder(),
    Object? requiresRecheck = const $CopyWithPlaceholder(),
    Object? notes = const $CopyWithPlaceholder(),
  }) {
    return SexAndSeparateRequestItemsInner(
      pupIdentityId: pupIdentityId == const $CopyWithPlaceholder()
          ? _value.pupIdentityId
          // ignore: cast_nullable_to_non_nullable
          : pupIdentityId as String,
      sex: sex == const $CopyWithPlaceholder()
          ? _value.sex
          // ignore: cast_nullable_to_non_nullable
          : sex as Sex,
      sexConfidence: sexConfidence == const $CopyWithPlaceholder()
          ? _value.sexConfidence
          // ignore: cast_nullable_to_non_nullable
          : sexConfidence as num?,
      destinationEnclosureId:
          destinationEnclosureId == const $CopyWithPlaceholder()
          ? _value.destinationEnclosureId
          // ignore: cast_nullable_to_non_nullable
          : destinationEnclosureId as String,
      requiresRecheck: requiresRecheck == const $CopyWithPlaceholder()
          ? _value.requiresRecheck
          // ignore: cast_nullable_to_non_nullable
          : requiresRecheck as bool,
      notes: notes == const $CopyWithPlaceholder()
          ? _value.notes
          // ignore: cast_nullable_to_non_nullable
          : notes as String?,
    );
  }
}

extension $SexAndSeparateRequestItemsInnerCopyWith
    on SexAndSeparateRequestItemsInner {
  /// Returns a callable class that can be used as follows: `instanceOfSexAndSeparateRequestItemsInner.copyWith(...)` or like so:`instanceOfSexAndSeparateRequestItemsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SexAndSeparateRequestItemsInnerCWProxy get copyWith =>
      _$SexAndSeparateRequestItemsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SexAndSeparateRequestItemsInner _$SexAndSeparateRequestItemsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SexAndSeparateRequestItemsInner',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'pup_identity_id',
        'sex',
        'destination_enclosure_id',
        'requires_recheck',
      ],
    );
    final val = SexAndSeparateRequestItemsInner(
      pupIdentityId: $checkedConvert('pup_identity_id', (v) => v as String),
      sex: $checkedConvert('sex', (v) => $enumDecode(_$SexEnumMap, v)),
      sexConfidence: $checkedConvert('sex_confidence', (v) => v as num?),
      destinationEnclosureId: $checkedConvert(
        'destination_enclosure_id',
        (v) => v as String,
      ),
      requiresRecheck: $checkedConvert('requires_recheck', (v) => v as bool),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'pupIdentityId': 'pup_identity_id',
    'sexConfidence': 'sex_confidence',
    'destinationEnclosureId': 'destination_enclosure_id',
    'requiresRecheck': 'requires_recheck',
  },
);

Map<String, dynamic> _$SexAndSeparateRequestItemsInnerToJson(
  SexAndSeparateRequestItemsInner instance,
) => <String, dynamic>{
  'pup_identity_id': instance.pupIdentityId,
  'sex': _$SexEnumMap[instance.sex]!,
  'sex_confidence': ?instance.sexConfidence,
  'destination_enclosure_id': instance.destinationEnclosureId,
  'requires_recheck': instance.requiresRecheck,
  'notes': ?instance.notes,
};

const _$SexEnumMap = {
  Sex.male: 'male',
  Sex.female: 'female',
  Sex.unknown: 'unknown',
};
