import 'package:flutter/material.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';

class QuestionReviewCard extends StatelessWidget {
  final int index;
  final Question question;
  final QuizAttempt attempt;

  const QuestionReviewCard({
    super.key,
    required this.index,
    required this.question,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    List<String> userSelectedIds = [];
    String essayText = '';

    try {
      if (question.type == QuestionType.essay) {
        final essay = attempt.essayAnswers.firstWhere(
          (a) => a.questionId == question.questionId,
        );
        essayText = essay.answerText;
      } else {
        final mcq = attempt.multipleChoiceAnswers.firstWhere(
          (a) => a.questionId == question.questionId,
        );
        userSelectedIds = mcq.selectedOptions;
      }
    } catch (_) {}

    bool isQuestionCorrect = false;
    if (question.type != QuestionType.essay) {
      final correctIds = question.options
          .where((o) => o.isCorrect)
          .map((o) => o.answerId)
          .toSet();
      final userIds = userSelectedIds.toSet();
      isQuestionCorrect =
          (userIds.length == correctIds.length &&
          userIds.containsAll(correctIds));
    }

    Color borderColor = Colors.grey.shade300;
    if (question.type != QuestionType.essay) {
      borderColor = isQuestionCorrect ? Colors.green : Colors.red;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Đề bài
            Text(
              'Câu ${index + 1}: ${question.content}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            if (question.type == QuestionType.essay) ...[
              const Text(
                'Bài làm của bạn:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                essayText.isEmpty ? '(Bỏ trống)' : essayText,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Chờ giáo viên chấm',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            ] else ...[
              ...question.options.map((option) {
                final isSelected = userSelectedIds.contains(option.answerId);
                final isCorrectOption = option.isCorrect;

                Color textColor = Colors.black87;
                IconData icon = Icons.radio_button_unchecked;
                Color iconColor = Colors.grey;

                if (isCorrectOption) {
                  textColor = Colors.green;
                  icon = Icons.check_circle;
                  iconColor = Colors.green;
                } else if (isSelected && !isCorrectOption) {
                  textColor = Colors.red;
                  icon = Icons.cancel;
                  iconColor = Colors.red;
                } else if (isSelected) {
                  icon = Icons.check_circle;
                  iconColor = Colors.green;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(icon, size: 20, color: iconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          option.answerText,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: (isCorrectOption || isSelected)
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
