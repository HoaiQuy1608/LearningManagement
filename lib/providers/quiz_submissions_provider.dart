import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';

final quizSubmissionsProvider = StreamProvider.autoDispose
    .family<List<QuizAttempt>, String>((ref, quizId) {
      final dbRef = FirebaseDatabase.instance.ref('quiz_attempts/$quizId');

      return dbRef.onValue.map((event) {
        final data = event.snapshot.value as Map<Object?, Object?>?;
        if (data == null) return [];

        final List<QuizAttempt> submissions = [];

        data.forEach((attemptId, attemptData) {
          try {
            final map = Map<String, dynamic>.from(attemptData as Map);
            submissions.add(QuizAttempt.fromJson(map));
          } catch (e) {
            print('Lỗi parse bài nộp: $e');
          }
        });
        submissions.sort((a, b) => b.score.compareTo(a.score));
        return submissions;
      });
    });
