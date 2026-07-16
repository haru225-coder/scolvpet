// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individualize_litter_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$IndividualizeLitterRequestCWProxy {
  IndividualizeLitterRequest individualizedAt(DateTime individualizedAt);

  IndividualizeLitterRequest timezone(String timezone);

  IndividualizeLitterRequest eligibleSetToken(String eligibleSetToken);

  IndividualizeLitterRequest items(
    List<IndividualizeLitterRequestItemsInner> items,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeLitterRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeLitterRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeLitterRequest call({
    DateTime individualizedAt,
    String timezone,
    String eligibleSetToken,
    List<IndividualizeLitterRequestItemsInner> items,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfIndividualizeLitterRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfIndividualizeLitterRequest.copyWith.fieldName(...)`
class _$IndividualizeLitterRequestCWProxyImpl
    implements _$IndividualizeLitterRequestCWProxy {
  const _$IndividualizeLitterRequestCWProxyImpl(this._value);

  final IndividualizeLitterRequest _value;

  @override
  IndividualizeLitterRequest individualizedAt(DateTime individualizedAt) =>
      this(individualizedAt: individualizedAt);

  @override
  IndividualizeLitterRequest timezone(String timezone) =>
      this(timezone: timezone);

  @override
  IndividualizeLitterRequest eligibleSetToken(String eligibleSetToken) =>
      this(eligibleSetToken: eligibleSetToken);

  @override
  IndividualizeLitterRequest items(
    List<IndividualizeLitterRequestItemsInner> items,
  ) => this(items: items);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `IndividualizeLitterRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// IndividualizeLitterRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  IndividualizeLitterRequest call({
    Object? individualizedAt = const $CopyWithPlaceholder(),
    Object? timezone = const $CopyWithPlaceholder(),
    Object? eligibleSetToken = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return IndividualizeLitterRequest(
      individualizedAt: individualizedAt == const $CopyWithPlaceholder()
          ? _value.individualizedAt
          // ignore: cast_nullable_to_non_nullable
          : individualizedAt as DateTime,
      timezone: timezone == const $CopyWithPlaceholder()
          ? _value.timezone
          // ignore: cast_nullable_to_non_nullable
          : timezone as String,
      eligibleSetToken: eligibleSetToken == const $CopyWithPlaceholder()
          ? _value.eligibleSetToken
          // ignore: cast_nullable_to_non_nullable
          : eligibleSetToken as String,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<IndividualizeLitterRequestItemsInner>,
    );
  }
}

extension $IndividualizeLitterRequestCopyWith on IndividualizeLitterRequest {
  /// Returns a callable class that can be used as follows: `instanceOfIndividualizeLitterRequest.copyWith(...)` or like so:`instanceOfIndividualizeLitterRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$IndividualizeLitterRequestCWProxy get copyWith =>
      _$IndividualizeLitterRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IndividualizeLitterRequest _$IndividualizeLitterRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'IndividualizeLitterRequest',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'individualized_at',
        'timezone',
        'eligible_set_token',
        'items',
      ],
    );
    final val = IndividualizeLitterRequest(
      individualizedAt: $checkedConvert(
        'individualized_at',
        (v) => DateTime.parse(v as String),
      ),
      timezone: $checkedConvert('timezone', (v) => v as String),
      eligibleSetToken: $checkedConvert(
        'eligible_set_token',
        (v) => v as String,
      ),
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map(
              (e) => IndividualizeLitterRequestItemsInner.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'individualizedAt': 'individualized_at',
    'eligibleSetToken': 'eligible_set_token',
  },
);

Map<String, dynamic> _$IndividualizeLitterRequestToJson(
  IndividualizeLitterRequest instance,
) => <String, dynamic>{
  'individualized_at': instance.individualizedAt.toIso8601String(),
  'timezone': instance.timezone,
  'eligible_set_token': instance.eligibleSetToken,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
