// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individualize_litter_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndividualizeLitterResponseDataCWProxy {
  IndividualizeLitterResponseData litterId(String litterId);

  IndividualizeLitterResponseData evaluatedEligibleSetToken(
    String evaluatedEligibleSetToken,
  );

  IndividualizeLitterResponseData evaluatedEligibleCount(
    int evaluatedEligibleCount,
  );

  IndividualizeLitterResponseData mappings(List<IndividualizeMapping> mappings);

  IndividualizeLitterResponseData createdLitterMemberCount(
    int createdLitterMemberCount,
  );

  IndividualizeLitterResponseData createdParentageCount(
    int createdParentageCount,
  );

  IndividualizeLitterResponseData reconciliation(Reconciliation reconciliation);

  IndividualizeLitterResponseData litterVersion(int litterVersion);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeLitterResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeLitterResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeLitterResponseData call({
    String litterId,
    String evaluatedEligibleSetToken,
    int evaluatedEligibleCount,
    List<IndividualizeMapping> mappings,
    int createdLitterMemberCount,
    int createdParentageCount,
    Reconciliation reconciliation,
    int litterVersion,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndividualizeLitterResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndividualizeLitterResponseData.copyWith.fieldName(...)`
class _$IndividualizeLitterResponseDataCWProxyImpl
    implements _$IndividualizeLitterResponseDataCWProxy {
  const _$IndividualizeLitterResponseDataCWProxyImpl(this._value);

  final IndividualizeLitterResponseData _value;

  @override
  IndividualizeLitterResponseData litterId(String litterId) =>
      this(litterId: litterId);

  @override
  IndividualizeLitterResponseData evaluatedEligibleSetToken(
    String evaluatedEligibleSetToken,
  ) => this(evaluatedEligibleSetToken: evaluatedEligibleSetToken);

  @override
  IndividualizeLitterResponseData evaluatedEligibleCount(
    int evaluatedEligibleCount,
  ) => this(evaluatedEligibleCount: evaluatedEligibleCount);

  @override
  IndividualizeLitterResponseData mappings(
    List<IndividualizeMapping> mappings,
  ) => this(mappings: mappings);

  @override
  IndividualizeLitterResponseData createdLitterMemberCount(
    int createdLitterMemberCount,
  ) => this(createdLitterMemberCount: createdLitterMemberCount);

  @override
  IndividualizeLitterResponseData createdParentageCount(
    int createdParentageCount,
  ) => this(createdParentageCount: createdParentageCount);

  @override
  IndividualizeLitterResponseData reconciliation(
    Reconciliation reconciliation,
  ) => this(reconciliation: reconciliation);

  @override
  IndividualizeLitterResponseData litterVersion(int litterVersion) =>
      this(litterVersion: litterVersion);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeLitterResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeLitterResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeLitterResponseData call({
    Object? litterId = const $CopyWithPlaceholder(),
    Object? evaluatedEligibleSetToken = const $CopyWithPlaceholder(),
    Object? evaluatedEligibleCount = const $CopyWithPlaceholder(),
    Object? mappings = const $CopyWithPlaceholder(),
    Object? createdLitterMemberCount = const $CopyWithPlaceholder(),
    Object? createdParentageCount = const $CopyWithPlaceholder(),
    Object? reconciliation = const $CopyWithPlaceholder(),
    Object? litterVersion = const $CopyWithPlaceholder(),
  }) {
    return IndividualizeLitterResponseData(
      litterId: litterId == const $CopyWithPlaceholder()
          ? _value.litterId
          // ignore: cast_nullable_to_non_nullable
          : litterId as String,
      evaluatedEligibleSetToken:
          evaluatedEligibleSetToken == const $CopyWithPlaceholder()
          ? _value.evaluatedEligibleSetToken
          // ignore: cast_nullable_to_non_nullable
          : evaluatedEligibleSetToken as String,
      evaluatedEligibleCount:
          evaluatedEligibleCount == const $CopyWithPlaceholder()
          ? _value.evaluatedEligibleCount
          // ignore: cast_nullable_to_non_nullable
          : evaluatedEligibleCount as int,
      mappings: mappings == const $CopyWithPlaceholder()
          ? _value.mappings
          // ignore: cast_nullable_to_non_nullable
          : mappings as List<IndividualizeMapping>,
      createdLitterMemberCount:
          createdLitterMemberCount == const $CopyWithPlaceholder()
          ? _value.createdLitterMemberCount
          // ignore: cast_nullable_to_non_nullable
          : createdLitterMemberCount as int,
      createdParentageCount:
          createdParentageCount == const $CopyWithPlaceholder()
          ? _value.createdParentageCount
          // ignore: cast_nullable_to_non_nullable
          : createdParentageCount as int,
      reconciliation: reconciliation == const $CopyWithPlaceholder()
          ? _value.reconciliation
          // ignore: cast_nullable_to_non_nullable
          : reconciliation as Reconciliation,
      litterVersion: litterVersion == const $CopyWithPlaceholder()
          ? _value.litterVersion
          // ignore: cast_nullable_to_non_nullable
          : litterVersion as int,
    );
  }
}

extension $IndividualizeLitterResponseDataCopyWith
    on IndividualizeLitterResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfIndividualizeLitterResponseData.copyWith(...)` or like so:`instanceOfIndividualizeLitterResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndividualizeLitterResponseDataCWProxy get copyWith =>
      _$IndividualizeLitterResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualizeLitterResponseData _$IndividualizeLitterResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'IndividualizeLitterResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'litter_id',
        'evaluated_eligible_set_token',
        'evaluated_eligible_count',
        'mappings',
        'created_litter_member_count',
        'created_parentage_count',
        'reconciliation',
        'litter_version',
      ],
    );
    final val = IndividualizeLitterResponseData(
      litterId: $checkedConvert('litter_id', (v) => v as String),
      evaluatedEligibleSetToken: $checkedConvert(
        'evaluated_eligible_set_token',
        (v) => v as String,
      ),
      evaluatedEligibleCount: $checkedConvert(
        'evaluated_eligible_count',
        (v) => (v as num).toInt(),
      ),
      mappings: $checkedConvert(
        'mappings',
        (v) => (v as List<dynamic>)
            .map(
              (e) => IndividualizeMapping.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      ),
      createdLitterMemberCount: $checkedConvert(
        'created_litter_member_count',
        (v) => (v as num).toInt(),
      ),
      createdParentageCount: $checkedConvert(
        'created_parentage_count',
        (v) => (v as num).toInt(),
      ),
      reconciliation: $checkedConvert(
        'reconciliation',
        (v) => Reconciliation.fromJson(v as Map<String, dynamic>),
      ),
      litterVersion: $checkedConvert(
        'litter_version',
        (v) => (v as num).toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'litterId': 'litter_id',
    'evaluatedEligibleSetToken': 'evaluated_eligible_set_token',
    'evaluatedEligibleCount': 'evaluated_eligible_count',
    'createdLitterMemberCount': 'created_litter_member_count',
    'createdParentageCount': 'created_parentage_count',
    'litterVersion': 'litter_version',
  },
);

Map<String, dynamic> _$IndividualizeLitterResponseDataToJson(
  IndividualizeLitterResponseData instance,
) => <String, dynamic>{
  'litter_id': instance.litterId,
  'evaluated_eligible_set_token': instance.evaluatedEligibleSetToken,
  'evaluated_eligible_count': instance.evaluatedEligibleCount,
  'mappings': instance.mappings.map((e) => e.toJson()).toList(),
  'created_litter_member_count': instance.createdLitterMemberCount,
  'created_parentage_count': instance.createdParentageCount,
  'reconciliation': instance.reconciliation.toJson(),
  'litter_version': instance.litterVersion,
};
