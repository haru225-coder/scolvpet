// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_reservation.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CustomerReservationCWProxy {
  CustomerReservation id(String? id);

  CustomerReservation title(String? title);

  CustomerReservation status(String? status);

  CustomerReservation reservedAt(DateTime? reservedAt);

  CustomerReservation holdExpiresAt(DateTime? holdExpiresAt);

  CustomerReservation updatedAt(DateTime? updatedAt);

  CustomerReservation version(int? version);

  CustomerReservation hamster(CustomerReservationHamster? hamster);

  CustomerReservation documents(
    List<CustomerReservationDocumentsInner>? documents,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservation(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservation call({
    String? id,
    String? title,
    String? status,
    DateTime? reservedAt,
    DateTime? holdExpiresAt,
    DateTime? updatedAt,
    int? version,
    CustomerReservationHamster? hamster,
    List<CustomerReservationDocumentsInner>? documents,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCustomerReservation.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCustomerReservation.copyWith.fieldName(...)`
class _$CustomerReservationCWProxyImpl implements _$CustomerReservationCWProxy {
  const _$CustomerReservationCWProxyImpl(this._value);

  final CustomerReservation _value;

  @override
  CustomerReservation id(String? id) => this(id: id);

  @override
  CustomerReservation title(String? title) => this(title: title);

  @override
  CustomerReservation status(String? status) => this(status: status);

  @override
  CustomerReservation reservedAt(DateTime? reservedAt) =>
      this(reservedAt: reservedAt);

  @override
  CustomerReservation holdExpiresAt(DateTime? holdExpiresAt) =>
      this(holdExpiresAt: holdExpiresAt);

  @override
  CustomerReservation updatedAt(DateTime? updatedAt) =>
      this(updatedAt: updatedAt);

  @override
  CustomerReservation version(int? version) => this(version: version);

  @override
  CustomerReservation hamster(CustomerReservationHamster? hamster) =>
      this(hamster: hamster);

  @override
  CustomerReservation documents(
    List<CustomerReservationDocumentsInner>? documents,
  ) => this(documents: documents);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CustomerReservation(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CustomerReservation(...).copyWith(id: 12, name: "My name")
  /// ````
  CustomerReservation call({
    Object? id = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? reservedAt = const $CopyWithPlaceholder(),
    Object? holdExpiresAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? hamster = const $CopyWithPlaceholder(),
    Object? documents = const $CopyWithPlaceholder(),
  }) {
    return CustomerReservation(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as String?,
      reservedAt: reservedAt == const $CopyWithPlaceholder()
          ? _value.reservedAt
          // ignore: cast_nullable_to_non_nullable
          : reservedAt as DateTime?,
      holdExpiresAt: holdExpiresAt == const $CopyWithPlaceholder()
          ? _value.holdExpiresAt
          // ignore: cast_nullable_to_non_nullable
          : holdExpiresAt as DateTime?,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int?,
      hamster: hamster == const $CopyWithPlaceholder()
          ? _value.hamster
          // ignore: cast_nullable_to_non_nullable
          : hamster as CustomerReservationHamster?,
      documents: documents == const $CopyWithPlaceholder()
          ? _value.documents
          // ignore: cast_nullable_to_non_nullable
          : documents as List<CustomerReservationDocumentsInner>?,
    );
  }
}

extension $CustomerReservationCopyWith on CustomerReservation {
  /// Returns a callable class that can be used as follows: `instanceOfCustomerReservation.copyWith(...)` or like so:`instanceOfCustomerReservation.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CustomerReservationCWProxy get copyWith =>
      _$CustomerReservationCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerReservation _$CustomerReservationFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CustomerReservation',
      json,
      ($checkedConvert) {
        final val = CustomerReservation(
          id: $checkedConvert('id', (v) => v as String?),
          title: $checkedConvert('title', (v) => v as String?),
          status: $checkedConvert('status', (v) => v as String?),
          reservedAt: $checkedConvert(
            'reserved_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          holdExpiresAt: $checkedConvert(
            'hold_expires_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          version: $checkedConvert('version', (v) => (v as num?)?.toInt()),
          hamster: $checkedConvert(
            'hamster',
            (v) => v == null
                ? null
                : CustomerReservationHamster.fromJson(
                    v as Map<String, dynamic>,
                  ),
          ),
          documents: $checkedConvert(
            'documents',
            (v) => (v as List<dynamic>?)
                ?.map(
                  (e) => CustomerReservationDocumentsInner.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'reservedAt': 'reserved_at',
        'holdExpiresAt': 'hold_expires_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$CustomerReservationToJson(
  CustomerReservation instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'title': ?instance.title,
  'status': ?instance.status,
  'reserved_at': ?instance.reservedAt?.toIso8601String(),
  'hold_expires_at': ?instance.holdExpiresAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'version': ?instance.version,
  'hamster': ?instance.hamster?.toJson(),
  'documents': ?instance.documents?.map((e) => e.toJson()).toList(),
};
