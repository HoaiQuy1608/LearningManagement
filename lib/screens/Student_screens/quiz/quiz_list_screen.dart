import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
import 'create_quiz_screen.dart';

class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final quizzes = quizState.quizzes;

    return Stack(
      children: [
        ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.quiz_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text('${quiz.title}: ${quiz.subject}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.question_answer_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.0),
                        Text('${quiz.questionCount} câu'),
                        SizedBox(width: 16.0),
                        const Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4.0),
                        Text('${quiz.timeLimitMinutes} phút'),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14.0),
                onTap: () {
                  print('TODO: Mở bài quiz ${quiz.title}');
                },
              ),
            );
          },
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateQuizScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        ),
        if (quizState.isLoading)
          Container(
            color: Colors.black.withAlpha(77),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
