import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
import 'package:learningmanagement/providers/quiz_history_provider.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/take_quiz_screen.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/create_quiz_screen.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/quiz_result_screen.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

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
              final attempt = historyMap[quiz.quizId];
              final isDone = attempt != null;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (isDone) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              QuizResultScreen(quiz: quiz, attempt: attempt),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TakeQuizScreen(quiz: quiz),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? Colors.green[50]
                                    : Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isDone ? Icons.check_circle : Icons.school,
                                color: isDone ? Colors.green : Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quiz.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    quiz.subject,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isDone)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${attempt.score}đ',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${quiz.timeLimit}p',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.help_outline,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${quiz.questions.length} câu hỏi',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              isDone ? 'Xem kết quả' : 'Làm bài ngay',
                              style: TextStyle(
                                color: isDone ? Colors.green : Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: isDone ? Colors.green : Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
