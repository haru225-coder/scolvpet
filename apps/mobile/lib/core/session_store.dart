import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SessionStorePort {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> clear();

  Future<void> saveSnapshot(SessionSnapshot snapshot);

  Future<SessionSnapshot?> readSnapshot();
}

class SessionSnapshot {
  const SessionSnapshot({
    this.account,
    this.organization,
    this.rules,
    this.systemRules,
  });

  final Map<String, dynamic>? account;
  final Map<String, dynamic>? organization;
  final List<dynamic>? rules;
  final List<dynamic>? systemRules;
}

class SessionStore implements SessionStorePort {
  SessionStore({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'scolvpet.access_token';
  static const _refreshTokenKey = 'scolvpet.refresh_token';
  static const _snapshotKey = 'scolvpet.read_snapshot';
  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> readAccessToken() =>
      _secureStorage.read(key: _accessTokenKey);

  @override
  Future<String?> readRefreshToken() =>
      _secureStorage.read(key: _refreshTokenKey);

  @override
  Future<void> clear() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<void> saveSnapshot(SessionSnapshot snapshot) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _snapshotKey,
      jsonEncode({
        'account': snapshot.account,
        'organization': snapshot.organization,
        'rules': snapshot.rules,
        'system_rules': snapshot.systemRules,
      }),
    );
  }

  @override
  Future<SessionSnapshot?> readSnapshot() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_snapshotKey);
    if (raw == null) return null;
    final value = jsonDecode(raw) as Map<String, dynamic>;
    return SessionSnapshot(
      account: value['account'] as Map<String, dynamic>?,
      organization: value['organization'] as Map<String, dynamic>?,
      rules: value['rules'] as List<dynamic>?,
      systemRules: value['system_rules'] as List<dynamic>?,
    );
  }
}
