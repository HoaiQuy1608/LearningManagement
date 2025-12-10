import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
import 'package:learningmanagement/providers/quiz_history_provider.dart';
import 'package:learningmanagement/screens/Quiz_screens/take_quiz_screen.dart';
import 'package:learningmanagement/screens/Quiz_screens/create_quiz_screen.dart';
import 'package:learningmanagement/screens/Quiz_screens/quiz_result_screen.dart';
import 'package:learningmanagement/widgets/quizs/quiz_item_card.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/models/quiz_model.dart';

class QuizListScreen extends ConsumerWidget {
  final bool showAppBar;
  const QuizListScreen({super.key, this.showAppBar = true});

  void _handleDoneQuizTap(BuildContext context, Quiz quiz, List<QuizAttempt> attempts) {
    final latestAttempt = attempts.first;
    final attemptsCount = attempts.length;
    String maxAttemptLabel = (quiz.maxAttempt >= 99) ? "Không giới hạn" : "${quiz.maxAttempt}";
    bool canRetake = quiz.maxAttempt >= 99 || attemptsCount < quiz.maxAttempt;

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
            Text('Số lần đã làm: $attemptsCount / $maxAttemptLabel',
                style: TextStyle(color: canRetake ? Colors.black : Colors.red, fontWeight: FontWeight.bold)),
            if (!canRetake)
              const Padding(padding: EdgeInsets.only(top: 8.0), child: Text('Bạn đã hết lượt làm bài!', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => QuizResultScreen(quiz: quiz, attempt: latestAttempt)));
            },
            child: const Text('Xem kết quả'),
          ),
          if (canRetake)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => TakeQuizScreen(quiz: quiz)));
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

    Widget bodyContent = quizState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : quizState.quizzes.isEmpty
            ? const Center(child: Text('Chưa có bài kiểm tra nào.'))
            : historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Lỗi: $err')),
                data: (historyMap) => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizState.quizzes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final quiz = quizState.quizzes[index];
                    final attemptsList = historyMap[quiz.quizId] ?? [];
                    final isDone = attemptsList.isNotEmpty;
                    final latestAttempt = isDone ? attemptsList.first : null;

                    return QuizItemCard(
                      quiz: quiz,
                      attempt: latestAttempt,
                      onTap: () => isDone
                          ? _handleDoneQuizTap(context, quiz, attemptsList)
                          : Navigator.push(context, MaterialPageRoute(builder: (_) => TakeQuizScreen(quiz: quiz))),
                    );
                  },
                ),
              );

    final contentWithFab = Scaffold(
      body: bodyContent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQuizScreen())),
      ),
    );

    if (!showAppBar) return contentWithFab;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bài kiểm tra", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFF8A63D2)]),
          ),
        ),
      ),
      body: contentWithFab.body,
      floatingActionButton: contentWithFab.floatingActionButton,
    );
  }
}