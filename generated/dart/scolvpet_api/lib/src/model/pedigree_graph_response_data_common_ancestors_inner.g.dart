// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedigree_graph_response_data_common_ancestors_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PedigreeGraphResponseDataCommonAncestorsInnerCWProxy {
  PedigreeGraphResponseDataCommonAncestorsInner hamsterId(String hamsterId);

  PedigreeGraphResponseDataCommonAncestorsInner paths(int paths);

  PedigreeGraphResponseDataCommonAncestorsInner minimumGeneration(
    int minimumGeneration,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeGraphResponseDataCommonAncestorsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeGraphResponseDataCommonAncestorsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeGraphResponseDataCommonAncestorsInner call({
    String hamsterId,
    int paths,
    int minimumGeneration,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPedigreeGraphResponseDataCommonAncestorsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPedigreeGraphResponseDataCommonAncestorsInner.copyWith.fieldName(...)`
class _$PedigreeGraphResponseDataCommonAncestorsInnerCWProxyImpl
    implements _$PedigreeGraphResponseDataCommonAncestorsInnerCWProxy {
  const _$PedigreeGraphResponseDataCommonAncestorsInnerCWProxyImpl(this._value);

  final PedigreeGraphResponseDataCommonAncestorsInner _value;

  @override
  PedigreeGraphResponseDataCommonAncestorsInner hamsterId(String hamsterId) =>
      this(hamsterId: hamsterId);

  @override
  PedigreeGraphResponseDataCommonAncestorsInner paths(int paths) =>
      this(paths: paths);

  @override
  PedigreeGraphResponseDataCommonAncestorsInner minimumGeneration(
    int minimumGeneration,
  ) => this(minimumGeneration: minimumGeneration);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PedigreeGraphResponseDataCommonAncestorsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PedigreeGraphResponseDataCommonAncestorsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  PedigreeGraphResponseDataCommonAncestorsInner call({
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? paths = const $CopyWithPlaceholder(),
    Object? minimumGeneration = const $CopyWithPlaceholder(),
  }) {
    return PedigreeGraphResponseDataCommonAncestorsInner(
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
      paths: paths == const $CopyWithPlaceholder()
          ? _value.paths
          // ignore: cast_nullable_to_non_nullable
          : paths as int,
      minimumGeneration: minimumGeneration == const $CopyWithPlaceholder()
          ? _value.minimumGeneration
          // ignore: cast_nullable_to_non_nullable
          : minimumGeneration as int,
    );
  }
}

extension $PedigreeGraphResponseDataCommonAncestorsInnerCopyWith
    on PedigreeGraphResponseDataCommonAncestorsInner {
  /// Returns a callable class that can be used as follows: `instanceOfPedigreeGraphResponseDataCommonAncestorsInner.copyWith(...)` or like so:`instanceOfPedigreeGraphResponseDataCommonAncestorsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PedigreeGraphResponseDataCommonAncestorsInnerCWProxy get copyWith =>
      _$PedigreeGraphResponseDataCommonAncestorsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedigreeGraphResponseDataCommonAncestorsInner
_$PedigreeGraphResponseDataCommonAncestorsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PedigreeGraphResponseDataCommonAncestorsInner',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['hamster_id', 'paths', 'minimum_generation'],
    );
    final val = PedigreeGraphResponseDataCommonAncestorsInner(
      hamsterId: $checkedConvert('hamster_id', (v) => v as String),
      paths: $checkedConvert('paths', (v) => (v as num).toInt()),
      minimumGeneration: $checkedConvert(
        'minimum_generation',
        (v) => (v as num).toInt(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'hamsterId': 'hamster_id',
    'minimumGeneration': 'minimum_generation',
  },
);

Map<String, dynamic> _$PedigreeGraphResponseDataCommonAncestorsInnerToJson(
  PedigreeGraphResponseDataCommonAncestorsInner instance,
) => <String, dynamic>{
  'hamster_id': instance.hamsterId,
  'paths': instance.paths,
  'minimum_generation': instance.minimumGeneration,
};
