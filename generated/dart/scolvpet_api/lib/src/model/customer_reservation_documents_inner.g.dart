// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_reservation_documents_inner.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerReservationDocumentsInnerCWProxy {
  CustomerReservationDocumentsInner id(String? id);

  CustomerReservationDocumentsInner docType(String? docType);

  CustomerReservationDocumentsInner status(String? status);

  CustomerReservationDocumentsInner publicToken(String? publicToken);

  CustomerReservationDocumentsInner webPath(String? webPath);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservationDocumentsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservationDocumentsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservationDocumentsInner call({
    String? id,
    String? docType,
    String? status,
    String? publicToken,
    String? webPath,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerReservationDocumentsInner.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerReservationDocumentsInner.copyWith.fieldName(...)`
class _$CustomerReservationDocumentsInnerCWProxyImpl
    implements _$CustomerReservationDocumentsInnerCWProxy {
  const _$CustomerReservationDocumentsInnerCWProxyImpl(this._value);

  final CustomerReservationDocumentsInner _value;

  @override
  CustomerReservationDocumentsInner id(String? id) => this(id: id);

  @override
  CustomerReservationDocumentsInner docType(String? docType) =>
      this(docType: docType);

  @override
  CustomerReservationDocumentsInner status(String? status) =>
      this(status: status);

  @override
  CustomerReservationDocumentsInner publicToken(String? publicToken) =>
      this(publicToken: publicToken);

  @override
  CustomerReservationDocumentsInner webPath(String? webPath) =>
      this(webPath: webPath);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservationDocumentsInner(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservationDocumentsInner(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservationDocumentsInner call({
    Object? id = const $CopyWithPlaceholder(),
    Object? docType = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? publicToken = const $CopyWithPlaceholder(),
    Object? webPath = const $CopyWithPlaceholder(),
  }) {
    return CustomerReservationDocumentsInner(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      docType: docType == const $CopyWithPlaceholder()
          ? _value.docType
          // ignore: cast_nullable_to_non_nullable
          : docType as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      publicToken: publicToken == const $CopyWithPlaceholder()
          ? _value.publicToken
          // ignore: cast_nullable_to_non_nullable
          : publicToken as String?,
      webPath: webPath == const $CopyWithPlaceholder()
          ? _value.webPath
          // ignore: cast_nullable_to_non_nullable
          : webPath as String?,
    );
  }
}

extension $CustomerReservationDocumentsInnerCopyWith
    on CustomerReservationDocumentsInner {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerReservationDocumentsInner.copyWith(...)` or like so:`instanceOfCustomerReservationDocumentsInner.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerReservationDocumentsInnerCWProxy get copyWith =>
      _$CustomerReservationDocumentsInnerCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerReservationDocumentsInner _$CustomerReservationDocumentsInnerFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'CustomerReservationDocumentsInner',
  json,
  ($checkedConvert) {
    final val = CustomerReservationDocumentsInner(
      id: $checkedConvert('id', (v) => v as String?),
      docType: $checkedConvert('doc_type', (v) => v as String?),
      status: $checkedConvert('status', (v) => v as String?),
      publicToken: $checkedConvert('public_token', (v) => v as String?),
      webPath: $checkedConvert('web_path', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'docType': 'doc_type',
    'publicToken': 'public_token',
    'webPath': 'web_path',
  },
);

Map<String, dynamic> _$CustomerReservationDocumentsInnerToJson(
  CustomerReservationDocumentsInner instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'doc_type': ?instance.docType,
  'status': ?instance.status,
  'public_token': ?instance.publicToken,
  'web_path': ?instance.webPath,
};
