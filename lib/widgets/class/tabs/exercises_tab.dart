import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
import 'package:learningmanagement/providers/quiz_history_provider.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/screens/Quiz_screens/quiz_result_screen.dart';
import 'package:learningmanagement/screens/Quiz_screens/take_quiz_screen.dart';
import 'package:learningmanagement/screens/class/quiz_submissions_screen.dart';
import 'package:learningmanagement/widgets/quizs/quiz_item_card.dart';

class ExercisesTab extends ConsumerWidget {
  final String classId;
  final bool isTeacher;
  const ExercisesTab({
    super.key,
    required this.classId,
    required this.isTeacher,
  });

  void _showAssignDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final allQuizzes = ref.watch(quizProvider).quizzes;
        final myId = ref.read(authProvider).userId;

        final availableQuizzes = allQuizzes.where((q) {
          return q.creatorId == myId && (q.classId == null || q.classId == '');
        }).toList();

        return Container(
          padding: const EdgeInsets.all(16),
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn bài tập để giao:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: availableQuizzes.isEmpty
                    ? const Center(
                        child: Text(
                          'Không còn bài quiz nào trống.\nHãy tạo thêm quiz mới ở ngoài trang chủ.',
                        ),
                      )
                    : ListView.separated(
                        itemCount: availableQuizzes.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final q = availableQuizzes[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.description,
                              color: Colors.blue,
                            ),
                            title: Text(
                              q.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${q.questions.length} câu hỏi • ${q.timeLimit} phút',
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await ref
                                    .read(quizProvider.notifier)
                                    .assignQuizToClass(q.quizId, classId);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã giao bài "${q.title}" cho lớp!',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Giao'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final historyAsync = ref.watch(quizHistoryProvider);
    final classQuizzes = quizState.quizzes
        .where((q) => q.classId == classId)
        .toList();

    return Scaffold(
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              onPressed: () => _showAssignDialog(context, ref),
              label: const Text('Giao Bài'),
              icon: const Icon(Icons.assignment_add),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
        data: (historyMap) {
          if (classQuizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Lớp chưa có bài tập nào',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: classQuizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quiz = classQuizzes[index];

              final attemptsList = historyMap[quiz.quizId];
              final isDone = (attemptsList != null && attemptsList.isNotEmpty);
              final latestAttempt = isDone ? attemptsList.first : null;

              return QuizItemCard(
                quiz: quiz,
                attempt: latestAttempt,
                onTap: () {
                  if (isTeacher) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizSubmissionsScreen(quiz: quiz),
                      ),
                    );
                  } else {
                    if (isDone) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizResultScreen(
                            quiz: quiz,
                            attempt: latestAttempt!,
                          ),
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
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
