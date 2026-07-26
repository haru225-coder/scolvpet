// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_public_site_simulate_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PostPublicSiteSimulateRequestCWProxy {
  PostPublicSiteSimulateRequest sireHamsterId(String? sireHamsterId);

  PostPublicSiteSimulateRequest damHamsterId(String? damHamsterId);

  PostPublicSiteSimulateRequest series(String? series);

  PostPublicSiteSimulateRequest sirePhenotype(String? sirePhenotype);

  PostPublicSiteSimulateRequest damPhenotype(String? damPhenotype);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostPublicSiteSimulateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostPublicSiteSimulateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PostPublicSiteSimulateRequest call({
    String? sireHamsterId,
    String? damHamsterId,
    String? series,
    String? sirePhenotype,
    String? damPhenotype,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPostPublicSiteSimulateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPostPublicSiteSimulateRequest.copyWith.fieldName(...)`
class _$PostPublicSiteSimulateRequestCWProxyImpl
    implements _$PostPublicSiteSimulateRequestCWProxy {
  const _$PostPublicSiteSimulateRequestCWProxyImpl(this._value);

  final PostPublicSiteSimulateRequest _value;

  @override
  PostPublicSiteSimulateRequest sireHamsterId(String? sireHamsterId) =>
      this(sireHamsterId: sireHamsterId);

  @override
  PostPublicSiteSimulateRequest damHamsterId(String? damHamsterId) =>
      this(damHamsterId: damHamsterId);

  @override
  PostPublicSiteSimulateRequest series(String? series) => this(series: series);

  @override
  PostPublicSiteSimulateRequest sirePhenotype(String? sirePhenotype) =>
      this(sirePhenotype: sirePhenotype);

  @override
  PostPublicSiteSimulateRequest damPhenotype(String? damPhenotype) =>
      this(damPhenotype: damPhenotype);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PostPublicSiteSimulateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PostPublicSiteSimulateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PostPublicSiteSimulateRequest call({
    Object? sireHamsterId = const $CopyWithPlaceholder(),
    Object? damHamsterId = const $CopyWithPlaceholder(),
    Object? series = const $CopyWithPlaceholder(),
    Object? sirePhenotype = const $CopyWithPlaceholder(),
    Object? damPhenotype = const $CopyWithPlaceholder(),
  }) {
    return PostPublicSiteSimulateRequest(
      sireHamsterId: sireHamsterId == const $CopyWithPlaceholder()
          ? _value.sireHamsterId
          // ignore: cast_nullable_to_non_nullable
          : sireHamsterId as String?,
      damHamsterId: damHamsterId == const $CopyWithPlaceholder()
          ? _value.damHamsterId
          // ignore: cast_nullable_to_non_nullable
          : damHamsterId as String?,
      series: series == const $CopyWithPlaceholder()
          ? _value.series
          // ignore: cast_nullable_to_non_nullable
          : series as String?,
      sirePhenotype: sirePhenotype == const $CopyWithPlaceholder()
          ? _value.sirePhenotype
          // ignore: cast_nullable_to_non_nullable
          : sirePhenotype as String?,
      damPhenotype: damPhenotype == const $CopyWithPlaceholder()
          ? _value.damPhenotype
          // ignore: cast_nullable_to_non_nullable
          : damPhenotype as String?,
    );
  }
}

extension $PostPublicSiteSimulateRequestCopyWith
    on PostPublicSiteSimulateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPostPublicSiteSimulateRequest.copyWith(...)` or like so:`instanceOfPostPublicSiteSimulateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PostPublicSiteSimulateRequestCWProxy get copyWith =>
      _$PostPublicSiteSimulateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostPublicSiteSimulateRequest _$PostPublicSiteSimulateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PostPublicSiteSimulateRequest',
  json,
  ($checkedConvert) {
    final val = PostPublicSiteSimulateRequest(
      sireHamsterId: $checkedConvert('sire_hamster_id', (v) => v as String?),
      damHamsterId: $checkedConvert('dam_hamster_id', (v) => v as String?),
      series: $checkedConvert('series', (v) => v as String?),
      sirePhenotype: $checkedConvert('sire_phenotype', (v) => v as String?),
      damPhenotype: $checkedConvert('dam_phenotype', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'sireHamsterId': 'sire_hamster_id',
    'damHamsterId': 'dam_hamster_id',
    'sirePhenotype': 'sire_phenotype',
    'damPhenotype': 'dam_phenotype',
  },
);

Map<String, dynamic> _$PostPublicSiteSimulateRequestToJson(
  PostPublicSiteSimulateRequest instance,
) => <String, dynamic>{
  'sire_hamster_id': ?instance.sireHamsterId,
  'dam_hamster_id': ?instance.damHamsterId,
  'series': ?instance.series,
  'sire_phenotype': ?instance.sirePhenotype,
  'dam_phenotype': ?instance.damPhenotype,
};
