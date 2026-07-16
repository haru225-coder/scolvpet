import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scolvpet_api/scolvpet_api.dart';

import '../data/i1_repository.dart';
import 'session_store.dart';

enum AppPhase { restoring, login, code, setup, home }

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
  String? lastError;

  Future<void> restore() async {
    final token = await _sessionStore.readAccessToken();
    if (token == null) {
      phase = AppPhase.login;
      notifyListeners();
      return;
    }
    try {
      final current = await _repository.getCurrentAccount();
      account = current.account;
      organization = current.currentOrganization;
      await refreshRules();
      phase = AppPhase.home;
    } catch (_) {
      final refreshToken = await _sessionStore.readRefreshToken();
      try {
        if (refreshToken == null) throw StateError('missing refresh token');
        final session = await _repository.refresh(refreshToken);
        account = session.account;
        organization = session.currentOrganization;
        await refreshRules();
        phase = AppPhase.home;
      } catch (_) {
        final cached = await _sessionStore.readSnapshot();
        if (cached?.organization != null && _restoreSnapshot(cached!)) {
          offline = true;
          phase = AppPhase.home;
        } else {
          phase = AppPhase.login;
        }
      }
    }
    notifyListeners();
  }

  Future<void> requestCode(String value) async {
    phone = value;
    lastError = null;
    try {
      verificationId = await _repository.requestCode(value);
      offline = false;
      phase = AppPhase.code;
    } catch (error) {
      _captureError(error);
    }
    notifyListeners();
  }

  Future<void> login(String code) async {
    if (phone == null || verificationId == null) return;
    try {
      final session = await _repository.login(
        phone: phone!,
        verificationId: verificationId!,
        code: code,
      );
      account = session.account;
      organization = session.currentOrganization;
      offline = false;
      phase = AppPhase.setup;
      await refreshRules();
    } catch (error) {
      _captureError(error);
    }
    notifyListeners();
  }

  Future<void> completeSetup(String name) async {
    if (organization == null) return;
    if (offline) {
      lastError = '离线只读，联网后重新提交/再操作';
      notifyListeners();
      return;
    }
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
    }
    notifyListeners();
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
    await _repository.logout();
    account = null;
    organization = null;
    ownerRules = [];
    systemRules = [];
    phase = AppPhase.login;
    offline = false;
    notifyListeners();
  }

  Future<void> _saveSnapshot() async {
    await _sessionStore.saveSnapshot(
      SessionSnapshot(
        account: account?.toJson(),
        organization: organization?.toJson(),
        rules: ownerRules.map((rule) => rule.toJson()).toList(),
        systemRules: systemRules.map((rule) => rule.toJson()).toList(),
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
      return true;
    } on Object {
      account = null;
      organization = null;
      ownerRules = [];
      systemRules = [];
      return false;
    }
  }

  void _captureError(Object error) {
    offline =
        error is DioException && error.type == DioExceptionType.connectionError;
    lastError = offline ? '离线只读，联网后重新提交/再操作' : '请求未完成，请稍后重试';
  }
}
