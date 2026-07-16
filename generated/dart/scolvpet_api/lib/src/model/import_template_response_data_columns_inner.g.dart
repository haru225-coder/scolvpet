// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_template_response_data_columns_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ImportTemplateResponseDataColumnsInnerCWProxy {
  ImportTemplateResponseDataColumnsInner key(String key);

  ImportTemplateResponseDataColumnsInner label(String label);

  ImportTemplateResponseDataColumnsInner required_(bool required_);

  ImportTemplateResponseDataColumnsInner dataType(String dataType);

  ImportTemplateResponseDataColumnsInner example(
    ImportTemplateResponseDataColumnsInnerExample? example,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportTemplateResponseDataColumnsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportTemplateResponseDataColumnsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportTemplateResponseDataColumnsInner call({
    String key,
    String label,
    bool required_,
    String dataType,
    ImportTemplateResponseDataColumnsInnerExample? example,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfImportTemplateResponseDataColumnsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfImportTemplateResponseDataColumnsInner.copyWith.fieldName(...)`
class _$ImportTemplateResponseDataColumnsInnerCWProxyImpl
    implements _$ImportTemplateResponseDataColumnsInnerCWProxy {
  const _$ImportTemplateResponseDataColumnsInnerCWProxyImpl(this._value);

  final ImportTemplateResponseDataColumnsInner _value;

  @override
  ImportTemplateResponseDataColumnsInner key(String key) => this(key: key);

  @override
  ImportTemplateResponseDataColumnsInner label(String label) =>
      this(label: label);

  @override
  ImportTemplateResponseDataColumnsInner required_(bool required_) =>
      this(required_: required_);

  @override
  ImportTemplateResponseDataColumnsInner dataType(String dataType) =>
      this(dataType: dataType);

  @override
  ImportTemplateResponseDataColumnsInner example(
    ImportTemplateResponseDataColumnsInnerExample? example,
  ) => this(example: example);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ImportTemplateResponseDataColumnsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ImportTemplateResponseDataColumnsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  ImportTemplateResponseDataColumnsInner call({
    Object? key = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? required_ = const $CopyWithPlaceholder(),
    Object? dataType = const $CopyWithPlaceholder(),
    Object? example = const $CopyWithPlaceholder(),
  }) {
    return ImportTemplateResponseDataColumnsInner(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      required_: required_ == const $CopyWithPlaceholder()
          ? _value.required_
          // ignore: cast_nullable_to_non_nullable
          : required_ as bool,
      dataType: dataType == const $CopyWithPlaceholder()
          ? _value.dataType
          // ignore: cast_nullable_to_non_nullable
          : dataType as String,
      example: example == const $CopyWithPlaceholder()
          ? _value.example
          // ignore: cast_nullable_to_non_nullable
          : example as ImportTemplateResponseDataColumnsInnerExample?,
    );
  }
}

extension $ImportTemplateResponseDataColumnsInnerCopyWith
    on ImportTemplateResponseDataColumnsInner {
  /// Returns a callable class that can be used as follows: `instanceOfImportTemplateResponseDataColumnsInner.copyWith(...)` or like so:`instanceOfImportTemplateResponseDataColumnsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ImportTemplateResponseDataColumnsInnerCWProxy get copyWith =>
      _$ImportTemplateResponseDataColumnsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportTemplateResponseDataColumnsInner
_$ImportTemplateResponseDataColumnsInnerFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'ImportTemplateResponseDataColumnsInner',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['key', 'label', 'required', 'data_type'],
        );
        final val = ImportTemplateResponseDataColumnsInner(
          key: $checkedConvert('key', (v) => v as String),
          label: $checkedConvert('label', (v) => v as String),
          required_: $checkedConvert('required', (v) => v as bool),
          dataType: $checkedConvert('data_type', (v) => v as String),
          example: $checkedConvert(
            'example',
            (v) => v == null
                ? null
                : ImportTemplateResponseDataColumnsInnerExample.fromJson(
                    v as Map<String, dynamic>,
                  ),
          ),
        );
        return val;
      },
      fieldKeyMap: const {'required_': 'required', 'dataType': 'data_type'},
    );

Map<String, dynamic> _$ImportTemplateResponseDataColumnsInnerToJson(
  ImportTemplateResponseDataColumnsInner instance,
) => <String, dynamic>{
  'key': instance.key,
  'label': instance.label,
  'required': instance.required_,
  'data_type': instance.dataType,
  'example': ?instance.example?.toJson(),
};
