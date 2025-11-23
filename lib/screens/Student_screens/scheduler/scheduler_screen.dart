import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:learningmanagement/providers/scheduler_provider.dart';
import 'package:learningmanagement/screens/Student_screens/scheduler/event_detail_screen.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/providers/deadline_countdown_provider.dart';
import 'package:learningmanagement/widgets/schedules/countdown_timer.dart';
import 'package:learningmanagement/screens/Student_screens/scheduler/student_stats_screen.dart';

class SchedulerScreen extends ConsumerStatefulWidget {
  const SchedulerScreen({super.key});
  @override
  ConsumerState<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends ConsumerState<SchedulerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  CalendarFormat _calendarFormat = CalendarFormat.month;

  static const Map<ScheduleType, String> _typeName = {
    ScheduleType.lesson: 'Buổi học',
    ScheduleType.exam: 'Bài kiểm tra',
    ScheduleType.assignment: 'Bài tập',
    ScheduleType.deadline: 'Deadline',
  };

  Color _getColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }

  @override
  Widget build(BuildContext context) {
    final eventsMap = ref.watch(schedulerProvider);
    final countdownMap = ref.watch(deadlineCountdownProvider);
    final selectedEvents = ref
        .read(schedulerProvider.notifier)
        .getEventsForDay(_selectedDay);
    final theme = Theme.of(context);

    return Column(
      children: [
        // === LỊCH ===
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            calendarFormat: _calendarFormat,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Tháng',
              CalendarFormat.twoWeeks: '2 Tuần',
              CalendarFormat.week: 'Tuần',
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(77),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) => eventsMap[day] ?? [],
          ),
        ),

        // === TIÊU ĐỀ NGÀY ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sự kiện ngày ${_selectedDay.day}/${_selectedDay.month}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.blue),
                tooltip: 'Xem Thống kê',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentStatsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),

        // === DANH SÁCH SỰ KIỆN ===
        Expanded(
          child: selectedEvents.isEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có sự kiện',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = selectedEvents[index];
                    final countdown = countdownMap[event.id];
                    final eventColor = _getColor(event.color);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: event),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: eventColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 12,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: eventColor.withAlpha(30),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            _typeName[event.type] ?? 'Sự kiện',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: eventColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (event.type != ScheduleType.lesson &&
                                        countdown != null &&
                                        !countdown.isCompleted)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.timer_outlined,
                                              size: 14,
                                              color: Colors.redAccent,
                                            ),
                                            const SizedBox(width: 4),
                                            CountdownTimer(
                                              deadline: countdown.deadline,
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
