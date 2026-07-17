import 'package:flutter/material.dart';

import '../breeding/breeding_controller.dart';
import '../i2/i2_controller.dart';
import '../i2/i2_models.dart';
import '../tasks/task_controller.dart';
import 'calendar_aggregator.dart';
import 'calendar_models.dart';

/// Month calendar aggregating tasks, breeding windows and litter wean days.
class CalendarMonthPage extends StatefulWidget {
  const CalendarMonthPage({
    super.key,
    required this.taskController,
    required this.breedingController,
    required this.i2Controller,
    this.initialMonth,
  });

  final TaskController taskController;
  final BreedingController breedingController;
  final I2Controller i2Controller;
  final DateTime? initialMonth;

  @override
  State<CalendarMonthPage> createState() => _CalendarMonthPageState();
}

class _CalendarMonthPageState extends State<CalendarMonthPage> {
  late CalendarMonth _month;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialMonth ?? DateTime.now();
    _month = CalendarMonth(year: seed.year, month: seed.month);
    _selectedDay = DateTime(seed.year, seed.month, seed.day);
    _refreshSources();
  }

  Future<void> _refreshSources() async {
    await Future.wait([
      widget.taskController.refresh(),
      widget.breedingController.refresh(),
      widget.i2Controller.retry(),
    ]);
    if (mounted) setState(() {});
  }

  Color _kindColor(CalendarEventKind kind) => switch (kind) {
    CalendarEventKind.expectedBirth => const Color(0xffc77852),
    CalendarEventKind.weaning => const Color(0xff5b8a72),
    CalendarEventKind.cleaning => const Color(0xff4a7c9b),
    CalendarEventKind.weight => const Color(0xffb6534a),
    CalendarEventKind.breeding => const Color(0xff8a6d3b),
    CalendarEventKind.other => const Color(0xff6c7774),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.taskController,
        widget.breedingController,
        widget.i2Controller,
      ]),
      builder: (context, _) {
        final tasks = widget.taskController.listState.data ?? const [];
        final plans = widget.breedingController.listState.data ?? const [];
        final litters =
            widget.i2Controller.snapshotState.data?.litters ??
            const <I2Litter>[];
        final events = buildCalendarEvents(
          tasks: tasks,
          plans: plans,
          litters: litters,
        );
        final byDay = eventsByDay(events, _month);
        final selected =
            _selectedDay == null ? const <CalendarEvent>[] : (byDay[_selectedDay!] ?? const <CalendarEvent>[]);

        return Scaffold(
          appBar: AppBar(
            title: const Text('日历'),
            actions: [
              IconButton(
                key: const Key('calendar-refresh'),
                tooltip: '刷新',
                onPressed: _refreshSources,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('calendar-prev-month'),
                      onPressed: () => setState(() {
                        _month = _month.previous;
                        _selectedDay = null;
                      }),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        _month.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const Key('calendar-next-month'),
                      onPressed: () => setState(() {
                        _month = _month.next;
                        _selectedDay = null;
                      }),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _WeekdayLabel('一'),
                    _WeekdayLabel('二'),
                    _WeekdayLabel('三'),
                    _WeekdayLabel('四'),
                    _WeekdayLabel('五'),
                    _WeekdayLabel('六'),
                    _WeekdayLabel('日'),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _MonthGrid(
                    month: _month,
                    byDay: byDay,
                    selectedDay: _selectedDay,
                    kindColor: _kindColor,
                    onSelect: (day) => setState(() => _selectedDay = day),
                  ),
                ),
              ),
              _Legend(kindColor: _kindColor),
              const Divider(height: 1),
              Expanded(
                flex: 4,
                child: selected.isEmpty
                    ? Center(
                        child: Text(
                          _selectedDay == null
                              ? '点选日期查看预产 / 断奶 / 清洁等事项'
                              : '这一天暂无聚合事项',
                          style: const TextStyle(color: Color(0xff6c7774)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: selected.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final event = selected[index];
                          return Card(
                            key: Key('calendar-event-${event.id}'),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _kindColor(
                                  event.kind,
                                ).withValues(alpha: 0.18),
                                child: Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: _kindColor(event.kind),
                                ),
                              ),
                              title: Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  event.kindLabel,
                                  if (event.subtitle != null) event.subtitle!,
                                ].join(' · '),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff6c7774),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.kindColor});
  final Color Function(CalendarEventKind) kindColor;

  @override
  Widget build(BuildContext context) {
    final items = [
      CalendarEventKind.expectedBirth,
      CalendarEventKind.weaning,
      CalendarEventKind.cleaning,
      CalendarEventKind.weight,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          for (final kind in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: kindColor(kind)),
                const SizedBox(width: 4),
                Text(
                  switch (kind) {
                    CalendarEventKind.expectedBirth => '预产',
                    CalendarEventKind.weaning => '断奶',
                    CalendarEventKind.cleaning => '清洁',
                    CalendarEventKind.weight => '称重',
                    _ => '',
                  },
                  style: const TextStyle(fontSize: 11, color: Color(0xff6c7774)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.byDay,
    required this.selectedDay,
    required this.kindColor,
    required this.onSelect,
  });

  final CalendarMonth month;
  final Map<DateTime, List<CalendarEvent>> byDay;
  final DateTime? selectedDay;
  final Color Function(CalendarEventKind) kindColor;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final cells = month.dayCells;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final rowCount = (cells.length / 7).ceil();

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 2.0;
        final cellW = (constraints.maxWidth - 6 * gap) / 7;
        final cellH = (constraints.maxHeight - (rowCount - 1) * gap) / rowCount;
        return Column(
          children: [
            for (var row = 0; row < rowCount; row++) ...[
              if (row > 0) const SizedBox(height: gap),
              SizedBox(
                height: cellH,
                child: Row(
                  children: [
                    for (var col = 0; col < 7; col++) ...[
                      if (col > 0) const SizedBox(width: gap),
                      SizedBox(
                        width: cellW,
                        height: cellH,
                        child: _dayCell(cells[row * 7 + col], todayKey),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _dayCell(DateTime? day, DateTime todayKey) {
    if (day == null) return const SizedBox.shrink();
    final dayEvents = byDay[day] ?? const <CalendarEvent>[];
    final kinds = kindsForDay(dayEvents);
    final isSelected = selectedDay == day;
    final isToday = day == todayKey;
    return Material(
      color: isSelected
          ? const Color(0xffdce5e3)
          : isToday
          ? const Color(0xfffff3e8)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: Key('calendar-day-${day.day}'),
        borderRadius: BorderRadius.circular(10),
        onTap: () => onSelect(day),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday || isSelected
                    ? FontWeight.w800
                    : FontWeight.w500,
                color: const Color(0xff1f2928),
              ),
            ),
            const SizedBox(height: 2),
            if (kinds.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final kind in kinds.take(3))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: kindColor(kind),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
