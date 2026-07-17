// Read-only calendar aggregation (T-P0-06).

enum CalendarEventKind {
  expectedBirth,
  weaning,
  cleaning,
  weight,
  breeding,
  other,
}

class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.kind,
    required this.title,
    required this.date,
    this.subtitle,
    this.sourceType,
    this.sourceId,
  });

  final String id;
  final CalendarEventKind kind;
  final String title;

  /// Local calendar day (time ignored for bucketing).
  final DateTime date;
  final String? subtitle;
  final String? sourceType;
  final String? sourceId;

  DateTime get dayKey => DateTime(date.year, date.month, date.day);

  String get kindLabel => switch (kind) {
    CalendarEventKind.expectedBirth => '预产',
    CalendarEventKind.weaning => '断奶',
    CalendarEventKind.cleaning => '清洁',
    CalendarEventKind.weight => '称重',
    CalendarEventKind.breeding => '繁育',
    CalendarEventKind.other => '其他',
  };
}

class CalendarMonth {
  const CalendarMonth({required this.year, required this.month});

  final int year;
  final int month;

  DateTime get firstDay => DateTime(year, month, 1);

  DateTime get lastDay => DateTime(year, month + 1, 0);

  CalendarMonth get previous {
    final d = DateTime(year, month - 1, 1);
    return CalendarMonth(year: d.year, month: d.month);
  }

  CalendarMonth get next {
    final d = DateTime(year, month + 1, 1);
    return CalendarMonth(year: d.year, month: d.month);
  }

  String get label => '$year年${month.toString().padLeft(2, '0')}月';

  /// Monday-first grid cells (null = outside month).
  List<DateTime?> get dayCells {
    final first = firstDay;
    // DateTime.weekday: Mon=1 … Sun=7
    final leading = first.weekday - 1;
    final daysInMonth = lastDay.day;
    final cells = <DateTime?>[
      ...List<DateTime?>.filled(leading, null),
      ...List<DateTime>.generate(
        daysInMonth,
        (i) => DateTime(year, month, i + 1),
      ),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  bool contains(DateTime day) => day.year == year && day.month == month;
}

/// Map task_type / source into a display kind for month dots.
CalendarEventKind calendarKindForTaskType(String taskType) {
  final t = taskType.toLowerCase();
  if (t.contains('wean')) return CalendarEventKind.weaning;
  if (t.contains('clean')) return CalendarEventKind.cleaning;
  if (t.contains('weight') || t.contains('pup_weight')) {
    return CalendarEventKind.weight;
  }
  if (t.contains('gestat') ||
      t.contains('birth') ||
      t.contains('no_birth') ||
      t.contains('pair') ||
      t.contains('sex_') ||
      t.contains('separate')) {
    return CalendarEventKind.breeding;
  }
  return CalendarEventKind.other;
}
