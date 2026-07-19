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
    this.currentMemberRole,
    this.capabilities,
  });

  final Map<String, dynamic>? account;
  final Map<String, dynamic>? organization;
  final List<dynamic>? rules;
  final List<dynamic>? systemRules;
  final String? currentMemberRole;
  final List<String>? capabilities;
}

class SessionStore implements SessionStorePort {
  SessionStore({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'scolvpet.access_token';
  static const _refreshTokenKey = 'scolvpet.refresh_token';
  static const _snapshotKey = 'scolvpet.read_snapshot';
  static const _businessPreferenceKeys = <String>[
    _snapshotKey,
    'scolvpet.i2.snapshot',
    'scolvpet.i2.drafts',
    'today_widget_title',
    'today_widget_body',
    'today_widget_count_label',
    'today_widget_open_count',
    'today_widget_overdue_count',
    'today_widget_json',
    'today_widget_updated_at',
  ];
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
    // Logout is a best-effort local boundary: one storage backend failing must
    // not prevent the other account-bound values from being removed.
    try {
      await _secureStorage.delete(key: _accessTokenKey);
    } on Object {
      // Continue with the remaining account-bound values.
    }
    try {
      await _secureStorage.delete(key: _refreshTokenKey);
    } on Object {
      // Continue with local business data cleanup below.
    }
    try {
      final preferences = await SharedPreferences.getInstance();
      for (final key in _businessPreferenceKeys) {
        await preferences.remove(key);
      }
    } on Object {
      // Keep logout usable even if the preferences backend is unavailable.
    }
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
        'current_member_role': snapshot.currentMemberRole,
        'capabilities': snapshot.capabilities,
      }),
    );
  }

  @override
  Future<SessionSnapshot?> readSnapshot() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_snapshotKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        await preferences.remove(_snapshotKey);
        return null;
      }
      final value = Map<String, dynamic>.from(decoded);
      return SessionSnapshot(
        account: _mapOrNull(value['account']),
        organization: _mapOrNull(value['organization']),
        rules: _listOrNull(value['rules']),
        systemRules: _listOrNull(value['system_rules'] ?? value['systemRules']),
        currentMemberRole: _stringOrNull(
          value['current_member_role'] ?? value['currentMemberRole'],
        ),
        capabilities: _stringListOrNull(value['capabilities']),
      );
    } on Object {
      // A truncated or old incompatible snapshot must never strand startup in
      // the restoring phase. Discard it so the next launch does not retry it.
      try {
        await preferences.remove(_snapshotKey);
      } on Object {
        // Returning null is still the safe startup fallback.
      }
      return null;
    }
  }

  static Map<String, dynamic>? _mapOrNull(Object? value) {
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  static List<dynamic>? _listOrNull(Object? value) {
    if (value is! List) return null;
    return List<dynamic>.from(value);
  }

  static List<String>? _stringListOrNull(Object? value) {
    if (value is! List) return null;
    return value.whereType<String>().toList(growable: false);
  }

  static String? _stringOrNull(Object? value) => value is String ? value : null;
}
