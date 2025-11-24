import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

final quizHistoryProvider =
    StreamProvider.autoDispose<Map<String, List<QuizAttempt>>>((ref) {
      final userId = ref.watch(authProvider).userId;
      if (userId == null) return Stream.value({});
      final dbRef = FirebaseDatabase.instance.ref('quiz_attempts');

      return dbRef.onValue.map((event) {
        final data = event.snapshot.value as Map<Object?, Object?>?;
        if (data == null) return {};

        final Map<String, List<QuizAttempt>> userHistory = {};

        data.forEach((quizIdKey, attemptsMap) {
          final quizId = quizIdKey as String;
          final attempts = attemptsMap as Map<Object?, Object?>;
          if (!userHistory.containsKey(quizId)) {
            userHistory[quizId] = [];
          }
          attempts.forEach((attemptId, attemptData) {
            final map = Map<String, dynamic>.from(attemptData as Map);
            if (map['userId'] == userId) {
              try {
                userHistory[quizId]!.add(QuizAttempt.fromJson(map));
              } catch (e) {
                print('lỗi parse lịch sử quiz: $e');
              }
            }
          });
          userHistory[quizId]!.sort(
            (a, b) => b.submittedAt.compareTo(a.submittedAt),
          );
        });
        return userHistory;
      });
    });
