import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/models/essay_answer_model.dart';

final gradingProvider = Provider((ref) => GradingController());

class GradingController {
  final _db = FirebaseDatabase.instance.ref();

  Future<void> updateEssayGrade({
    required String quizId,
    required String attemptId,
    required String questionId,
    required double newScore,
    required QuizAttempt currentAttempt,
  }) async {
    final updatedEssayAnswers = currentAttempt.essayAnswers.map((answer) {
      if (answer.questionId == questionId) {
        return EssayAnswer(
          essayId: answer.essayId,
          attemptId: answer.attemptId,
          questionId: answer.questionId,
          answerText: answer.answerText,
          teacherScore: newScore,
          teacherComment: "Đã chấm",
        );
      }
      return answer;
    }).toList();

    double totalMcqScore = currentAttempt.multipleChoiceAnswers.fold(
      0,
      (sum, item) => sum + item.score,
    );
    double totalEssayScore = updatedEssayAnswers.fold(
      0,
      (sum, item) => sum + item.teacherScore,
    );
    final finalScore = totalMcqScore + totalEssayScore;

    final updateAttempt = currentAttempt.copyWith(
      score: finalScore,
      essayAnswers: updatedEssayAnswers,
    );
    await _db
        .child('quiz_attempts')
        .child(quizId)
        .child(attemptId)
        .set(updateAttempt.toJson());
  }
}
