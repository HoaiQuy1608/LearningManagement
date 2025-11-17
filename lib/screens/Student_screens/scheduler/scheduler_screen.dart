import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:learningmanagement/providers/scheduler_provider.dart';
import 'package:learningmanagement/screens/Student_screens/scheduler/event_detail_screen.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/providers/deadline_countdown_provider.dart';
import 'package:learningmanagement/widgets/countdown_timer.dart';

class SchedulerScreen extends ConsumerStatefulWidget {
  const SchedulerScreen({super.key});
  @override
  ConsumerState<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends ConsumerState<SchedulerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

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
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sự kiện ngày ${_selectedDay.day}/${_selectedDay.month}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),

        // === DANH SÁCH SỰ KIỆN ===
        Expanded(
          child: selectedEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Không có sự kiện',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = selectedEvents[index];
                    final countdown = countdownMap[event.id];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 8,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getColor(event.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.description != null)
                              Text(
                                event.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} • ${_typeName[event.type] ?? event.type.name}',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 12,
                              ),
                            ),
                            // Hiển thị đồng hồ đếm ngược
                            if (event.type != ScheduleType.lesson &&
                                countdown != null &&
                                !countdown.isCompleted)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      size: 12,
                                      color: Colors.red,
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
                        // Kết nối đến chi tiết sự kiện
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(event: event),
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
