// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_template.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DocumentTemplateCWProxy {
  DocumentTemplate id(String id);

  DocumentTemplate kind(DocumentTemplateKindEnum kind);

  DocumentTemplate name(String name);

  DocumentTemplate bodyText(String bodyText);

  DocumentTemplate version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTemplate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTemplate(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTemplate call({
    String id,
    DocumentTemplateKindEnum kind,
    String name,
    String bodyText,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDocumentTemplate.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDocumentTemplate.copyWith.fieldName(...)`
class _$DocumentTemplateCWProxyImpl implements _$DocumentTemplateCWProxy {
  const _$DocumentTemplateCWProxyImpl(this._value);

  final DocumentTemplate _value;

  @override
  DocumentTemplate id(String id) => this(id: id);

  @override
  DocumentTemplate kind(DocumentTemplateKindEnum kind) => this(kind: kind);

  @override
  DocumentTemplate name(String name) => this(name: name);

  @override
  DocumentTemplate bodyText(String bodyText) => this(bodyText: bodyText);

  @override
  DocumentTemplate version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DocumentTemplate(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DocumentTemplate(...).copyWith(id: 12, name: "My name")
  /// ````
  DocumentTemplate call({
    Object? id = const $CopyWithPlaceholder(),
    Object? kind = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? bodyText = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return DocumentTemplate(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as DocumentTemplateKindEnum,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      bodyText: bodyText == const $CopyWithPlaceholder()
          ? _value.bodyText
          // ignore: cast_nullable_to_non_nullable
          : bodyText as String,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $DocumentTemplateCopyWith on DocumentTemplate {
  /// Returns a callable class that can be used as follows: `instanceOfDocumentTemplate.copyWith(...)` or like so:`instanceOfDocumentTemplate.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DocumentTemplateCWProxy get copyWith => _$DocumentTemplateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentTemplate _$DocumentTemplateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DocumentTemplate', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'kind', 'name', 'body_text', 'version'],
      );
      final val = DocumentTemplate(
        id: $checkedConvert('id', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$DocumentTemplateKindEnumEnumMap, v),
        ),
        name: $checkedConvert('name', (v) => v as String),
        bodyText: $checkedConvert('body_text', (v) => v as String),
        version: $checkedConvert('version', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'bodyText': 'body_text'});

Map<String, dynamic> _$DocumentTemplateToJson(DocumentTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$DocumentTemplateKindEnumEnumMap[instance.kind]!,
      'name': instance.name,
      'body_text': instance.bodyText,
      'version': instance.version,
    };

const _$DocumentTemplateKindEnumEnumMap = {
  DocumentTemplateKindEnum.contract: 'contract',
  DocumentTemplateKindEnum.receipt: 'receipt',
};
