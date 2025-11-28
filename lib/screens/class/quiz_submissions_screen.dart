import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/screens/class/grading_screen.dart';
import 'package:learningmanagement/providers/quiz_submissions_provider.dart';

class QuizSubmissionsScreen extends ConsumerWidget {
  final Quiz quiz;
  const QuizSubmissionsScreen({super.key, required this.quiz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(quizSubmissionsProvider(quiz.quizId));

    return Scaffold(
      appBar: AppBar(title: Text('Bài nộp - ${quiz.title}')),
      body: asyncData.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
        data: (attempts) {
          if (attempts.isEmpty) {
            return const Center(child: Text('Chưa có sinh viên nào nộp bài.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: attempts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final attempt = attempts[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, color: Colors.blue),
                ),
                title: FutureBuilder(
                  future: FirebaseDatabase.instance
                      .ref('users/${attempt.userId}/displayName')
                      .get(),
                  builder: (ctx, snap) {
                    if (snap.hasData && snap.data!.value != null) {
                      return Text(
                        snap.data!.value.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      );
                    }
                    return Text('ID: ${attempt.userId.substring(0, 5)}...');
                  },
                ),
                subtitle: Text(
                  'Nộp: ${DateFormat('dd/MM HH:mm').format(attempt.submittedAt)}',
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: attempt.score >= 5
                        ? Colors.green[100]
                        : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${attempt.score}đ',
                    style: TextStyle(
                      color: attempt.score >= 5
                          ? Colors.green[800]
                          : Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GradingScreen(quiz: quiz, attempt: attempt),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
