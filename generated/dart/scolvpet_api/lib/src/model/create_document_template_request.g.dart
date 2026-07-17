// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_document_template_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateDocumentTemplateRequestCWProxy {
  CreateDocumentTemplateRequest name(String name);

  CreateDocumentTemplateRequest bodyText(String? bodyText);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateDocumentTemplateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateDocumentTemplateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateDocumentTemplateRequest call({String name, String? bodyText});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateDocumentTemplateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateDocumentTemplateRequest.copyWith.fieldName(...)`
class _$CreateDocumentTemplateRequestCWProxyImpl
    implements _$CreateDocumentTemplateRequestCWProxy {
  const _$CreateDocumentTemplateRequestCWProxyImpl(this._value);

  final CreateDocumentTemplateRequest _value;

  @override
  CreateDocumentTemplateRequest name(String name) => this(name: name);

  @override
  CreateDocumentTemplateRequest bodyText(String? bodyText) =>
      this(bodyText: bodyText);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateDocumentTemplateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateDocumentTemplateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateDocumentTemplateRequest call({
    Object? name = const $CopyWithPlaceholder(),
    Object? bodyText = const $CopyWithPlaceholder(),
  }) {
    return CreateDocumentTemplateRequest(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      bodyText: bodyText == const $CopyWithPlaceholder()
          ? _value.bodyText
          // ignore: cast_nullable_to_non_nullable
          : bodyText as String?,
    );
  }
}

extension $CreateDocumentTemplateRequestCopyWith
    on CreateDocumentTemplateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateDocumentTemplateRequest.copyWith(...)` or like so:`instanceOfCreateDocumentTemplateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateDocumentTemplateRequestCWProxy get copyWith =>
      _$CreateDocumentTemplateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDocumentTemplateRequest _$CreateDocumentTemplateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateDocumentTemplateRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['name']);
  final val = CreateDocumentTemplateRequest(
    name: $checkedConvert('name', (v) => v as String),
    bodyText: $checkedConvert('body_text', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'bodyText': 'body_text'});

Map<String, dynamic> _$CreateDocumentTemplateRequestToJson(
  CreateDocumentTemplateRequest instance,
) => <String, dynamic>{'name': instance.name, 'body_text': ?instance.bodyText};
