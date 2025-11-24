import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
import 'package:learningmanagement/providers/quiz_history_provider.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/take_quiz_screen.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/create_quiz_screen.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/quiz_result_screen.dart';
import 'package:learningmanagement/widgets/quizs/quiz_item_card.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/models/quiz_model.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  void _handleDoneQuizTap(
    BuildContext context,
    Quiz quiz,
    List<QuizAttempt> attempts,
  ) {
    final latestAttempt = attempts.first;
    final attemptsCount = attempts.length;
    String maxAttemptLabel = (quiz.maxAttempt >= 99)
        ? "Không giới hạn"
        : "${quiz.maxAttempt}";

    bool canRetake = false;
    if (quiz.maxAttempt >= 99) {
      canRetake = true;
    } else {
      canRetake = attemptsCount < quiz.maxAttempt;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(quiz.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điểm số mới nhất: ${latestAttempt.score}'),
            const SizedBox(height: 8),

            Text(
              'Số lần đã làm: $attemptsCount / $maxAttemptLabel',
              style: TextStyle(
                color: canRetake ? Colors.black : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (!canRetake)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Bạn đã hết lượt làm bài!',
                  style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      QuizResultScreen(quiz: quiz, attempt: latestAttempt),
                ),
              );
            },
            child: const Text('Xem kết quả'),
          ),
          if (canRetake)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TakeQuizScreen(quiz: quiz)),
                );
              },
              child: const Text('Làm lại'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final historyAsync = ref.watch(quizHistoryProvider);

    Widget bodyContent;

    if (quizState.isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (quizState.quizzes.isEmpty) {
      bodyContent = const Center(child: Text('Chưa có bài kiểm tra nào.'));
    } else {
      bodyContent = historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (historyMap) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: quizState.quizzes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quiz = quizState.quizzes[index];

              final attemptsList = historyMap[quiz.quizId];
              final isDone = (attemptsList != null && attemptsList.isNotEmpty);
              final latestAttempt = isDone ? attemptsList.first : null;

              return QuizItemCard(
                quiz: quiz,
                attempt: latestAttempt,
                onTap: () {
                  if (isDone) {
                    _handleDoneQuizTap(context, quiz, attemptsList);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TakeQuizScreen(quiz: quiz),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bài Kiểm Tra')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
          );
        },
      ),
      body: bodyContent,
    );
  }
}
