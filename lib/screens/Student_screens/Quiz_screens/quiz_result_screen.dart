import 'package:flutter/material.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/models/question_model.dart';

class QuizResultScreen extends StatelessWidget {
  final Quiz quiz;
  final QuizAttempt attempt;

  const QuizResultScreen({
    super.key,
    required this.quiz,
    required this.attempt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài quiz'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade100, width: 4),
              ),
              child: Column(
                children: [
                  Text(
                    '${attempt.score}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Text(
                    'Điểm số',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chi tiết bài làm:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quiz.questions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final question = quiz.questions[index];
                return _buildQuestionResultItem(index, question);
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              child: const Text(
                'Về trang chủ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionResultItem(int index, Question question) {
    List<String> userSelectedIds = [];
    try {
      final mcq = attempt.multipleChoiceAnswers.firstWhere(
        (a) => a.questionId == question.questionId,
      );
      userSelectedIds = mcq.selectedOptions;
    } catch (_) {}

    String essayText = '';
    try {
      final essay = attempt.essayAnswers.firstWhere(
        (a) => a.questionId == question.questionId,
      );
      essayText = essay.answerText;
    } catch (_) {}

    bool isCorrect = false;
    if (question.type != QuestionType.essay) {
      final correctIds = question.options
          .where((o) => o.isCorrect)
          .map((o) => o.answerId)
          .toSet();
      final userIds = userSelectedIds.toSet();
      isCorrect =
          (userIds.length == correctIds.length &&
          userIds.containsAll(correctIds));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: question.type == QuestionType.essay
              ? Colors.grey.shade300
              : (isCorrect ? Colors.green : Colors.red),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Câu ${index + 1}: ${question.content}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (question.type == QuestionType.essay) ...[
              const Text(
                'Đáp án của bạn:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                essayText.isEmpty ? 'Chưa trả lời' : essayText,
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
                  'Chờ giáo viên chấm điểm.',
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
