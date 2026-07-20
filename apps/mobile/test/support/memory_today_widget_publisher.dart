// Test doubles only — not part of production lib.
// Moved out of lib/ per docs/engineering/复杂度收敛约定.md

import 'package:scolvpet_mobile/features/home_widget/today_widget_publisher.dart';
import 'package:scolvpet_mobile/features/home_widget/today_widget_snapshot.dart';

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
