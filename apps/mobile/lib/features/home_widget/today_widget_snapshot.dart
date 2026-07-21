import 'dart:convert';

import '../shell/today_care_queue.dart';
import '../tasks/task_models.dart';

/// Serializable payload for home-screen "今日待办" widgets (T-P1-05).
class TodayWidgetLine {
  const TodayWidgetLine({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
  });

  final String id;
  final String title;
  final String subtitle;
  final String kind;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'kind': kind,
  };

  factory TodayWidgetLine.fromJson(Map<String, dynamic> json) =>
      TodayWidgetLine(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        kind: json['kind'] as String? ?? '',
      );
}

class TodayWidgetSnapshot {
  const TodayWidgetSnapshot({
    required this.updatedAt,
    required this.headline,
    required this.lines,
    required this.openCount,
    required this.overdueCount,
    this.emptyMessage = '今日暂无待办',
  });

  final DateTime updatedAt;
  final String headline;
  final List<TodayWidgetLine> lines;
  final int openCount;
  final int overdueCount;
  final String emptyMessage;

  bool get isEmpty => lines.isEmpty;

  /// Multi-line body suitable for RemoteViews / WidgetKit text.
  String get bodyText {
    if (lines.isEmpty) return emptyMessage;
    return lines
        .map((line) {
          final sub = line.subtitle.trim();
          return sub.isEmpty ? '· ${line.title}' : '· ${line.title}（$sub）';
        })
        .join('\n');
  }

  String get countLabel {
    if (openCount <= 0) return '无待办';
    if (overdueCount > 0) return '$openCount 项 · $overdueCount 逾期';
    return '$openCount 项';
  }

  Map<String, dynamic> toJson() => {
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'headline': headline,
    'lines': lines.map((e) => e.toJson()).toList(),
    'open_count': openCount,
    'overdue_count': overdueCount,
    'empty_message': emptyMessage,
    'body_text': bodyText,
    'count_label': countLabel,
  };

  String toJsonString() => jsonEncode(toJson());

  factory TodayWidgetSnapshot.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    return TodayWidgetSnapshot(
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      headline: json['headline'] as String? ?? '今日待办',
      lines: rawLines is List
          ? rawLines
                .whereType<Map>()
                .map(
                  (e) => TodayWidgetLine.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
      openCount: (json['open_count'] as num?)?.toInt() ?? 0,
      overdueCount: (json['overdue_count'] as num?)?.toInt() ?? 0,
      emptyMessage: json['empty_message'] as String? ?? '今日暂无待办',
    );
  }

  factory TodayWidgetSnapshot.fromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return TodayWidgetSnapshot.empty();
    }
    return TodayWidgetSnapshot.fromJson(Map<String, dynamic>.from(decoded));
  }

  factory TodayWidgetSnapshot.empty({DateTime? now}) {
    return TodayWidgetSnapshot(
      updatedAt: (now ?? DateTime.now()).toUtc(),
      headline: '今日待办',
      lines: const [],
      openCount: 0,
      overdueCount: 0,
    );
  }

  /// Build from care queue rows (home dashboard / task sync).
  factory TodayWidgetSnapshot.fromCareQueue(
    List<TodayCareItem> queue, {
    DateTime? now,
    int maxLines = 5,
  }) {
    final clock = now ?? DateTime.now();
    final lines = queue
        .take(maxLines)
        .map(
          (item) => TodayWidgetLine(
            id: item.id,
            title: item.title,
            subtitle: item.subtitle,
            kind: item.kind.name,
          ),
        )
        .toList();
    final openTaskCount = queue.where((e) => e.task != null).length;
    final overdue = queue
        .where((e) => e.kind == TodayCareKind.overdueTask)
        .length;
    return TodayWidgetSnapshot(
      updatedAt: clock.toUtc(),
      headline: '今日待办',
      lines: lines,
      openCount: openTaskCount > 0 ? openTaskCount : lines.length,
      overdueCount: overdue,
    );
  }

  /// Task-only convenience used by [TaskController] sync.
  factory TodayWidgetSnapshot.fromTasks(
    Iterable<CareTaskItem> tasks, {
    DateTime? now,
    int maxLines = 5,
  }) {
    final queue = buildTodayCareQueue(
      tasks: tasks,
      now: now,
      maxItems: maxLines,
    );
    return TodayWidgetSnapshot.fromCareQueue(
      queue,
      now: now,
      maxLines: maxLines,
    );
  }
}

/// Preference keys shared with Android AppWidget / iOS App Group.
abstract final class TodayWidgetKeys {
  static const title = 'today_widget_title';
  static const body = 'today_widget_body';
  static const countLabel = 'today_widget_count_label';
  static const openCount = 'today_widget_open_count';
  static const overdueCount = 'today_widget_overdue_count';
  static const json = 'today_widget_json';
  static const updatedAt = 'today_widget_updated_at';

  /// Flutter SharedPreferences prefixes keys with `flutter.` on Android.
  static const androidFlutterPrefix = 'flutter.';
}
