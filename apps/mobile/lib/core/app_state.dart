import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

import '../data/i1_repository.dart';
import 'session_store.dart';

enum AppPhase { restoring, login, code, setup, home }

class AppCapability {
  const AppCapability._();

  static const manageMembers = 'manage_members';
  static const writeBreeding = 'write_breeding';
  static const writeLitter = 'write_litter';
  static const writeHamster = 'write_hamster';
  static const writeEnclosure = 'write_enclosure';
  static const writeWeight = 'write_weight';
  static const writeTask = 'write_task';
  static const writeHealth = 'write_health';
  static const writeImport = 'write_import';
  static const writeMedia = 'write_media';
  static const writeCrm = 'write_crm';
  static const writeDocuments = 'write_documents';
  static const writeAccounting = 'write_accounting';
  static const writeGrowth = 'write_growth';
}

class AppState extends ChangeNotifier {
  AppState({
    required I1Repository repository,
    required SessionStorePort sessionStore,
  }) : _repository = repository,
       _sessionStore = sessionStore;

  final I1Repository _repository;
  final SessionStorePort _sessionStore;
  AppPhase phase = AppPhase.restoring;
  bool offline = false;
  String? phone;
  String? verificationId;
  Account? account;
  Organization? organization;
  List<SpeciesRuleVersion> systemRules = [];
  List<SpeciesRuleVersion> ownerRules = [];
  String currentMemberRole = 'viewer';
  Set<String> capabilities = const <String>{};
  String? lastError;
  bool _authorizationResolved = false;

  bool hasCapability(String capability) => capabilities.contains(capability);

  Future<void> restore() async {
    try {
      final token = await _sessionStore.readAccessToken();
      if (token == null) {
        phase = AppPhase.login;
        return;
      }
      try {
        final current = await _repository.getCurrentAccount();
        _applyCurrentAccount(current);
        await refreshRules();
        phase = AppPhase.home;
      } catch (currentError) {
        final refreshToken = await _sessionStore.readRefreshToken();
        try {
          if (refreshToken == null) throw StateError('missing refresh token');
          final session = await _repository.refresh(refreshToken);
          _applySession(session);
          try {
            _applyCurrentAccount(await _repository.getCurrentAccount());
          } on Object {
            if (!_authorizationResolved) rethrow;
          }
          await refreshRules();
          phase = AppPhase.home;
        } catch (refreshError) {
          if (_isOfflineError(currentError) || _isOfflineError(refreshError)) {
            final cached = await _readSnapshotSafely();
            if (cached?.organization != null && _restoreSnapshot(cached!)) {
              offline = true;
              phase = AppPhase.home;
            } else {
              phase = AppPhase.login;
            }
          } else {
            try {
              await _sessionStore.clear();
            } on Object {
              // The invalid remote session must not keep the UI in offline mode.
            }
            _clearIdentity();
            offline = false;
            phase = AppPhase.login;
          }
        }
      }
    } on Object {
      _clearIdentity();
      offline = false;
      phase = AppPhase.login;
    } finally {
      notifyListeners();
    }
  }

  bool busy = false;

  Future<void> requestCode(String value) async {
    final phoneValue = value.trim();
    phone = phoneValue;
    lastError = null;
    if (!_looksLikeCnPhone(phoneValue)) {
      lastError = '请输入有效的中国大陆手机号，例如 +8613800138000';
      notifyListeners();
      return;
    }
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      verificationId = await _repository.requestCode(phoneValue);
      offline = false;
      phase = AppPhase.code;
    } catch (error) {
      _captureError(error);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> resendCode() async {
    final current = phone;
    if (current == null || current.isEmpty) return;
    await requestCode(current);
  }

  void backToLogin() {
    phase = AppPhase.login;
    verificationId = null;
    lastError = null;
    busy = false;
    notifyListeners();
  }

  Future<void> login(String code) async {
    if (phone == null || verificationId == null) return;
    final trimmed = code.trim();
    if (trimmed.length != 6) {
      lastError = '请输入 6 位验证码';
      notifyListeners();
      return;
    }
    if (busy) return;
    lastError = null;
    busy = true;
    notifyListeners();
    try {
      final session = await _repository.login(
        phone: phone!,
        verificationId: verificationId!,
        code: trimmed,
      );
      _applySession(session);
      try {
        _applyCurrentAccount(await _repository.getCurrentAccount());
      } on Object {
        if (!_authorizationResolved) rethrow;
      }
      offline = false;
      phase = _needsSetup ? AppPhase.setup : AppPhase.home;
      await refreshRules();
    } catch (error) {
      _captureError(error);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  static bool _looksLikeCnPhone(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^\+86[1][3-9]\d{9}$').hasMatch(normalized) ||
        RegExp(r'^1[3-9]\d{9}$').hasMatch(normalized);
  }

  Future<void> completeSetup(String name) async {
    if (organization == null) return;
    if (offline) {
      lastError = '离线只读，联网后重新提交/再操作';
      notifyListeners();
      return;
    }
    if (busy) return;
    lastError = null;
    busy = true;
    notifyListeners();
    try {
      organization = await _repository.updateOrganization(
        name: name,
        version: organization!.version,
      );
      if (ownerRules.isEmpty && systemRules.isNotEmpty) {
        ownerRules = [await _repository.copyRule(systemRules.first)];
      }
      await _saveSnapshot();
      phase = AppPhase.home;
      offline = false;
    } catch (error) {
      _captureError(error);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refreshRules() async {
    try {
      systemRules = await _repository.listSystemRules();
      ownerRules = await _repository.listOwnerRules();
      await _saveSnapshot();
    } catch (error) {
      _captureError(error);
    }
  }

  Future<void> copyRule(SpeciesRuleVersion template) async {
    if (offline) {
      lastError = '离线只读，联网后重新提交/再操作';
      notifyListeners();
      return;
    }
    try {
      ownerRules = [...ownerRules, await _repository.copyRule(template)];
      await _saveSnapshot();
      lastError = null;
    } catch (error) {
      _captureError(error);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } on Object {
      // Local logout must still complete when the server is unreachable.
    }
    try {
      await _sessionStore.clear();
    } on Object {
      // SessionStore performs best-effort cleanup; keep the app logged out.
    }
    _clearIdentity();
    phone = null;
    verificationId = null;
    lastError = null;
    busy = false;
    phase = AppPhase.login;
    offline = false;
    notifyListeners();
  }

  Future<SessionSnapshot?> _readSnapshotSafely() async {
    try {
      return await _sessionStore.readSnapshot();
    } on Object {
      return null;
    }
  }

  Future<void> _saveSnapshot() async {
    await _sessionStore.saveSnapshot(
      SessionSnapshot(
        account: account?.toJson(),
        organization: organization?.toJson(),
        rules: ownerRules.map((rule) => rule.toJson()).toList(),
        systemRules: systemRules.map((rule) => rule.toJson()).toList(),
        currentMemberRole: currentMemberRole,
        capabilities: capabilities.toList()..sort(),
      ),
    );
  }

  bool _restoreSnapshot(SessionSnapshot snapshot) {
    try {
      final accountJson = snapshot.account;
      final organizationJson = snapshot.organization;
      if (accountJson == null || organizationJson == null) return false;
      account = Account.fromJson(Map<String, dynamic>.from(accountJson));
      organization = Organization.fromJson(
        Map<String, dynamic>.from(organizationJson),
      );
      ownerRules = (snapshot.rules ?? const <dynamic>[])
          .map(
            (value) => SpeciesRuleVersion.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList();
      systemRules = (snapshot.systemRules ?? const <dynamic>[])
          .map(
            (value) => SpeciesRuleVersion.fromJson(
              Map<String, dynamic>.from(value as Map),
            ),
          )
          .toList();
      _restoreAuthorization(snapshot);
      return true;
    } on Object {
      _clearIdentity();
      return false;
    }
  }

  void _applyCurrentAccount(CurrentAccountResponseData current) {
    account = current.account;
    organization = current.currentOrganization;
    _applyAuthorizationPayload(current.toJson());
  }

  void _applySession(SessionResponseData session) {
    account = session.account;
    organization = session.currentOrganization;
    _applyAuthorizationPayload(session.toJson());
  }

  void _applyAuthorizationPayload(Map<String, dynamic> payload) {
    final nextCapabilities = _normalizeCapabilities(payload['capabilities']);
    final explicitRole = _normalizeRole(payload['member_role']);
    final capabilityRole = _roleFromCapabilities(nextCapabilities);
    final resolvedRole = explicitRole ?? capabilityRole;
    if (resolvedRole != null) {
      currentMemberRole = resolvedRole;
      _authorizationResolved = true;
    } else if (!_authorizationResolved) {
      currentMemberRole = _ownershipFallbackRole();
    }
    capabilities = Set<String>.unmodifiable(
      nextCapabilities.isEmpty
          ? _fallbackCapabilities(currentMemberRole)
          : <String>{...nextCapabilities, 'member_role:$currentMemberRole'},
    );
  }

  void _restoreAuthorization(SessionSnapshot snapshot) {
    final snapshotCapabilities = snapshot.capabilities ?? const <String>[];
    final snapshotRole = _normalizeRole(snapshot.currentMemberRole);
    final capabilityRole = _roleFromCapabilities(snapshotCapabilities);
    currentMemberRole =
        snapshotRole ?? capabilityRole ?? _ownershipFallbackRole();
    _authorizationResolved = snapshotRole != null || capabilityRole != null;
    capabilities = Set<String>.unmodifiable(
      snapshotCapabilities.isEmpty
          ? _fallbackCapabilities(currentMemberRole)
          : <String>{...snapshotCapabilities, 'member_role:$currentMemberRole'},
    );
  }

  String _ownershipFallbackRole() {
    final accountId = account?.id;
    final ownerId = organization?.ownerId;
    return accountId != null && ownerId != null && accountId == ownerId
        ? 'owner'
        : 'viewer';
  }

  bool get _needsSetup =>
      currentMemberRole == 'owner' && organization?.name.trim() == '我的熊舍';

  void _clearIdentity() {
    account = null;
    organization = null;
    ownerRules = [];
    systemRules = [];
    currentMemberRole = 'viewer';
    capabilities = const <String>{};
    _authorizationResolved = false;
  }

  static Set<String> _normalizeCapabilities(Object? value) {
    if (value is! Iterable) return const <String>{};
    return value
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet();
  }

  static String? _normalizeRole(Object? value) {
    final role = value?.toString().trim().toLowerCase();
    return switch (role) {
      'owner' || 'breeder' || 'caretaker' || 'staff' || 'viewer' => role,
      _ => null,
    };
  }

  static String? _roleFromCapabilities(Iterable<String> values) {
    for (final value in values) {
      if (value.startsWith('member_role:')) {
        return _normalizeRole(value.substring('member_role:'.length));
      }
    }
    return null;
  }

  static Set<String> _fallbackCapabilities(String role) {
    final base = <String>{
      'member_role:$role',
      'tenant_scope',
      'offline_read_cache',
    };
    return switch (role) {
      'owner' => {
        ...base,
        AppCapability.manageMembers,
        AppCapability.writeBreeding,
        AppCapability.writeLitter,
        AppCapability.writeHamster,
        AppCapability.writeEnclosure,
        AppCapability.writeWeight,
        AppCapability.writeTask,
        AppCapability.writeHealth,
        AppCapability.writeImport,
        AppCapability.writeMedia,
        AppCapability.writeCrm,
        AppCapability.writeDocuments,
        AppCapability.writeAccounting,
        AppCapability.writeGrowth,
      },
      'breeder' => {
        ...base,
        AppCapability.writeBreeding,
        AppCapability.writeLitter,
        AppCapability.writeHamster,
        AppCapability.writeWeight,
        AppCapability.writeTask,
        AppCapability.writeHealth,
        AppCapability.writeMedia,
      },
      'caretaker' => {
        ...base,
        AppCapability.writeLitter,
        AppCapability.writeHamster,
        AppCapability.writeEnclosure,
        AppCapability.writeWeight,
        AppCapability.writeTask,
        AppCapability.writeHealth,
        AppCapability.writeMedia,
      },
      'staff' => {
        ...base,
        AppCapability.writeHamster,
        AppCapability.writeCrm,
        AppCapability.writeDocuments,
        AppCapability.writeGrowth,
      },
      _ => base,
    };
  }

  void _captureError(Object error) {
    offline = _isOfflineError(error);
    if (offline) {
      lastError = '离线只读，联网后重新提交/再操作';
      return;
    }
    // 诊断用：尽量暴露真实原因
    if (error is DioException) {
      final status = error.response?.statusCode;
      final msg =
          error.response?.data?.toString() ??
          error.message ??
          error.type.toString();
      lastError = status != null
          ? '请求失败($status): $msg'
          : '网络错误(${error.type}): $msg';
    } else {
      lastError = '错误: ${error.toString()}';
    }
  }

  static bool _isOfflineError(Object error) =>
      error is DioException &&
      switch (error.type) {
        DioExceptionType.connectionError ||
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout => true,
        _ => false,
      };
}
