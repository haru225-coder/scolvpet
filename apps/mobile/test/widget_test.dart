import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

import 'package:scolvpet_mobile/core/app_state.dart';
import 'package:scolvpet_mobile/core/session_store.dart';
import 'package:scolvpet_mobile/data/i1_repository.dart';
import 'package:scolvpet_mobile/data/i2_repository.dart';
import 'package:scolvpet_mobile/features/breeding/breeding.dart';
import 'package:scolvpet_mobile/features/i2/i2_controller.dart';
import 'package:scolvpet_mobile/features/litter/litter.dart';
import 'package:scolvpet_mobile/features/pedigree/pedigree.dart';
import 'package:scolvpet_mobile/features/tasks/tasks.dart';
import 'package:scolvpet_mobile/ui/screens.dart';
import 'package:scolvpet_mobile/main.dart';

void main() {
  test(
    'AppState restores generated models into offline read-only state',
    () async {
      final state = AppState(
        repository: FakeRepository(offline: true),
        sessionStore: MemorySessionStore(snapshot: demoSnapshot),
      );

      await state.restore();

      expect(state.phase, AppPhase.home);
      expect(state.offline, isTrue);
      expect(state.account?.phoneMasked, '138****8000');
      expect(state.organization?.name, '雪团熊舍');
      expect(state.ownerRules.single.speciesCode, 'mesocricetus_auratus');
      expect(state.systemRules.single.sourceNote, 'I1 系统模板');
    },
  );

  testWidgets(
    'ScolvPetApp renders initialization, five navigation tabs and cached shell',
    (tester) async {
      final state = AppState(
        repository: FakeRepository(offline: true),
        sessionStore: MemorySessionStore(snapshot: demoSnapshot, delayed: true),
      );
      final i2Controller = I2Controller(repository: MemoryI2Repository());
      final breedingController = BreedingController(
        repository: MemoryBreedingRepository(),
      );
      final litterBoardController = LitterBoardController(
        repository: MemoryLitterBoardRepository(),
      );
      final taskController = TaskController(
        repository: MemoryTaskRepository(),
        notifications: MemoryLocalNotificationScheduler(),
      );

      await tester.pumpWidget(
        ScolvPetApp(
          state: state,
          i2Controller: i2Controller,
          breedingController: breedingController,
          litterBoardController: litterBoardController,
          taskController: taskController,
          pedigreeRepository: MemoryPedigreeRepository(),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 40));
      await tester.pumpAndSettle();

      expect(find.byType(HomeShell), findsOneWidget);
      for (final label in ['今日', '仓鼠', '笼舍', '繁育', '我的']) {
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
      expect(find.text('快捷操作'), findsOneWidget);
      expect(find.text('在养'), findsOneWidget);
      expect(find.byKey(const Key('home-quick-litters')), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('繁育'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('繁育向导'), findsOneWidget);
      expect(find.text('窝次列表'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('我的'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('雪团熊舍'), findsOneWidget);
      expect(find.text('离线只读 · 联网后重新提交/再操作'), findsOneWidget);
      await tester.tap(find.text('数据中心'));
      await tester.pumpAndSettle();
      expect(find.text('数据搬家与空间概览'), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text('最近备份'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('物种规则'));
      await tester.pumpAndSettle();
      expect(find.text('mesocricetus_auratus'), findsWidgets);
      final copyButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, '复制'),
      );
      expect(copyButton.onPressed, isNull);
    },
  );
}

final demoSnapshot = SessionSnapshot(
  account: {
    'id': '00000000-0000-0000-0000-000000000001',
    'phone_masked': '138****8000',
    'display_name': '演示舍主一',
  },
  organization: {
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
  rules: [demoRule(owner: true)],
  systemRules: [demoRule(owner: false)],
);

Map<String, dynamic> demoRule({required bool owner}) => {
  'id': owner
      ? '00000000-0000-0000-0000-000000000301'
      : '00000000-0000-0000-0000-000000000201',
  'owner_id': owner ? '00000000-0000-0000-0000-000000000001' : null,
  'scope': owner ? 'owner' : 'system',
  'source_template_id': owner ? '00000000-0000-0000-0000-000000000201' : null,
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
  'source_note': owner ? 'I1 owner copy' : 'I1 系统模板',
  'version': 1,
  'effective_at': '2026-07-16T00:00:00Z',
  'frozen': true,
};

class MemorySessionStore implements SessionStorePort {
  MemorySessionStore({this.snapshot, this.delayed = false});

  final SessionSnapshot? snapshot;
  final bool delayed;

  @override
  Future<void> clear() async {}

  @override
  Future<SessionSnapshot?> readSnapshot() async {
    if (delayed) await Future<void>.delayed(const Duration(milliseconds: 20));
    return snapshot;
  }

  @override
  Future<String?> readAccessToken() async {
    if (delayed) await Future<void>.delayed(const Duration(milliseconds: 20));
    return 'cached-access-token';
  }

  @override
  Future<String?> readRefreshToken() async => 'cached-refresh-token';

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {}

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

class FakeRepository implements I1Repository {
  FakeRepository({required this.offline});

  final bool offline;

  DioException get networkError => DioException(
    requestOptions: RequestOptions(path: '/v1/me'),
    type: DioExceptionType.connectionError,
  );

  @override
  Future<SpeciesRuleVersion> copyRule(SpeciesRuleVersion template) async {
    if (offline) throw networkError;
    return template;
  }

  @override
  Future<CurrentAccountResponseData> getCurrentAccount() async {
    throw networkError;
  }

  @override
  Future<SessionResponseData> login({
    required String phone,
    required String verificationId,
    required String code,
  }) async => throw networkError;

  @override
  Future<void> logout() async {}

  @override
  Future<SessionResponseData> refresh(String refreshToken) async {
    throw networkError;
  }

  @override
  Future<String> requestCode(String phone) async => throw networkError;

  @override
  Future<List<SpeciesRuleVersion>> listOwnerRules() async {
    throw networkError;
  }

  @override
  Future<List<SpeciesRuleVersion>> listSystemRules() async {
    throw networkError;
  }

  @override
  Future<Organization> updateOrganization({
    required String name,
    required int version,
  }) async => throw networkError;
}
