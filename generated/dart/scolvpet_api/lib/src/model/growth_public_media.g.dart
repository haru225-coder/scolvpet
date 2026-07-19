// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_public_media.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthPublicMediaCWProxy {
  GrowthPublicMedia id(String id);

  GrowthPublicMedia url(String url);

  GrowthPublicMedia kind(GrowthPublicMediaKindEnum kind);

  GrowthPublicMedia status(GrowthPublicMediaStatusEnum? status);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicMedia(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicMedia(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicMedia call({
    String id,
    String url,
    GrowthPublicMediaKindEnum kind,
    GrowthPublicMediaStatusEnum? status,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthPublicMedia.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthPublicMedia.copyWith.fieldName(...)`
class _$GrowthPublicMediaCWProxyImpl implements _$GrowthPublicMediaCWProxy {
  const _$GrowthPublicMediaCWProxyImpl(this._value);

  final GrowthPublicMedia _value;

  @override
  GrowthPublicMedia id(String id) => this(id: id);

  @override
  GrowthPublicMedia url(String url) => this(url: url);

  @override
  GrowthPublicMedia kind(GrowthPublicMediaKindEnum kind) => this(kind: kind);

  @override
  GrowthPublicMedia status(GrowthPublicMediaStatusEnum? status) =>
      this(status: status);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthPublicMedia(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthPublicMedia(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthPublicMedia call({
    Object? id = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
  }) {
    return GrowthPublicMedia(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      url: url == const $CopyWithPlaceholder()
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as GrowthPublicMediaKindEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as GrowthPublicMediaStatusEnum?,
    );
  }
}

extension $GrowthPublicMediaCopyWith on GrowthPublicMedia {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthPublicMedia.copyWith(...)` or like so:`instanceOfGrowthPublicMedia.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthPublicMediaCWProxy get copyWith =>
      _$GrowthPublicMediaCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthPublicMedia _$GrowthPublicMediaFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GrowthPublicMedia', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'url', 'kind']);
      final val = GrowthPublicMedia(
        id: $checkedConvert('id', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$GrowthPublicMediaKindEnumEnumMap, v),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecodeNullable(_$GrowthPublicMediaStatusEnumEnumMap, v),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GrowthPublicMediaToJson(GrowthPublicMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'kind': _$GrowthPublicMediaKindEnumEnumMap[instance.kind]!,
      'status': ?_$GrowthPublicMediaStatusEnumEnumMap[instance.status],
    };

const _$GrowthPublicMediaKindEnumEnumMap = {
  GrowthPublicMediaKindEnum.cover: 'cover',
  GrowthPublicMediaKindEnum.thumbnail: 'thumbnail',
  GrowthPublicMediaKindEnum.preview: 'preview',
};

const _$GrowthPublicMediaStatusEnumEnumMap = {
  GrowthPublicMediaStatusEnum.ready: 'ready',
  GrowthPublicMediaStatusEnum.processing: 'processing',
  GrowthPublicMediaStatusEnum.failed: 'failed',
};
