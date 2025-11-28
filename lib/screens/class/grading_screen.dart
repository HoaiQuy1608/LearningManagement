import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/providers/grading_provider.dart';
import 'package:learningmanagement/widgets/class/grading/auto_graded_card.dart';
import 'package:learningmanagement/widgets/class/grading/manual_grading_card.dart';

class GradingScreen extends ConsumerWidget {
  final Quiz quiz;
  final QuizAttempt attempt;

  const GradingScreen({super.key, required this.quiz, required this.attempt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Chấm bài')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: quiz.questions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final question = quiz.questions[index];

          if (question.type != QuestionType.essay) {
            return AutoGradedCard(index: index, question: question);
          }

          String studentAnswer = '';
          double currentScore = 0;
          try {
            final ans = attempt.essayAnswers.firstWhere(
              (a) => a.questionId == question.questionId,
            );
            studentAnswer = ans.answerText;
            currentScore = ans.teacherScore;
          } catch (_) {}

          return ManualGradingCard(
            index: index,
            question: question,
            studentAnswer: studentAnswer,
            currentScore: currentScore,
            onSaveScore: (newScore) async {
              await ref
                  .read(gradingProvider)
                  .updateEssayGrade(
                    quizId: quiz.quizId,
                    attemptId: attempt.attemptId,
                    questionId: question.questionId,
                    newScore: double.tryParse(newScore) ?? 0,
                    currentAttempt: attempt,
                  );

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Đã lưu điểm!')));
              }
            },
          );
        },
      ),
    );
  }
}
