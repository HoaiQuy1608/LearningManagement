import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/deadline_countdown_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

final deadlineCountdownProvider =
    NotifierProvider<
      DeadlineCountdownProvider,
      Map<String, DeadlineCountdownModel>
    >(() => DeadlineCountdownProvider());

class DeadlineCountdownProvider
    extends Notifier<Map<String, DeadlineCountdownModel>> {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  late final String _userId;

  @override
  Map<String, DeadlineCountdownModel> build() {
    final userId = ref.watch(authProvider).userId;
    if (userId == null) {
      return {};
    }
    _userId = userId;
    _listenToCountdowns();
    return {};
  }

  void _listenToCountdowns() {
    _db.child('deadline_countdowns').child(_userId).onValue.listen((event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data == null) {
        state = {};
        return;
      }
      final Map<String, DeadlineCountdownModel> newState = {};
      data.forEach((key, value) {
        if (value is! Map<Object?, Object?>) return;
        final map = value;
        final countdown = DeadlineCountdownModel.fromJson(
          Map<String, dynamic>.from(map),
        );
        newState[countdown.scheduleId] = countdown;
      });
      state = newState;
    });
  }

  DeadlineCountdownModel? getByScheduleId(String scheduleId) =>
      state[scheduleId];

  Future<void> markAsCompleted(String scheduleId) async {
    final countdown = state[scheduleId];
    if (countdown == null || countdown.isCompleted) return;
    final updated = DeadlineCountdownModel(
      id: countdown.id,
      scheduleId: countdown.scheduleId,
      deadline: countdown.deadline,
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    state = {...state, scheduleId: updated};

    await _db
        .child('deadline_countdowns')
        .child(_userId)
        .child(countdown.id)
        .set(updated.toJson());
  }

  Future<void> createOrUpdate(String scheduleId, DateTime deadline) async {
    final existing = state[scheduleId];
    String id;
    if (existing != null) {
      id = existing.id;
    } else {
      id = _db.child('deadline_countdowns').child(_userId).push().key!;
    }
    final countdown = DeadlineCountdownModel(
      id: id,
      scheduleId: scheduleId,
      deadline: deadline,
    );
    state = {...state, scheduleId: countdown};
    await _db
        .child('deadline_countdowns')
        .child(_userId)
        .child(id)
        .set(countdown.toJson());
  }
}
