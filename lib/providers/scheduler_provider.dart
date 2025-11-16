import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'dart:collection';
import 'package:learningmanagement/main.dart';
import 'package:learningmanagement/service/notifications_service.dart';

class SchedulerProvider
    extends Notifier<LinkedHashMap<DateTime, List<ScheduleModel>>> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  late final String _userId;
  ScheduleModel? _lastDeleted;

  @override
  LinkedHashMap<DateTime, List<ScheduleModel>> build() {
    _userId = ref.read(authProvider).userId!;
    _listenToEvents();
    return LinkedHashMap<DateTime, List<ScheduleModel>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );
  }

  void _listenToEvents() {
    _db.child('schedules').child(_userId).onValue.listen((event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data == null) {
        state = LinkedHashMap<DateTime, List<ScheduleModel>>(
          equals: isSameDay,
          hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
        );
        return;
      }
      final Map<DateTime, List<ScheduleModel>> eventsMap = {};
      data.forEach((key, value) {
        final eventMap = value as Map<Object?, Object?>;
        final event = ScheduleModel.fromMap(
          Map<String, dynamic>.from(eventMap),
        );
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        eventsMap.putIfAbsent(eventDate, () => []).add(event);
      });

      final newState = LinkedHashMap<DateTime, List<ScheduleModel>>(
        equals: isSameDay,
        hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
      )..addAll(eventsMap);
      state = newState;
    });
  }

  List<ScheduleModel> getEventsForDay(DateTime day) => state[day] ?? [];

  Future<void> addEvent(ScheduleModel event) async {
    final day = DateTime(
      event.startTime.year,
      event.startTime.month,
      event.startTime.day,
    );
    final newState = LinkedHashMap<DateTime, List<ScheduleModel>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    )..addAll(state);
    newState[day] = [...?newState[day], event];
    state = newState;
    await _db
        .child('schedules')
        .child(_userId)
        .child(event.id)
        .set(event.toMap());
    await NotificationsService.schedule(event);
  }

  Future<void> removeEvent(String eventId, BuildContext context) async {
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
    state = newState;
    await _db.child('schedules').child(_userId).child(eventId).remove();
    await NotificationsService.cancel(eventId);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã xóa sự kiện'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            if (_lastDeleted != null) {
              addEvent(_lastDeleted!);
              _lastDeleted = null;
            }
          },
        ),
      ),
    );
  }

  Future<void> editEvent(ScheduleModel updateEvent) async {
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

    newState[newDay] = [...?newState[newDay], updateEvent];
    state = newState;
    await _db
        .child('schedules')
        .child(_userId)
        .child(updateEvent.id)
        .set(updateEvent.toMap());
  }
}

final schedulerProvider =
    NotifierProvider<
      SchedulerProvider,
      LinkedHashMap<DateTime, List<ScheduleModel>>
    >(() => SchedulerProvider());
