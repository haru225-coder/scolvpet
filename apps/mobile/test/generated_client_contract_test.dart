import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

void main() {
  test(
    'generated dart-dio models deserialize I1 refresh/session responses',
    () {
      final refresh = RefreshSessionRequest.fromJson({
        'refresh_token': 'rt_i1',
      });
      expect(refresh.refreshToken, 'rt_i1');
      expect(refresh.toJson(), {'refresh_token': 'rt_i1'});

      final session = SessionResponse.fromJson({
        'data': {
          'token_type': 'Bearer',
          'access_token': 'at_i1',
          'expires_in_seconds': 3600,
          'refresh_token': 'rt_i1_next',
          'account': {
            'id': '00000000-0000-0000-0000-000000000001',
            'phone_masked': '138****8000',
            'display_name': null,
          },
          'current_organization': {
            'id': '00000000-0000-0000-0000-000000000101',
            'owner_id': '00000000-0000-0000-0000-000000000001',
            'name': '雪团熊舍',
            'mode': 'personal',
            'timezone': 'Asia/Shanghai',
            'weight_unit': 'g',
            'version': 1,
            'created_at': '2026-07-16T00:00:00Z',
            'updated_at': '2026-07-16T00:00:00Z',
          },
          'member_role': 'owner',
          'capabilities': ['org.manage', 'hamster.write', 'breeding.write'],
        },
        'meta': {
          'request_id': 'req_i1',
          'generated_at': '2026-07-16T00:00:00Z',
          'timezone': 'Asia/Shanghai',
        },
      });
      expect(session.data.accessToken, 'at_i1');
      expect(session.data.currentOrganization.name, '雪团熊舍');
      expect(session.data.memberRole.value, 'owner');
      expect(session.data.capabilities, contains('hamster.write'));
    },
  );

  test(
    'generated rule model accepts contract fields and excludes display_name',
    () {
      final rule = SpeciesRuleVersion.fromJson({
        'id': '00000000-0000-0000-0000-000000000201',
        'owner_id': null,
        'scope': 'system',
        'source_template_id': null,
        'species_code': 'mesocricetus_auratus',
        'variety_scope': ['golden'],
        'gestation_min_days': 16,
        'gestation_max_days': 18,
        'pairing_max_minutes': 15,
        'weaning_target_days': 21,
        'sexing_target_days': 28,
        'separation_target_days': 35,
        'post_breeding_rest_days': 7,
        'profile_creation_deadline_days': 42,
        'weight_reference': {'unit': 'g'},
        'source_note': 'I1 system rule',
        'version': 1,
        'effective_at': '2026-07-16T00:00:00Z',
        'frozen': true,
      });
      expect(rule.speciesCode, 'mesocricetus_auratus');
      expect(rule.toJson().containsKey('display_name'), isFalse);
    },
  );

  test(
    'generated DefaultApi exposes getPublicShareMedia as binary Uint8List',
    () {
      // Contract check: OpenAPI operationId getPublicShareMedia must stay
      // generated as a binary GET that returns Response<Uint8List> with
      // ResponseType.bytes (compile-time signature + runtime method presence).
      final api = DefaultApi(Dio());
      Future<Response<Uint8List>> Function({
        required String token,
        required String mediaId,
        CancelToken? cancelToken,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? extra,
        ValidateStatus? validateStatus,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      })
      typed = api.getPublicShareMedia;
      expect(typed, isNotNull);
      expect(
        ScolvpetApi().getDefaultApi().getPublicShareMedia,
        isA<Function>(),
      );
    },
  );
}
