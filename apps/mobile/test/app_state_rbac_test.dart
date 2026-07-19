import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scolvpet_api/scolvpet_api.dart';
import 'package:scolvpet_mobile/core/app_state.dart';
import 'package:scolvpet_mobile/core/session_store.dart';
import 'package:scolvpet_mobile/data/i1_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('restore uses /me role and persists capabilities in snapshot', () async {
    final store = _MemorySessionStore(accessToken: 'access');
    final repository = _FakeI1Repository(
      current: _currentAccount(
        role: 'staff',
        capabilities: const [
          'member_role:staff',
          'tenant_scope',
          'offline_read_cache',
          AppCapability.writeHamster,
          AppCapability.writeCrm,
          AppCapability.writeDocuments,
          AppCapability.writeGrowth,
        ],
      ),
    );
    final state = AppState(repository: repository, sessionStore: store);

    await state.restore();

    expect(state.phase, AppPhase.home);
    expect(state.currentMemberRole, 'staff');
    expect(state.hasCapability(AppCapability.writeCrm), isTrue);
    expect(state.hasCapability(AppCapability.writeBreeding), isFalse);
    expect(store.savedSnapshot?.currentMemberRole, 'staff');
    expect(
      store.savedSnapshot?.capabilities,
      contains(AppCapability.writeDocuments),
    );
  });

  test(
    'login refreshes /me and skips owner setup for invited member',
    () async {
      final store = _MemorySessionStore();
      final repository = _FakeI1Repository(
        loginSession: _session(
          role: 'viewer',
          capabilities: const [
            'member_role:viewer',
            'tenant_scope',
            'offline_read_cache',
          ],
        ),
        current: _currentAccount(
          role: 'caretaker',
          capabilities: const [
            'member_role:caretaker',
            'tenant_scope',
            'offline_read_cache',
            AppCapability.writeLitter,
            AppCapability.writeHamster,
            AppCapability.writeEnclosure,
            AppCapability.writeWeight,
            AppCapability.writeTask,
            AppCapability.writeHealth,
            AppCapability.writeMedia,
          ],
        ),
      );
      final state = AppState(repository: repository, sessionStore: store);

      await state.requestCode('+8613800138000');
      await state.login('123456');

      expect(repository.currentAccountCalls, 1);
      expect(state.phase, AppPhase.home);
      expect(state.currentMemberRole, 'caretaker');
      expect(state.hasCapability(AppCapability.writeEnclosure), isTrue);
      expect(state.hasCapability(AppCapability.writeCrm), isFalse);
    },
  );

  test('offline restore keeps cached member role and capabilities', () async {
    final snapshot = SessionSnapshot(
      account: _accountJson,
      organization: _organizationJson,
      currentMemberRole: 'breeder',
      capabilities: const [
        'member_role:breeder',
        'tenant_scope',
        'offline_read_cache',
        AppCapability.writeBreeding,
        AppCapability.writeLitter,
        AppCapability.writeHamster,
      ],
    );
    final networkError = DioException(
      requestOptions: RequestOptions(path: '/v1/me'),
      type: DioExceptionType.connectionError,
    );
    final store = _MemorySessionStore(
      accessToken: 'access',
      refreshToken: 'refresh',
      snapshot: snapshot,
    );
    final repository = _FakeI1Repository(
      currentError: networkError,
      currentFailuresBeforeSuccess: 1,
      refreshError: networkError,
    );
    final state = AppState(repository: repository, sessionStore: store);

    await state.restore();

    expect(state.phase, AppPhase.home);
    expect(state.offline, isTrue);
    expect(state.currentMemberRole, 'breeder');
    expect(state.hasCapability(AppCapability.writeBreeding), isTrue);
    expect(state.hasCapability(AppCapability.writeEnclosure), isFalse);
  });

  test(
    'expired access token refreshes session then reloads /me role',
    () async {
      final expiredError = DioException(
        requestOptions: RequestOptions(path: '/v1/me'),
        response: Response<void>(
          requestOptions: RequestOptions(path: '/v1/me'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );
      final store = _MemorySessionStore(
        accessToken: 'expired-access',
        refreshToken: 'refresh',
      );
      final repository = _FakeI1Repository(
        current: _currentAccount(
          role: 'staff',
          capabilities: const [
            'member_role:staff',
            'tenant_scope',
            'offline_read_cache',
            AppCapability.writeCrm,
            AppCapability.writeDocuments,
          ],
        ),
        currentError: expiredError,
        currentFailuresBeforeSuccess: 1,
      );
      final state = AppState(repository: repository, sessionStore: store);

      await state.restore();

      expect(repository.currentAccountCalls, 2);
      expect(state.phase, AppPhase.home);
      expect(state.currentMemberRole, 'staff');
      expect(state.hasCapability(AppCapability.writeDocuments), isTrue);
    },
  );

  test('SessionStore round-trips authorization fields', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SessionStore();
    const snapshot = SessionSnapshot(
      currentMemberRole: 'viewer',
      capabilities: [
        'member_role:viewer',
        'tenant_scope',
        'offline_read_cache',
      ],
    );

    await store.saveSnapshot(snapshot);
    final restored = await store.readSnapshot();

    expect(restored?.currentMemberRole, 'viewer');
    expect(restored?.capabilities, snapshot.capabilities);
  });
}

class _MemorySessionStore implements SessionStorePort {
  _MemorySessionStore({this.accessToken, this.refreshToken, this.snapshot});

  final String? accessToken;
  final String? refreshToken;
  final SessionSnapshot? snapshot;
  SessionSnapshot? savedSnapshot;

  @override
  Future<void> clear() async {}

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<SessionSnapshot?> readSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {
    savedSnapshot = snapshot;
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
}

class _FakeI1Repository implements I1Repository {
  _FakeI1Repository({
    this.current,
    this.loginSession,
    this.currentError,
    this.currentFailuresBeforeSuccess = 0,
    this.refreshError,
  });

  final CurrentAccountResponseData? current;
  final SessionResponseData? loginSession;
  final Object? currentError;
  final int currentFailuresBeforeSuccess;
  final Object? refreshError;
  int currentAccountCalls = 0;

  @override
  Future<SpeciesRuleVersion> copyRule(SpeciesRuleVersion template) async =>
      template;

  @override
  Future<CurrentAccountResponseData> getCurrentAccount() async {
    currentAccountCalls++;
    final error = currentError;
    if (currentAccountCalls <= currentFailuresBeforeSuccess && error != null) {
      throw error;
    }
    return current ?? _currentAccount(role: 'owner');
  }

  @override
  Future<SessionResponseData> login({
    required String phone,
    required String verificationId,
    required String code,
  }) async => loginSession ?? _session(role: 'owner');

  @override
  Future<void> logout() async {}

  @override
  Future<SessionResponseData> refresh(String refreshToken) async {
    if (refreshError case final error?) throw error;
    return _session(role: 'owner');
  }

  @override
  Future<String> requestCode(String phone) async => 'verification-id';

  @override
  Future<List<SpeciesRuleVersion>> listOwnerRules() async => const [];

  @override
  Future<List<SpeciesRuleVersion>> listSystemRules() async => const [];

  @override
  Future<Organization> updateOrganization({
    required String name,
    required int version,
  }) async => Organization.fromJson({..._organizationJson, 'name': name});
}

CurrentAccountResponseData _currentAccount({
  required String role,
  List<String>? capabilities,
}) => CurrentAccountResponseData.fromJson({
  'account': _accountJson,
  'current_organization': _organizationJson,
  'member_role': role,
  'capabilities': capabilities ?? _capabilitiesFor(role),
});

SessionResponseData _session({
  required String role,
  List<String>? capabilities,
}) => SessionResponseData.fromJson({
  'token_type': 'Bearer',
  'access_token': 'access-next',
  'expires_in_seconds': 3600,
  'refresh_token': 'refresh-next',
  'account': _accountJson,
  'current_organization': _organizationJson,
  'member_role': role,
  'capabilities': capabilities ?? _capabilitiesFor(role),
});

List<String> _capabilitiesFor(String role) => [
  'member_role:$role',
  'tenant_scope',
  'offline_read_cache',
];

const _accountJson = <String, dynamic>{
  'id': '00000000-0000-0000-0000-000000000002',
  'phone_masked': '138****8000',
  'display_name': '受邀成员',
};

const _organizationJson = <String, dynamic>{
  'id': '00000000-0000-0000-0000-000000000101',
  'owner_id': '00000000-0000-0000-0000-000000000001',
  'name': '雪团熊舍',
  'mode': 'personal',
  'timezone': 'Asia/Shanghai',
  'weight_unit': 'g',
  'version': 1,
  'created_at': '2026-07-16T00:00:00Z',
  'updated_at': '2026-07-16T00:00:00Z',
};
