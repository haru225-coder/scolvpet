// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_growth_consult_response_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PublicGrowthConsultResponseDataCWProxy {
  PublicGrowthConsultResponseData sessionToken(String sessionToken);

  PublicGrowthConsultResponseData consultationId(String consultationId);

  PublicGrowthConsultResponseData answer(String answer);

  PublicGrowthConsultResponseData recommendations(
    List<Map<String, Object>> recommendations,
  );

  PublicGrowthConsultResponseData facts(List<GrowthPublicFact> facts);

  PublicGrowthConsultResponseData handoffSuggested(bool handoffSuggested);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthConsultResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthConsultResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthConsultResponseData call({
    String sessionToken,
    String consultationId,
    String answer,
    List<Map<String, Object>> recommendations,
    List<GrowthPublicFact> facts,
    bool handoffSuggested,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPublicGrowthConsultResponseData.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPublicGrowthConsultResponseData.copyWith.fieldName(...)`
class _$PublicGrowthConsultResponseDataCWProxyImpl
    implements _$PublicGrowthConsultResponseDataCWProxy {
  const _$PublicGrowthConsultResponseDataCWProxyImpl(this._value);

  final PublicGrowthConsultResponseData _value;

  @override
  PublicGrowthConsultResponseData sessionToken(String sessionToken) =>
      this(sessionToken: sessionToken);

  @override
  PublicGrowthConsultResponseData consultationId(String consultationId) =>
      this(consultationId: consultationId);

  @override
  PublicGrowthConsultResponseData answer(String answer) => this(answer: answer);

  @override
  PublicGrowthConsultResponseData recommendations(
    List<Map<String, Object>> recommendations,
  ) => this(recommendations: recommendations);

  @override
  PublicGrowthConsultResponseData facts(List<GrowthPublicFact> facts) =>
      this(facts: facts);

  @override
  PublicGrowthConsultResponseData handoffSuggested(bool handoffSuggested) =>
      this(handoffSuggested: handoffSuggested);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PublicGrowthConsultResponseData(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PublicGrowthConsultResponseData(...).copyWith(id: 12, name: "My name")
  /// ````
  PublicGrowthConsultResponseData call({
    Object? sessionToken = const $CopyWithPlaceholder(),
    Object? consultationId = const $CopyWithPlaceholder(),
    Object? answer = const $CopyWithPlaceholder(),
    Object? recommendations = const $CopyWithPlaceholder(),
    Object? facts = const $CopyWithPlaceholder(),
    Object? handoffSuggested = const $CopyWithPlaceholder(),
  }) {
    return PublicGrowthConsultResponseData(
      sessionToken: sessionToken == const $CopyWithPlaceholder()
          ? _value.sessionToken
          // ignore: cast_nullable_to_non_nullable
          : sessionToken as String,
      consultationId: consultationId == const $CopyWithPlaceholder()
          ? _value.consultationId
          // ignore: cast_nullable_to_non_nullable
          : consultationId as String,
      answer: answer == const $CopyWithPlaceholder()
          ? _value.answer
          // ignore: cast_nullable_to_non_nullable
          : answer as String,
      recommendations: recommendations == const $CopyWithPlaceholder()
          ? _value.recommendations
          // ignore: cast_nullable_to_non_nullable
          : recommendations as List<Map<String, Object>>,
      facts: facts == const $CopyWithPlaceholder()
          ? _value.facts
          // ignore: cast_nullable_to_non_nullable
          : facts as List<GrowthPublicFact>,
      handoffSuggested: handoffSuggested == const $CopyWithPlaceholder()
          ? _value.handoffSuggested
          // ignore: cast_nullable_to_non_nullable
          : handoffSuggested as bool,
    );
  }
}

extension $PublicGrowthConsultResponseDataCopyWith
    on PublicGrowthConsultResponseData {
  /// Returns a callable class that can be used as follows: `instanceOfPublicGrowthConsultResponseData.copyWith(...)` or like so:`instanceOfPublicGrowthConsultResponseData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PublicGrowthConsultResponseDataCWProxy get copyWith =>
      _$PublicGrowthConsultResponseDataCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublicGrowthConsultResponseData _$PublicGrowthConsultResponseDataFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PublicGrowthConsultResponseData',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'session_token',
        'consultation_id',
        'answer',
        'recommendations',
        'facts',
        'handoff_suggested',
      ],
    );
    final val = PublicGrowthConsultResponseData(
      sessionToken: $checkedConvert('session_token', (v) => v as String),
      consultationId: $checkedConvert('consultation_id', (v) => v as String),
      answer: $checkedConvert('answer', (v) => v as String),
      recommendations: $checkedConvert(
        'recommendations',
        (v) => (v as List<dynamic>)
            .map(
              (e) => (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(k, e as Object),
              ),
            )
            .toList(),
      ),
      facts: $checkedConvert(
        'facts',
        (v) => (v as List<dynamic>)
            .map((e) => GrowthPublicFact.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      handoffSuggested: $checkedConvert('handoff_suggested', (v) => v as bool),
    );
    return val;
  },
  fieldKeyMap: const {
    'sessionToken': 'session_token',
    'consultationId': 'consultation_id',
    'handoffSuggested': 'handoff_suggested',
  },
);

Map<String, dynamic> _$PublicGrowthConsultResponseDataToJson(
  PublicGrowthConsultResponseData instance,
) => <String, dynamic>{
  'session_token': instance.sessionToken,
  'consultation_id': instance.consultationId,
  'answer': instance.answer,
  'recommendations': instance.recommendations,
  'facts': instance.facts.map((e) => e.toJson()).toList(),
  'handoff_suggested': instance.handoffSuggested,
};
