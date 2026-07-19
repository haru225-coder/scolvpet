import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../ui/theme/ios_theme.dart';
import '../../ui/widgets/ios_widgets.dart';
import '../breeding/breeding_controller.dart';
import '../i2/i2_controller.dart';
import '../i2/i2_models.dart';
import '../i2/i2_widgets.dart';
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
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialMonth ?? DateTime.now();
    _month = CalendarMonth(year: seed.year, month: seed.month);
    _selectedDay = DateTime(seed.year, seed.month, seed.day);
    _refreshSources();
  }

  Future<void> _refreshSources() async {
    if (_refreshing) return;
    _refreshing = true;
    if (mounted) setState(() {});
    try {
      await Future.wait([
        widget.taskController.refresh(),
        widget.breedingController.refresh(),
        widget.i2Controller.retry(),
      ]);
    } finally {
      _refreshing = false;
      if (mounted) setState(() {});
    }
  }

  List<(String, I2AsyncStatus)> get _sourceStates => [
    ('任务', widget.taskController.listState.status),
    ('繁育计划', widget.breedingController.listState.status),
    ('窝次', widget.i2Controller.snapshotState.status),
  ];

  bool _isPending(I2AsyncStatus status) =>
      status == I2AsyncStatus.idle || status == I2AsyncStatus.loading;

  bool _isFailure(I2AsyncStatus status) =>
      status == I2AsyncStatus.error || status == I2AsyncStatus.conflict;

  bool _isAvailable(I2AsyncStatus status) =>
      status == I2AsyncStatus.data || status == I2AsyncStatus.empty;

  Color _kindColor(CalendarEventKind kind) => switch (kind) {
    CalendarEventKind.expectedBirth => ScolvPalette.of(context).accent,
    CalendarEventKind.weaning => IosColors.systemGreen,
    CalendarEventKind.cleaning => IosColors.systemTeal,
    CalendarEventKind.weight => IosColors.systemRed,
    CalendarEventKind.breeding => IosColors.systemOrange,
    CalendarEventKind.other => ScolvPalette.of(context).secondaryLabel,
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
        final selected = _selectedDay == null
            ? const <CalendarEvent>[]
            : (byDay[_selectedDay!] ?? const <CalendarEvent>[]);
        final pendingSources = _sourceStates
            .where((entry) => _isPending(entry.$2))
            .map((entry) => entry.$1)
            .toList();
        final failedSources = _sourceStates
            .where((entry) => _isFailure(entry.$2))
            .map((entry) => entry.$1)
            .toList();
        final availableSourceCount = _sourceStates
            .where((entry) => _isAvailable(entry.$2))
            .length;
        final initialLoading =
            availableSourceCount == 0 && pendingSources.isNotEmpty;
        final allSourcesFailed =
            availableSourceCount == 0 && failedSources.length == 3;

        return Scaffold(
          appBar: AppBar(
            title: const Text('日历'),
            actions: [
              IconButton(
                key: const Key('calendar-refresh'),
                tooltip: '刷新',
                onPressed: _refreshing ? null : _refreshSources,
                icon: _refreshing
                    ? const CupertinoActivityIndicator(radius: 9)
                    : const Icon(CupertinoIcons.arrow_clockwise),
              ),
            ],
          ),
          body: initialLoading
              ? const IosLoading(
                  key: Key('calendar-loading'),
                  showSkeleton: true,
                )
              : allSourcesFailed
              ? I2StateMessage(
                  key: const Key('calendar-all-sources-error'),
                  icon: CupertinoIcons.cloud,
                  message: '日历数据加载失败，任务、繁育计划和窝次均未载入。',
                  actionLabel: '重新载入',
                  onRetry: _refreshing ? null : _refreshSources,
                  tone: IosColors.systemRed,
                )
              : RefreshIndicator(
                  color: ScolvPalette.of(context).accent,
                  onRefresh: _refreshSources,
                  child: ListView(
                    key: const Key('calendar-scroll'),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (pendingSources.isNotEmpty || failedSources.isNotEmpty)
                        Padding(
                          key: const Key('calendar-source-notice'),
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: IosBanner(
                            icon: pendingSources.isNotEmpty
                                ? CupertinoIcons.arrow_clockwise
                                : CupertinoIcons.exclamationmark_triangle,
                            color: IosColors.systemOrange,
                            text: _sourceNoticeText(
                              pendingSources: pendingSources,
                              failedSources: failedSources,
                            ),
                            actionLabel:
                                failedSources.isNotEmpty && !_refreshing
                                ? '重试'
                                : null,
                            onAction: failedSources.isNotEmpty && !_refreshing
                                ? _refreshSources
                                : null,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Row(
                          children: [
                            IconButton(
                              key: const Key('calendar-prev-month'),
                              tooltip: '上个月',
                              onPressed: () => setState(() {
                                _month = _month.previous;
                                _selectedDay = null;
                              }),
                              icon: const Icon(CupertinoIcons.chevron_left),
                            ),
                            Expanded(
                              child: Text(
                                _month.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                              ),
                            ),
                            IconButton(
                              key: const Key('calendar-next-month'),
                              tooltip: '下个月',
                              onPressed: () => setState(() {
                                _month = _month.next;
                                _selectedDay = null;
                              }),
                              icon: const Icon(CupertinoIcons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _MonthGrid(
                          month: _month,
                          byDay: byDay,
                          selectedDay: _selectedDay,
                          kindColor: _kindColor,
                          onSelect: (day) => setState(() => _selectedDay = day),
                        ),
                      ),
                      _Legend(kindColor: _kindColor),
                      const IosHairline(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          _selectedDay == null
                              ? '当日事项'
                              : '${_selectedDay!.month}月${_selectedDay!.day}日事项',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (selected.isEmpty)
                        _CalendarEmptyDay(
                          selectedDay: _selectedDay,
                          pendingSources: pendingSources,
                          failedSources: failedSources,
                        )
                      else
                        IosGroupedSection(
                          children: [
                            for (final event in selected)
                              IosListTile(
                                key: Key('calendar-event-${event.id}'),
                                leading: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _kindColor(event.kind),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: event.title,
                                subtitle: [
                                  event.kindLabel,
                                  if (event.subtitle != null) event.subtitle!,
                                ].join(' · '),
                                showChevron: false,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  String _sourceNoticeText({
    required List<String> pendingSources,
    required List<String> failedSources,
  }) {
    final parts = <String>[];
    if (pendingSources.isNotEmpty) {
      parts.add('${pendingSources.join('、')}正在载入，当前事项可能不完整');
    }
    if (failedSources.isNotEmpty) {
      parts.add('${failedSources.join('、')}未载入，当前仅显示其余来源');
    }
    return '${parts.join('；')}。';
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
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
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
                Icon(
                  CupertinoIcons.circle_fill,
                  size: 8,
                  color: kindColor(kind),
                ),
                const SizedBox(width: 4),
                Text(
                  switch (kind) {
                    CalendarEventKind.expectedBirth => '预产',
                    CalendarEventKind.weaning => '断奶',
                    CalendarEventKind.cleaning => '清洁',
                    CalendarEventKind.weight => '称重',
                    _ => '',
                  },
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CalendarEmptyDay extends StatelessWidget {
  const _CalendarEmptyDay({
    required this.selectedDay,
    required this.pendingSources,
    required this.failedSources,
  });

  final DateTime? selectedDay;
  final List<String> pendingSources;
  final List<String> failedSources;

  @override
  Widget build(BuildContext context) {
    final palette = ScolvPalette.of(context);
    final message = switch ((selectedDay, pendingSources, failedSources)) {
      (null, _, _) => '点选日期查看预产、断奶、清洁和称重事项。',
      (_, final pending, _) when pending.isNotEmpty =>
        '已载入的数据中，这一天暂无事项。${pending.join('、')}仍在同步。',
      (_, _, final failed) when failed.isNotEmpty =>
        '已载入的数据中，这一天暂无事项。${failed.join('、')}尚未载入。',
      _ => '这一天暂无事项。',
    };
    return Padding(
      key: const Key('calendar-empty-day'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        children: [
          Icon(
            selectedDay == null
                ? CupertinoIcons.calendar
                : CupertinoIcons.checkmark_circle,
            size: 34,
            color: palette.secondaryLabel,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: palette.secondaryLabel,
              height: 1.4,
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 2.0;
        final cellW = (constraints.maxWidth - 6 * gap) / 7;
        final scaledDayText = MediaQuery.textScalerOf(context).scale(13);
        final cellH = (44 + (scaledDayText - 13) * 1.5).clamp(44, 56);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: gap,
            mainAxisSpacing: gap,
            childAspectRatio: cellW / cellH,
          ),
          itemBuilder: (context, index) =>
              _dayCell(context, cells[index], todayKey),
        );
      },
    );
  }

  Widget _dayCell(BuildContext context, DateTime? day, DateTime todayKey) {
    if (day == null) return const SizedBox.shrink();
    final dayEvents = byDay[day] ?? const <CalendarEvent>[];
    final kinds = kindsForDay(dayEvents);
    final isSelected = selectedDay == day;
    final isToday = day == todayKey;
    return Material(
      color: isSelected
          ? ScolvPalette.of(context).accent.withValues(alpha: 0.14)
          : isToday
          ? ScolvPalette.of(context).accentSoft
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: Key('calendar-day-${day.day}'),
        borderRadius: BorderRadius.circular(10),
        onTap: () => onSelect(day),
        child: Semantics(
          selected: isSelected,
          button: true,
          label:
              '${day.month}月${day.day}日，${dayEvents.isEmpty ? '无事项' : '${dayEvents.length}项事项'}',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isToday || isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? ScolvPalette.of(context).accent
                      : ScolvPalette.of(context).label,
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
                          CupertinoIcons.circle_fill,
                          size: 5,
                          color: kindColor(kind),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
