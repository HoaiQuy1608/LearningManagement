import 'package:flutter/material.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/widgets/quizs/question_review_card.dart';

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
                return QuestionReviewCard(
                  index: index,
                  question: question,
                  attempt: attempt,
                );
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
}
