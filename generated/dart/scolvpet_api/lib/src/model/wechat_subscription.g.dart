// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wechat_subscription.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WechatSubscriptionCWProxy {
  WechatSubscription id(String id);

  WechatSubscription templateId(String templateId);

  WechatSubscription status(WechatSubscriptionStatusEnum status);

  WechatSubscription page(String? page);

  WechatSubscription grantedAt(DateTime grantedAt);

  WechatSubscription lastSentAt(DateTime? lastSentAt);

  WechatSubscription version(int version);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WechatSubscription(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WechatSubscription(...).copyWith(id: 12, name: "My name")
  /// ````
  WechatSubscription call({
    String id,
    String templateId,
    WechatSubscriptionStatusEnum status,
    String? page,
    DateTime grantedAt,
    DateTime? lastSentAt,
    int version,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWechatSubscription.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWechatSubscription.copyWith.fieldName(...)`
class _$WechatSubscriptionCWProxyImpl implements _$WechatSubscriptionCWProxy {
  const _$WechatSubscriptionCWProxyImpl(this._value);

  final WechatSubscription _value;

  @override
  WechatSubscription id(String id) => this(id: id);

  @override
  WechatSubscription templateId(String templateId) =>
      this(templateId: templateId);

  @override
  WechatSubscription status(WechatSubscriptionStatusEnum status) =>
      this(status: status);

  @override
  WechatSubscription page(String? page) => this(page: page);

  @override
  WechatSubscription grantedAt(DateTime grantedAt) =>
      this(grantedAt: grantedAt);

  @override
  WechatSubscription lastSentAt(DateTime? lastSentAt) =>
      this(lastSentAt: lastSentAt);

  @override
  WechatSubscription version(int version) => this(version: version);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `WechatSubscription(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// WechatSubscription(...).copyWith(id: 12, name: "My name")
  /// ````
  WechatSubscription call({
    Object? id = const $CopyWithPlaceholder(),
    Object? templateId = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? page = const $CopyWithPlaceholder(),
    Object? grantedAt = const $CopyWithPlaceholder(),
    Object? lastSentAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
  }) {
    return WechatSubscription(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      templateId: templateId == const $CopyWithPlaceholder()
          ? _value.templateId
          // ignore: cast_nullable_to_non_nullable
          : templateId as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as WechatSubscriptionStatusEnum,
      page: page == const $CopyWithPlaceholder()
          ? _value.page
          // ignore: cast_nullable_to_non_nullable
          : page as String?,
      grantedAt: grantedAt == const $CopyWithPlaceholder()
          ? _value.grantedAt
          // ignore: cast_nullable_to_non_nullable
          : grantedAt as DateTime,
      lastSentAt: lastSentAt == const $CopyWithPlaceholder()
          ? _value.lastSentAt
          // ignore: cast_nullable_to_non_nullable
          : lastSentAt as DateTime?,
      version: version == const $CopyWithPlaceholder()
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
    );
  }
}

extension $WechatSubscriptionCopyWith on WechatSubscription {
  /// Returns a callable class that can be used as follows: `instanceOfWechatSubscription.copyWith(...)` or like so:`instanceOfWechatSubscription.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WechatSubscriptionCWProxy get copyWith =>
      _$WechatSubscriptionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WechatSubscription _$WechatSubscriptionFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'WechatSubscription',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'id',
            'template_id',
            'status',
            'granted_at',
            'version',
          ],
        );
        final val = WechatSubscription(
          id: $checkedConvert('id', (v) => v as String),
          templateId: $checkedConvert('template_id', (v) => v as String),
          status: $checkedConvert(
            'status',
            (v) => $enumDecode(_$WechatSubscriptionStatusEnumEnumMap, v),
          ),
          page: $checkedConvert('page', (v) => v as String?),
          grantedAt: $checkedConvert(
            'granted_at',
            (v) => DateTime.parse(v as String),
          ),
          lastSentAt: $checkedConvert(
            'last_sent_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          version: $checkedConvert('version', (v) => (v as num).toInt()),
        );
        return val;
      },
      fieldKeyMap: const {
        'templateId': 'template_id',
        'grantedAt': 'granted_at',
        'lastSentAt': 'last_sent_at',
      },
    );

Map<String, dynamic> _$WechatSubscriptionToJson(WechatSubscription instance) =>
    <String, dynamic>{
      'id': instance.id,
      'template_id': instance.templateId,
      'status': _$WechatSubscriptionStatusEnumEnumMap[instance.status]!,
      'page': ?instance.page,
      'granted_at': instance.grantedAt.toIso8601String(),
      'last_sent_at': ?instance.lastSentAt?.toIso8601String(),
      'version': instance.version,
    };

const _$WechatSubscriptionStatusEnumEnumMap = {
  WechatSubscriptionStatusEnum.accept: 'accept',
  WechatSubscriptionStatusEnum.reject: 'reject',
  WechatSubscriptionStatusEnum.ban: 'ban',
  WechatSubscriptionStatusEnum.unknown: 'unknown',
};
