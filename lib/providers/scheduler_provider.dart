import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

typedef Event = String;

class SchedulerProvider extends Notifier<LinkedHashMap<DateTime, List<Event>>> {
  @override
  LinkedHashMap<DateTime, List<Event>> build() {
    final events = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    final today = DateTime.now();
    events[today] = [
      'Chơi Genshin cùng bạn gái',
      'Qua game goon để lọ cùng ai đó',
    ];

    final yesterday = today.subtract(const Duration(days: 1));
    events[yesterday] = ['Đọc sách lập trình Flutter'];
    return events;
  }

  List<Event> getEventsForDay(DateTime day) {
    return state[day] ?? [];
  }

  void addEvent(DateTime day, String eventTitle) {
    final eventForDay = getEventsForDay(day);

    final newState = LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    )..addAll(state);

    newState[day] = [...eventForDay, eventTitle];
    state = newState;
  }
}

final schedulerProvider =
    NotifierProvider<SchedulerProvider, LinkedHashMap<DateTime, List<Event>>>(
      () {
        return SchedulerProvider();
      },
    );
