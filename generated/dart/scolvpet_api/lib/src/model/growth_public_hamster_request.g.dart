// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_public_hamster_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthPublicHamsterRequestCWProxy {
  GrowthPublicHamsterRequest publicName(String? publicName);

  GrowthPublicHamsterRequest summary(String? summary);

  GrowthPublicHamsterRequest traits(List<String>? traits);

  GrowthPublicHamsterRequest filmingStatus(
    GrowthPublicHamsterRequestFilmingStatusEnum filmingStatus,
  );

  GrowthPublicHamsterRequest published(bool published);

  GrowthPublicHamsterRequest consultable(bool consultable);

  GrowthPublicHamsterRequest ctaText(String? ctaText);

  GrowthPublicHamsterRequest priceLabel(String? priceLabel);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicHamsterRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicHamsterRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicHamsterRequest call({
    String? publicName,
    String? summary,
    List<String>? traits,
    GrowthPublicHamsterRequestFilmingStatusEnum filmingStatus,
    bool published,
    bool consultable,
    String? ctaText,
    String? priceLabel,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthPublicHamsterRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthPublicHamsterRequest.copyWith.fieldName(...)`
class _$GrowthPublicHamsterRequestCWProxyImpl
    implements _$GrowthPublicHamsterRequestCWProxy {
  const _$GrowthPublicHamsterRequestCWProxyImpl(this._value);

  final GrowthPublicHamsterRequest _value;

  @override
  GrowthPublicHamsterRequest publicName(String? publicName) =>
      this(publicName: publicName);

  @override
  GrowthPublicHamsterRequest summary(String? summary) => this(summary: summary);

  @override
  GrowthPublicHamsterRequest traits(List<String>? traits) =>
      this(traits: traits);

  @override
  GrowthPublicHamsterRequest filmingStatus(
    GrowthPublicHamsterRequestFilmingStatusEnum filmingStatus,
  ) => this(filmingStatus: filmingStatus);

  @override
  GrowthPublicHamsterRequest published(bool published) =>
      this(published: published);

  @override
  GrowthPublicHamsterRequest consultable(bool consultable) =>
      this(consultable: consultable);

  @override
  GrowthPublicHamsterRequest ctaText(String? ctaText) => this(ctaText: ctaText);

  @override
  GrowthPublicHamsterRequest priceLabel(String? priceLabel) =>
      this(priceLabel: priceLabel);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicHamsterRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicHamsterRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicHamsterRequest call({
    Object? publicName = const $CopyWithPlaceholder(),
    Object? summary = const $CopyWithPlaceholder(),
    Object? traits = const $CopyWithPlaceholder(),
    Object? filmingStatus = const $CopyWithPlaceholder(),
    Object? published = const $CopyWithPlaceholder(),
    Object? consultable = const $CopyWithPlaceholder(),
    Object? ctaText = const $CopyWithPlaceholder(),
    Object? priceLabel = const $CopyWithPlaceholder(),
  }) {
    return GrowthPublicHamsterRequest(
      publicName: publicName == const $CopyWithPlaceholder()
          ? _value.publicName
          // ignore: cast_nullable_to_non_nullable
          : publicName as String?,
      summary: summary == const $CopyWithPlaceholder()
          ? _value.summary
          // ignore: cast_nullable_to_non_nullable
          : summary as String?,
      traits: traits == const $CopyWithPlaceholder()
          ? _value.traits
          // ignore: cast_nullable_to_non_nullable
          : traits as List<String>?,
      filmingStatus: filmingStatus == const $CopyWithPlaceholder()
          ? _value.filmingStatus
          // ignore: cast_nullable_to_non_nullable
          : filmingStatus as GrowthPublicHamsterRequestFilmingStatusEnum,
      published: published == const $CopyWithPlaceholder()
          ? _value.published
          // ignore: cast_nullable_to_non_nullable
          : published as bool,
      consultable: consultable == const $CopyWithPlaceholder()
          ? _value.consultable
          // ignore: cast_nullable_to_non_nullable
          : consultable as bool,
      ctaText: ctaText == const $CopyWithPlaceholder()
          ? _value.ctaText
          // ignore: cast_nullable_to_non_nullable
          : ctaText as String?,
      priceLabel: priceLabel == const $CopyWithPlaceholder()
          ? _value.priceLabel
          // ignore: cast_nullable_to_non_nullable
          : priceLabel as String?,
    );
  }
}

extension $GrowthPublicHamsterRequestCopyWith on GrowthPublicHamsterRequest {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthPublicHamsterRequest.copyWith(...)` or like so:`instanceOfGrowthPublicHamsterRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthPublicHamsterRequestCWProxy get copyWith =>
      _$GrowthPublicHamsterRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthPublicHamsterRequest _$GrowthPublicHamsterRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'GrowthPublicHamsterRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['filming_status', 'published', 'consultable'],
    );
    final val = GrowthPublicHamsterRequest(
      publicName: $checkedConvert('public_name', (v) => v as String?),
      summary: $checkedConvert('summary', (v) => v as String?),
      traits: $checkedConvert(
        'traits',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      filmingStatus: $checkedConvert(
        'filming_status',
        (v) => $enumDecode(
          _$GrowthPublicHamsterRequestFilmingStatusEnumEnumMap,
          v,
        ),
      ),
      published: $checkedConvert('published', (v) => v as bool),
      consultable: $checkedConvert('consultable', (v) => v as bool),
      ctaText: $checkedConvert('cta_text', (v) => v as String?),
      priceLabel: $checkedConvert('price_label', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'publicName': 'public_name',
    'filmingStatus': 'filming_status',
    'ctaText': 'cta_text',
    'priceLabel': 'price_label',
  },
);

Map<String, dynamic> _$GrowthPublicHamsterRequestToJson(
  GrowthPublicHamsterRequest instance,
) => <String, dynamic>{
  'public_name': ?instance.publicName,
  'summary': ?instance.summary,
  'traits': ?instance.traits,
  'filming_status':
      _$GrowthPublicHamsterRequestFilmingStatusEnumEnumMap[instance
          .filmingStatus]!,
  'published': instance.published,
  'consultable': instance.consultable,
  'cta_text': ?instance.ctaText,
  'price_label': ?instance.priceLabel,
};

const _$GrowthPublicHamsterRequestFilmingStatusEnumEnumMap = {
  GrowthPublicHamsterRequestFilmingStatusEnum.ready: 'ready',
  GrowthPublicHamsterRequestFilmingStatusEnum.rest: 'rest',
  GrowthPublicHamsterRequestFilmingStatusEnum.restricted: 'restricted',
};
