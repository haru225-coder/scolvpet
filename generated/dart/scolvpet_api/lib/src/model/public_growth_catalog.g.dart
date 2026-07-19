// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_catalog.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthCatalogCWProxy {
  PublicGrowthCatalog site(Map<String, Object> site);

  PublicGrowthCatalog hamsters(List<GrowthPublicHamster> hamsters);

  PublicGrowthCatalog campaign(GrowthCampaign? campaign);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthCatalog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthCatalog(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthCatalog call({
    Map<String, Object> site,
    List<GrowthPublicHamster> hamsters,
    GrowthCampaign? campaign,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthCatalog.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthCatalog.copyWith.fieldName(...)`
class _$PublicGrowthCatalogCWProxyImpl implements _$PublicGrowthCatalogCWProxy {
  const _$PublicGrowthCatalogCWProxyImpl(this._value);

  final PublicGrowthCatalog _value;

  @override
  PublicGrowthCatalog site(Map<String, Object> site) => this(site: site);

  @override
  PublicGrowthCatalog hamsters(List<GrowthPublicHamster> hamsters) =>
      this(hamsters: hamsters);

  @override
  PublicGrowthCatalog campaign(GrowthCampaign? campaign) =>
      this(campaign: campaign);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthCatalog(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthCatalog(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthCatalog call({
    Object? site = const $CopyWithPlaceholder(),
    Object? hamsters = const $CopyWithPlaceholder(),
    Object? campaign = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthCatalog(
      site: site == const $CopyWithPlaceholder()
          ? _value.site
          // ignore: cast_nullable_to_non_nullable
          : site as Map<String, Object>,
      hamsters: hamsters == const $CopyWithPlaceholder()
          ? _value.hamsters
          // ignore: cast_nullable_to_non_nullable
          : hamsters as List<GrowthPublicHamster>,
      campaign: campaign == const $CopyWithPlaceholder()
          ? _value.campaign
          // ignore: cast_nullable_to_non_nullable
          : campaign as GrowthCampaign?,
    );
  }
}

extension $PublicGrowthCatalogCopyWith on PublicGrowthCatalog {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthCatalog.copyWith(...)` or like so:`instanceOfPublicGrowthCatalog.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthCatalogCWProxy get copyWith =>
      _$PublicGrowthCatalogCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthCatalog _$PublicGrowthCatalogFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PublicGrowthCatalog', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['site', 'hamsters']);
  final val = PublicGrowthCatalog(
    site: $checkedConvert(
      'site',
      (v) =>
          (v as Map<String, dynamic>).map((k, e) => MapEntry(k, e as Object)),
    ),
    hamsters: $checkedConvert(
      'hamsters',
      (v) => (v as List<dynamic>)
          .map((e) => GrowthPublicHamster.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    campaign: $checkedConvert(
      'campaign',
      (v) =>
          v == null ? null : GrowthCampaign.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PublicGrowthCatalogToJson(
  PublicGrowthCatalog instance,
) => <String, dynamic>{
  'site': instance.site,
  'hamsters': instance.hamsters.map((e) => e.toJson()).toList(),
  'campaign': ?instance.campaign?.toJson(),
};
