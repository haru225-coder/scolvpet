import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'today_widget_snapshot.dart';

/// Publishes [TodayWidgetSnapshot] for home-screen widgets.
abstract interface class TodayWidgetPublisher {
  Future<void> publish(TodayWidgetSnapshot snapshot);
  Future<TodayWidgetSnapshot?> loadLast();
}

/// In-memory publisher for tests / offline preview.
class MemoryTodayWidgetPublisher implements TodayWidgetPublisher {
  TodayWidgetSnapshot? last;

  @override
  Future<void> publish(TodayWidgetSnapshot snapshot) async {
    last = snapshot;
  }

  @override
  Future<TodayWidgetSnapshot?> loadLast() async => last;
}

/// Writes SharedPreferences (Android FlutterSharedPreferences) and pings native.
class SharedPreferencesTodayWidgetPublisher implements TodayWidgetPublisher {
  SharedPreferencesTodayWidgetPublisher({
    SharedPreferences? preferences,
    MethodChannel? channel,
  }) : _preferences = preferences,
       _channel = channel ??
           const MethodChannel('cn.scolvpet.dev/today_widget');

  SharedPreferences? _preferences;
  final MethodChannel _channel;

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<void> publish(TodayWidgetSnapshot snapshot) async {
    final prefs = await _prefs();
    await prefs.setString(TodayWidgetKeys.title, snapshot.headline);
    await prefs.setString(TodayWidgetKeys.body, snapshot.bodyText);
    await prefs.setString(TodayWidgetKeys.countLabel, snapshot.countLabel);
    await prefs.setInt(TodayWidgetKeys.openCount, snapshot.openCount);
    await prefs.setInt(TodayWidgetKeys.overdueCount, snapshot.overdueCount);
    await prefs.setString(TodayWidgetKeys.json, snapshot.toJsonString());
    await prefs.setString(
      TodayWidgetKeys.updatedAt,
      snapshot.updatedAt.toUtc().toIso8601String(),
    );
    try {
      await _channel.invokeMethod<void>('refreshTodayWidget');
    } on MissingPluginException {
      // Host without native widget bridge (tests / some desktops).
    } catch (error) {
      debugPrint('today widget refresh failed: $error');
    }
  }

  @override
  Future<TodayWidgetSnapshot?> loadLast() async {
    final prefs = await _prefs();
    final raw = prefs.getString(TodayWidgetKeys.json);
    if (raw == null || raw.isEmpty) return null;
    try {
      return TodayWidgetSnapshot.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }
}
