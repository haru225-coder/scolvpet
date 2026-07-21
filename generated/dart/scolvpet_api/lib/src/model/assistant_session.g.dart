// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_session.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantSessionCWProxy {
  AssistantSession id(String id);

  AssistantSession ownerId(String ownerId);

  AssistantSession title(String title);

  AssistantSession createdAt(DateTime createdAt);

  AssistantSession updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantSession(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantSession(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantSession call({
    String id,
    String ownerId,
    String title,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantSession.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantSession.copyWith.fieldName(...)`
class _$AssistantSessionCWProxyImpl implements _$AssistantSessionCWProxy {
  const _$AssistantSessionCWProxyImpl(this._value);

  final AssistantSession _value;

  @override
  AssistantSession id(String id) => this(id: id);

  @override
  AssistantSession ownerId(String ownerId) => this(ownerId: ownerId);

  @override
  AssistantSession title(String title) => this(title: title);

  @override
  AssistantSession createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  AssistantSession updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantSession(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantSession(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantSession call({
    Object? id = const $CopyWithPlaceholder(),
    Object? ownerId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return AssistantSession(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      ownerId: ownerId == const $CopyWithPlaceholder()
          ? _value.ownerId
          // ignore: cast_nullable_to_non_nullable
          : ownerId as String,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $AssistantSessionCopyWith on AssistantSession {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantSession.copyWith(...)` or like so:`instanceOfAssistantSession.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantSessionCWProxy get copyWith => _$AssistantSessionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantSession _$AssistantSessionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AssistantSession',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'owner_id',
            'title',
            'created_at',
            'updated_at',
          ],
        );
        final val = AssistantSession(
          id: $checkedConvert('id', (v) => v as String),
          ownerId: $checkedConvert('owner_id', (v) => v as String),
          title: $checkedConvert('title', (v) => v as String),
          createdAt: $checkedConvert(
            'created_at',
            (v) => DateTime.parse(v as String),
          ),
          updatedAt: $checkedConvert(
            'updated_at',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'ownerId': 'owner_id',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$AssistantSessionToJson(AssistantSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
