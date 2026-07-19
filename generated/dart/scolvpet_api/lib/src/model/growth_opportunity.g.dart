// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_opportunity.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GrowthOpportunityCWProxy {
  GrowthOpportunity kind(String kind);

  GrowthOpportunity hamsterId(String hamsterId);

  GrowthOpportunity title(String title);

  GrowthOpportunity reason(String reason);

  GrowthOpportunity priority(int priority);

  GrowthOpportunity suggestion(String suggestion);

  GrowthOpportunity publicName(String? publicName);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthOpportunity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthOpportunity(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthOpportunity call({
    String kind,
    String hamsterId,
    String title,
    String reason,
    int priority,
    String suggestion,
    String? publicName,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGrowthOpportunity.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGrowthOpportunity.copyWith.fieldName(...)`
class _$GrowthOpportunityCWProxyImpl implements _$GrowthOpportunityCWProxy {
  const _$GrowthOpportunityCWProxyImpl(this._value);

  final GrowthOpportunity _value;

  @override
  GrowthOpportunity kind(String kind) => this(kind: kind);

  @override
  GrowthOpportunity hamsterId(String hamsterId) => this(hamsterId: hamsterId);

  @override
  GrowthOpportunity title(String title) => this(title: title);

  @override
  GrowthOpportunity reason(String reason) => this(reason: reason);

  @override
  GrowthOpportunity priority(int priority) => this(priority: priority);

  @override
  GrowthOpportunity suggestion(String suggestion) =>
      this(suggestion: suggestion);

  @override
  GrowthOpportunity publicName(String? publicName) =>
      this(publicName: publicName);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GrowthOpportunity(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GrowthOpportunity(...).copyWith(id: 12, name: "My name")
  /// ````
  GrowthOpportunity call({
    Object? kind = const $CopyWithPlaceholder(),
    Object? hamsterId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? priority = const $CopyWithPlaceholder(),
    Object? suggestion = const $CopyWithPlaceholder(),
    Object? publicName = const $CopyWithPlaceholder(),
  }) {
    return GrowthOpportunity(
      kind: kind == const $CopyWithPlaceholder()
          ? _value.kind
          // ignore: cast_nullable_to_non_nullable
          : kind as String,
      hamsterId: hamsterId == const $CopyWithPlaceholder()
          ? _value.hamsterId
          // ignore: cast_nullable_to_non_nullable
          : hamsterId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      priority: priority == const $CopyWithPlaceholder()
          ? _value.priority
          // ignore: cast_nullable_to_non_nullable
          : priority as int,
      suggestion: suggestion == const $CopyWithPlaceholder()
          ? _value.suggestion
          // ignore: cast_nullable_to_non_nullable
          : suggestion as String,
      publicName: publicName == const $CopyWithPlaceholder()
          ? _value.publicName
          // ignore: cast_nullable_to_non_nullable
          : publicName as String?,
    );
  }
}

extension $GrowthOpportunityCopyWith on GrowthOpportunity {
  /// Returns a callable class that can be used as follows: `instanceOfGrowthOpportunity.copyWith(...)` or like so:`instanceOfGrowthOpportunity.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GrowthOpportunityCWProxy get copyWith =>
      _$GrowthOpportunityCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrowthOpportunity _$GrowthOpportunityFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'GrowthOpportunity',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'kind',
            'hamster_id',
            'title',
            'reason',
            'priority',
            'suggestion',
          ],
        );
        final val = GrowthOpportunity(
          kind: $checkedConvert('kind', (v) => v as String),
          hamsterId: $checkedConvert('hamster_id', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          reason: $checkedConvert('reason', (v) => v as String),
          priority: $checkedConvert('priority', (v) => (v as num).toInt()),
          suggestion: $checkedConvert('suggestion', (v) => v as String),
          publicName: $checkedConvert('public_name', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'hamsterId': 'hamster_id',
        'publicName': 'public_name',
      },
    );

Map<String, dynamic> _$GrowthOpportunityToJson(GrowthOpportunity instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'hamster_id': instance.hamsterId,
      'title': instance.title,
      'reason': instance.reason,
      'priority': instance.priority,
      'suggestion': instance.suggestion,
      'public_name': ?instance.publicName,
    };
