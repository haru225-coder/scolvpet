// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enclosure_update_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$EnclosureUpdateRequestCWProxy {
  EnclosureUpdateRequest code(String? code);

  EnclosureUpdateRequest rackCode(String? rackCode);

  EnclosureUpdateRequest levelCode(String? levelCode);

  EnclosureUpdateRequest dimensions(EnclosureDimensions? dimensions);

  EnclosureUpdateRequest cleanlinessState(CleanlinessState? cleanlinessState);

  EnclosureUpdateRequest capacity(int? capacity);

  EnclosureUpdateRequest equipment(List<String>? equipment);

  EnclosureUpdateRequest lastCleanedAt(DateTime? lastCleanedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureUpdateRequest call({
    String? code,
    String? rackCode,
    String? levelCode,
    EnclosureDimensions? dimensions,
    CleanlinessState? cleanlinessState,
    int? capacity,
    List<String>? equipment,
    DateTime? lastCleanedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfEnclosureUpdateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfEnclosureUpdateRequest.copyWith.fieldName(...)`
class _$EnclosureUpdateRequestCWProxyImpl
    implements _$EnclosureUpdateRequestCWProxy {
  const _$EnclosureUpdateRequestCWProxyImpl(this._value);

  final EnclosureUpdateRequest _value;

  @override
  EnclosureUpdateRequest code(String? code) => this(code: code);

  @override
  EnclosureUpdateRequest rackCode(String? rackCode) => this(rackCode: rackCode);

  @override
  EnclosureUpdateRequest levelCode(String? levelCode) =>
      this(levelCode: levelCode);

  @override
  EnclosureUpdateRequest dimensions(EnclosureDimensions? dimensions) =>
      this(dimensions: dimensions);

  @override
  EnclosureUpdateRequest cleanlinessState(CleanlinessState? cleanlinessState) =>
      this(cleanlinessState: cleanlinessState);

  @override
  EnclosureUpdateRequest capacity(int? capacity) => this(capacity: capacity);

  @override
  EnclosureUpdateRequest equipment(List<String>? equipment) =>
      this(equipment: equipment);

  @override
  EnclosureUpdateRequest lastCleanedAt(DateTime? lastCleanedAt) =>
      this(lastCleanedAt: lastCleanedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `EnclosureUpdateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// EnclosureUpdateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  EnclosureUpdateRequest call({
    Object? code = const $CopyWithPlaceholder(),
    Object? rackCode = const $CopyWithPlaceholder(),
    Object? levelCode = const $CopyWithPlaceholder(),
    Object? dimensions = const $CopyWithPlaceholder(),
    Object? cleanlinessState = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? equipment = const $CopyWithPlaceholder(),
    Object? lastCleanedAt = const $CopyWithPlaceholder(),
  }) {
    return EnclosureUpdateRequest(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String?,
      rackCode: rackCode == const $CopyWithPlaceholder()
          ? _value.rackCode
          // ignore: cast_nullable_to_non_nullable
          : rackCode as String?,
      levelCode: levelCode == const $CopyWithPlaceholder()
          ? _value.levelCode
          // ignore: cast_nullable_to_non_nullable
          : levelCode as String?,
      dimensions: dimensions == const $CopyWithPlaceholder()
          ? _value.dimensions
          // ignore: cast_nullable_to_non_nullable
          : dimensions as EnclosureDimensions?,
      cleanlinessState: cleanlinessState == const $CopyWithPlaceholder()
          ? _value.cleanlinessState
          // ignore: cast_nullable_to_non_nullable
          : cleanlinessState as CleanlinessState?,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as int?,
      equipment: equipment == const $CopyWithPlaceholder()
          ? _value.equipment
          // ignore: cast_nullable_to_non_nullable
          : equipment as List<String>?,
      lastCleanedAt: lastCleanedAt == const $CopyWithPlaceholder()
          ? _value.lastCleanedAt
          // ignore: cast_nullable_to_non_nullable
          : lastCleanedAt as DateTime?,
    );
  }
}

extension $EnclosureUpdateRequestCopyWith on EnclosureUpdateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfEnclosureUpdateRequest.copyWith(...)` or like so:`instanceOfEnclosureUpdateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$EnclosureUpdateRequestCWProxy get copyWith =>
      _$EnclosureUpdateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EnclosureUpdateRequest _$EnclosureUpdateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'EnclosureUpdateRequest',
  json,
  ($checkedConvert) {
    final val = EnclosureUpdateRequest(
      code: $checkedConvert('code', (v) => v as String?),
      rackCode: $checkedConvert('rack_code', (v) => v as String?),
      levelCode: $checkedConvert('level_code', (v) => v as String?),
      dimensions: $checkedConvert(
        'dimensions',
        (v) => v == null
            ? null
            : EnclosureDimensions.fromJson(v as Map<String, dynamic>),
      ),
      cleanlinessState: $checkedConvert(
        'cleanliness_state',
        (v) => $enumDecodeNullable(_$CleanlinessStateEnumMap, v),
      ),
      capacity: $checkedConvert('capacity', (v) => (v as num?)?.toInt()),
      equipment: $checkedConvert(
        'equipment',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      lastCleanedAt: $checkedConvert(
        'last_cleaned_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'rackCode': 'rack_code',
    'levelCode': 'level_code',
    'cleanlinessState': 'cleanliness_state',
    'lastCleanedAt': 'last_cleaned_at',
  },
);

Map<String, dynamic> _$EnclosureUpdateRequestToJson(
  EnclosureUpdateRequest instance,
) => <String, dynamic>{
  'code': ?instance.code,
  'rack_code': ?instance.rackCode,
  'level_code': ?instance.levelCode,
  'dimensions': ?instance.dimensions?.toJson(),
  'cleanliness_state': ?_$CleanlinessStateEnumMap[instance.cleanlinessState],
  'capacity': ?instance.capacity,
  'equipment': ?instance.equipment,
  'last_cleaned_at': ?instance.lastCleanedAt?.toIso8601String(),
};

const _$CleanlinessStateEnumMap = {
  CleanlinessState.clean: 'clean',
  CleanlinessState.partialDue: 'partial_due',
  CleanlinessState.fullDue: 'full_due',
};
