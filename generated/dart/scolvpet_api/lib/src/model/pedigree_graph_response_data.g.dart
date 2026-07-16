// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedigree_graph_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PedigreeGraphResponseDataCWProxy {
  PedigreeGraphResponseData rootHamsterId(String rootHamsterId);

  PedigreeGraphResponseData nodes(List<Hamster> nodes);

  PedigreeGraphResponseData parentages(List<PedigreeParentage> parentages);

  PedigreeGraphResponseData litterParents(List<LitterParent> litterParents);

  PedigreeGraphResponseData litterMembers(List<LitterMember> litterMembers);

  PedigreeGraphResponseData commonAncestors(
    List<PedigreeGraphResponseDataCommonAncestorsInner> commonAncestors,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeGraphResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeGraphResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeGraphResponseData call({
    String rootHamsterId,
    List<Hamster> nodes,
    List<PedigreeParentage> parentages,
    List<LitterParent> litterParents,
    List<LitterMember> litterMembers,
    List<PedigreeGraphResponseDataCommonAncestorsInner> commonAncestors,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPedigreeGraphResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPedigreeGraphResponseData.copyWith.fieldName(...)`
class _$PedigreeGraphResponseDataCWProxyImpl
    implements _$PedigreeGraphResponseDataCWProxy {
  const _$PedigreeGraphResponseDataCWProxyImpl(this._value);

  final PedigreeGraphResponseData _value;

  @override
  PedigreeGraphResponseData rootHamsterId(String rootHamsterId) =>
      this(rootHamsterId: rootHamsterId);

  @override
  PedigreeGraphResponseData nodes(List<Hamster> nodes) => this(nodes: nodes);

  @override
  PedigreeGraphResponseData parentages(List<PedigreeParentage> parentages) =>
      this(parentages: parentages);

  @override
  PedigreeGraphResponseData litterParents(List<LitterParent> litterParents) =>
      this(litterParents: litterParents);

  @override
  PedigreeGraphResponseData litterMembers(List<LitterMember> litterMembers) =>
      this(litterMembers: litterMembers);

  @override
  PedigreeGraphResponseData commonAncestors(
    List<PedigreeGraphResponseDataCommonAncestorsInner> commonAncestors,
  ) => this(commonAncestors: commonAncestors);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeGraphResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeGraphResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeGraphResponseData call({
    Object? rootHamsterId = const $CopyWithPlaceholder(),
    Object? nodes = const $CopyWithPlaceholder(),
    Object? parentages = const $CopyWithPlaceholder(),
    Object? litterParents = const $CopyWithPlaceholder(),
    Object? litterMembers = const $CopyWithPlaceholder(),
    Object? commonAncestors = const $CopyWithPlaceholder(),
  }) {
    return PedigreeGraphResponseData(
      rootHamsterId: rootHamsterId == const $CopyWithPlaceholder()
          ? _value.rootHamsterId
          // ignore: cast_nullable_to_non_nullable
          : rootHamsterId as String,
      nodes: nodes == const $CopyWithPlaceholder()
          ? _value.nodes
          // ignore: cast_nullable_to_non_nullable
          : nodes as List<Hamster>,
      parentages: parentages == const $CopyWithPlaceholder()
          ? _value.parentages
          // ignore: cast_nullable_to_non_nullable
          : parentages as List<PedigreeParentage>,
      litterParents: litterParents == const $CopyWithPlaceholder()
          ? _value.litterParents
          // ignore: cast_nullable_to_non_nullable
          : litterParents as List<LitterParent>,
      litterMembers: litterMembers == const $CopyWithPlaceholder()
          ? _value.litterMembers
          // ignore: cast_nullable_to_non_nullable
          : litterMembers as List<LitterMember>,
      commonAncestors: commonAncestors == const $CopyWithPlaceholder()
          ? _value.commonAncestors
          // ignore: cast_nullable_to_non_nullable
          : commonAncestors
                as List<PedigreeGraphResponseDataCommonAncestorsInner>,
    );
  }
}

extension $PedigreeGraphResponseDataCopyWith on PedigreeGraphResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfPedigreeGraphResponseData.copyWith(...)` or like so:`instanceOfPedigreeGraphResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PedigreeGraphResponseDataCWProxy get copyWith =>
      _$PedigreeGraphResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedigreeGraphResponseData _$PedigreeGraphResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PedigreeGraphResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'root_hamster_id',
        'nodes',
        'parentages',
        'litter_parents',
        'litter_members',
        'common_ancestors',
      ],
    );
    final val = PedigreeGraphResponseData(
      rootHamsterId: $checkedConvert('root_hamster_id', (v) => v as String),
      nodes: $checkedConvert(
        'nodes',
        (v) => (v as List<dynamic>)
            .map((e) => Hamster.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      parentages: $checkedConvert(
        'parentages',
        (v) => (v as List<dynamic>)
            .map((e) => PedigreeParentage.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      litterParents: $checkedConvert(
        'litter_parents',
        (v) => (v as List<dynamic>)
            .map((e) => LitterParent.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      litterMembers: $checkedConvert(
        'litter_members',
        (v) => (v as List<dynamic>)
            .map((e) => LitterMember.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      commonAncestors: $checkedConvert(
        'common_ancestors',
        (v) => (v as List<dynamic>)
            .map(
              (e) => PedigreeGraphResponseDataCommonAncestorsInner.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'rootHamsterId': 'root_hamster_id',
    'litterParents': 'litter_parents',
    'litterMembers': 'litter_members',
    'commonAncestors': 'common_ancestors',
  },
);

Map<String, dynamic> _$PedigreeGraphResponseDataToJson(
  PedigreeGraphResponseData instance,
) => <String, dynamic>{
  'root_hamster_id': instance.rootHamsterId,
  'nodes': instance.nodes.map((e) => e.toJson()).toList(),
  'parentages': instance.parentages.map((e) => e.toJson()).toList(),
  'litter_parents': instance.litterParents.map((e) => e.toJson()).toList(),
  'litter_members': instance.litterMembers.map((e) => e.toJson()).toList(),
  'common_ancestors': instance.commonAncestors.map((e) => e.toJson()).toList(),
};
