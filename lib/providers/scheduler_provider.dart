import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'dart:collection';
import 'package:learningmanagement/service/notifications_service.dart';

class SchedulerProvider
    extends Notifier<LinkedHashMap<DateTime, List<ScheduleModel>>> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  String? _userId;
  ScheduleModel? _lastDeleted;

  @override
  LinkedHashMap<DateTime, List<ScheduleModel>> build() {
    final userId = ref.watch(authProvider).userId;
    if (userId == null) {
      return LinkedHashMap<DateTime, List<ScheduleModel>>(
        equals: isSameDay,
        hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
      );
    }
    _userId = userId;
    _listenToEvents();
    return LinkedHashMap<DateTime, List<ScheduleModel>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );
  }

  void _listenToEvents() {
    if (_userId == null) return;
    _db.child('schedules').child(_userId!).onValue.listen((event) {
      final rawData = event.snapshot.value;
      if (rawData == null) {
        state = LinkedHashMap(
          equals: isSameDay,
          hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
        );
        return;
      }
      final Map<DateTime, List<ScheduleModel>> eventsMap = {};
      void processItem(dynamic value) {
        try {
          if (value == null) return;
          final eventMap = Map<String, dynamic>.from(value as Map);
          final scheduleEvent = ScheduleModel.fromJson(eventMap);

          final eventDate = DateTime(
            scheduleEvent.startTime.year,
            scheduleEvent.startTime.month,
            scheduleEvent.startTime.day,
          );
          eventsMap.putIfAbsent(eventDate, () => []).add(scheduleEvent);
        } catch (e) {
          print('Bỏ qua mục không hợp lệ: $e');
        }
      }

      try {
        if (rawData is Map) {
          rawData.forEach((key, value) => processItem(value));
        } else if (rawData is List) {
          for (var value in rawData) {
            processItem(value);
          }
        }
      } catch (e) {
        print('Lỗi khi xử lý dữ liệu lịch trình: $e');
      }

      final newState = LinkedHashMap<DateTime, List<ScheduleModel>>(
        equals: isSameDay,
        hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
      )..addAll(eventsMap);
      state = newState;
    });
  }

  List<ScheduleModel> getEventsForDay(DateTime day) => state[day] ?? [];

  Future<void> addEvent(ScheduleModel event) async {
    if (_userId == null) return;
    final day = DateTime(
      event.startTime.year,
      event.startTime.month,
      event.startTime.day,
    );
    final newState = LinkedHashMap<DateTime, List<ScheduleModel>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    )..addAll(state);
    newState[day] = [...newState[day] ?? [], event];
    state = newState;
    await _db
        .child('schedules')
        .child(_userId!)
        .child(event.id)
        .set(event.toJson());
    await NotificationsService.schedule(event);

    if (event.endTime != null) {
      final endReminderTime = event.endTime!.subtract(
        const Duration(minutes: 0),
      );
      await NotificationsService.schedule(
        event,
        specificTime: endReminderTime,
        idSuffix: '_end',
      );
    }
  }

  Duration _parseDuration(String reminder) {
    if (reminder.contains('1 phút')) return const Duration(minutes: 1);
    if (reminder.contains('5 phút')) return const Duration(minutes: 5);
    if (reminder.contains('1 giờ')) return const Duration(hours: 1);
    if (reminder.contains('1 ngày')) return const Duration(days: 1);
    return Duration.zero;
  }

  Future<void> removeEvent(String eventId) async {
    if (_userId == null) return;
    if (!state.values.any((list) => list.any((ev) => ev.id == eventId))) {
      return;
    }
    final day = state.entries
        .firstWhere((e) => e.value.any((ev) => ev.id == eventId))
        .key;
    final event = state[day]!.firstWhere((ev) => ev.id == eventId);
    _lastDeleted = event;
    final newState = LinkedHashMap<DateTime, List<ScheduleModel>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    )..addAll(state);
    newState[day] = newState[day]!.where((ev) => ev.id != eventId).toList();
    if (newState[day]!.isEmpty) {
      newState.remove(day);
    }
    state = newState;
    await _db.child('schedules').child(_userId!).child(eventId).remove();
    await NotificationsService.cancel(eventId);
  }

  Future<void> undoRemove() async {
    if (_lastDeleted != null) {
      await addEvent(_lastDeleted!);
      _lastDeleted = null;
    }
  }

  Future<void> editEvent(ScheduleModel updateEvent) async {
    if (_userId == null) return;
    if (!state.values.any(
      (list) => list.any((ev) => ev.id == updateEvent.id),
    )) {
      await addEvent(updateEvent);
      return;
    }
    final oldDay = state.entries
        .firstWhere((e) => e.value.any((ev) => ev.id == updateEvent.id))
        .key;
    final newDay = DateTime(
      updateEvent.startTime.year,
      updateEvent.startTime.month,
      updateEvent.startTime.day,
    );
    final newState = LinkedHashMap<DateTime, List<ScheduleModel>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    )..addAll(state);

    newState[oldDay] = newState[oldDay]!
        .where((ev) => ev.id != updateEvent.id)
        .toList();
    if (newState[oldDay]!.isEmpty) {
      newState.remove(oldDay);
    }

    newState[newDay] = [...newState[newDay] ?? [], updateEvent];
    state = newState;
    await _db
        .child('schedules')
        .child(_userId!)
        .child(updateEvent.id)
        .set(updateEvent.toJson());

    await NotificationsService.cancel(updateEvent.id);
    if (updateEvent.reminder != null && updateEvent.reminder != 'Không nhắc') {
      Duration duration = _parseDuration(updateEvent.reminder!);
      DateTime notificationTime = updateEvent.startTime.subtract(duration);
      if (notificationTime.isAfter(DateTime.now())) {
        await NotificationsService.schedule(updateEvent);
      }
    }
    if (updateEvent.endTime != null) {
      final endReminderTime = updateEvent.endTime!.subtract(
        const Duration(minutes: 0),
      );
      if (endReminderTime.isAfter(DateTime.now())) {
        await NotificationsService.schedule(
          updateEvent,
          specificTime: endReminderTime,
          idSuffix: '_end',
        );
      }
    }
  }
}

final schedulerProvider =
    NotifierProvider<
      SchedulerProvider,
      LinkedHashMap<DateTime, List<ScheduleModel>>
    >(() => SchedulerProvider());
