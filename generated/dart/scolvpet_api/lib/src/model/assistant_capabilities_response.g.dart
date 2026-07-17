// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_capabilities_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantCapabilitiesResponseCWProxy {
  AssistantCapabilitiesResponse data(AssistantCapabilities data);

  AssistantCapabilitiesResponse meta(ResponseMeta meta);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantCapabilitiesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantCapabilitiesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantCapabilitiesResponse call({
    AssistantCapabilities data,
    ResponseMeta meta,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantCapabilitiesResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantCapabilitiesResponse.copyWith.fieldName(...)`
class _$AssistantCapabilitiesResponseCWProxyImpl
    implements _$AssistantCapabilitiesResponseCWProxy {
  const _$AssistantCapabilitiesResponseCWProxyImpl(this._value);

  final AssistantCapabilitiesResponse _value;

  @override
  AssistantCapabilitiesResponse data(AssistantCapabilities data) =>
      this(data: data);

  @override
  AssistantCapabilitiesResponse meta(ResponseMeta meta) => this(meta: meta);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantCapabilitiesResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantCapabilitiesResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantCapabilitiesResponse call({
    Object? data = const $CopyWithPlaceholder(),
    Object? meta = const $CopyWithPlaceholder(),
  }) {
    return AssistantCapabilitiesResponse(
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as AssistantCapabilities,
      meta: meta == const $CopyWithPlaceholder()
          ? _value.meta
          // ignore: cast_nullable_to_non_nullable
          : meta as ResponseMeta,
    );
  }
}

extension $AssistantCapabilitiesResponseCopyWith
    on AssistantCapabilitiesResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantCapabilitiesResponse.copyWith(...)` or like so:`instanceOfAssistantCapabilitiesResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantCapabilitiesResponseCWProxy get copyWith =>
      _$AssistantCapabilitiesResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantCapabilitiesResponse _$AssistantCapabilitiesResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantCapabilitiesResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['data', 'meta']);
  final val = AssistantCapabilitiesResponse(
    data: $checkedConvert(
      'data',
      (v) => AssistantCapabilities.fromJson(v as Map<String, dynamic>),
    ),
    meta: $checkedConvert(
      'meta',
      (v) => ResponseMeta.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$AssistantCapabilitiesResponseToJson(
  AssistantCapabilitiesResponse instance,
) => <String, dynamic>{
  'data': instance.data.toJson(),
  'meta': instance.meta.toJson(),
};
