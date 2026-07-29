// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_wechat_subscriptions_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpsertWechatSubscriptionsRequestCWProxy {
  UpsertWechatSubscriptionsRequest templates(
    Map<String, UpsertWechatSubscriptionsRequestTemplatesEnum> templates,
  );

  UpsertWechatSubscriptionsRequest page(String? page);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertWechatSubscriptionsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertWechatSubscriptionsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertWechatSubscriptionsRequest call({
    Map<String, UpsertWechatSubscriptionsRequestTemplatesEnum> templates,
    String? page,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpsertWechatSubscriptionsRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpsertWechatSubscriptionsRequest.copyWith.fieldName(...)`
class _$UpsertWechatSubscriptionsRequestCWProxyImpl
    implements _$UpsertWechatSubscriptionsRequestCWProxy {
  const _$UpsertWechatSubscriptionsRequestCWProxyImpl(this._value);

  final UpsertWechatSubscriptionsRequest _value;

  @override
  UpsertWechatSubscriptionsRequest templates(
    Map<String, UpsertWechatSubscriptionsRequestTemplatesEnum> templates,
  ) => this(templates: templates);

  @override
  UpsertWechatSubscriptionsRequest page(String? page) => this(page: page);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpsertWechatSubscriptionsRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpsertWechatSubscriptionsRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpsertWechatSubscriptionsRequest call({
    Object? templates = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
  }) {
    return UpsertWechatSubscriptionsRequest(
      templates: templates == const $CopyWithPlaceholder()
          ? _value.templates
          // ignore: cast_nullable_to_non_nullable
          : templates
                as Map<String, UpsertWechatSubscriptionsRequestTemplatesEnum>,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as String?,
    );
  }
}

extension $UpsertWechatSubscriptionsRequestCopyWith
    on UpsertWechatSubscriptionsRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpsertWechatSubscriptionsRequest.copyWith(...)` or like so:`instanceOfUpsertWechatSubscriptionsRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpsertWechatSubscriptionsRequestCWProxy get copyWith =>
      _$UpsertWechatSubscriptionsRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpsertWechatSubscriptionsRequest _$UpsertWechatSubscriptionsRequestFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('UpsertWechatSubscriptionsRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['templates']);
      final val = UpsertWechatSubscriptionsRequest(
        templates: $checkedConvert(
          'templates',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(
              k,
              $enumDecode(
                _$UpsertWechatSubscriptionsRequestTemplatesEnumEnumMap,
                e,
              ),
            ),
          ),
        ),
        page: $checkedConvert('page', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$UpsertWechatSubscriptionsRequestToJson(
  UpsertWechatSubscriptionsRequest instance,
) => <String, dynamic>{
  'templates': instance.templates.map(
    (k, e) =>
        MapEntry(k, _$UpsertWechatSubscriptionsRequestTemplatesEnumEnumMap[e]!),
  ),
  'page': ?instance.page,
};

const _$UpsertWechatSubscriptionsRequestTemplatesEnumEnumMap = {
  UpsertWechatSubscriptionsRequestTemplatesEnum.accept: 'accept',
  UpsertWechatSubscriptionsRequestTemplatesEnum.reject: 'reject',
  UpsertWechatSubscriptionsRequestTemplatesEnum.ban: 'ban',
  UpsertWechatSubscriptionsRequestTemplatesEnum.unknown: 'unknown',
};
