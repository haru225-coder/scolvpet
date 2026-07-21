// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_session_create_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AssistantSessionCreateRequestCWProxy {
  AssistantSessionCreateRequest title(String? title);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantSessionCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantSessionCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantSessionCreateRequest call({String? title});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAssistantSessionCreateRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAssistantSessionCreateRequest.copyWith.fieldName(...)`
class _$AssistantSessionCreateRequestCWProxyImpl
    implements _$AssistantSessionCreateRequestCWProxy {
  const _$AssistantSessionCreateRequestCWProxyImpl(this._value);

  final AssistantSessionCreateRequest _value;

  @override
  AssistantSessionCreateRequest title(String? title) => this(title: title);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AssistantSessionCreateRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AssistantSessionCreateRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AssistantSessionCreateRequest call({
    Object? title = const $CopyWithPlaceholder(),
  }) {
    return AssistantSessionCreateRequest(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
    );
  }
}

extension $AssistantSessionCreateRequestCopyWith
    on AssistantSessionCreateRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAssistantSessionCreateRequest.copyWith(...)` or like so:`instanceOfAssistantSessionCreateRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AssistantSessionCreateRequestCWProxy get copyWith =>
      _$AssistantSessionCreateRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantSessionCreateRequest _$AssistantSessionCreateRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantSessionCreateRequest', json, ($checkedConvert) {
  final val = AssistantSessionCreateRequest(
    title: $checkedConvert('title', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AssistantSessionCreateRequestToJson(
  AssistantSessionCreateRequest instance,
) => <String, dynamic>{'title': ?instance.title};
