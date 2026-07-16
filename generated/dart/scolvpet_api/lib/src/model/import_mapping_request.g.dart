// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_mapping_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportMappingRequestCWProxy {
  ImportMappingRequest timezone(String timezone);

  ImportMappingRequest mappings(
    List<ImportMappingRequestMappingsInner> mappings,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportMappingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportMappingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportMappingRequest call({
    String timezone,
    List<ImportMappingRequestMappingsInner> mappings,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportMappingRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportMappingRequest.copyWith.fieldName(...)`
class _$ImportMappingRequestCWProxyImpl
    implements _$ImportMappingRequestCWProxy {
  const _$ImportMappingRequestCWProxyImpl(this._value);

  final ImportMappingRequest _value;

  @override
  ImportMappingRequest timezone(String timezone) => this(timezone: timezone);

  @override
  ImportMappingRequest mappings(
    List<ImportMappingRequestMappingsInner> mappings,
  ) => this(mappings: mappings);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportMappingRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportMappingRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportMappingRequest call({
    Object? timezone = const $CopyWithPlaceholder(),
    Object? mappings = const $CopyWithPlaceholder(),
  }) {
    return ImportMappingRequest(
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      mappings: mappings == const $CopyWithPlaceholder()
          ? _value.mappings
          // ignore: cast_nullable_to_non_nullable
          : mappings as List<ImportMappingRequestMappingsInner>,
    );
  }
}

extension $ImportMappingRequestCopyWith on ImportMappingRequest {
  /// Returns a callable class that can be used as follows: `instanceOfImportMappingRequest.copyWith(...)` or like so:`instanceOfImportMappingRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportMappingRequestCWProxy get copyWith =>
      _$ImportMappingRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportMappingRequest _$ImportMappingRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ImportMappingRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['timezone', 'mappings']);
  final val = ImportMappingRequest(
    timezone: $checkedConvert('timezone', (v) => v as String),
    mappings: $checkedConvert(
      'mappings',
      (v) => (v as List<dynamic>)
          .map(
            (e) => ImportMappingRequestMappingsInner.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ImportMappingRequestToJson(
  ImportMappingRequest instance,
) => <String, dynamic>{
  'timezone': instance.timezone,
  'mappings': instance.mappings.map((e) => e.toJson()).toList(),
};
