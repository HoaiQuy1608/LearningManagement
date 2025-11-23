import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/providers/quiz_attempt_provider.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/quiz_result_screen.dart';

class TakeQuizScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  const TakeQuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends ConsumerState<TakeQuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizAttemptProvider.notifier).startQuiz(widget.quiz);
    });
  }

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(quizAttemptProvider);
    if (attempt == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final qIndex = attempt.currentQuestionIndex;
    final question = widget.quiz.questions[qIndex];

    List<String> selectedOpts = [];
    try {
      final ans = attempt.multipleChoiceAnswers.firstWhere(
        (a) => a.questionId == question.questionId,
      );
      selectedOpts = ans.selectedOptions;
    } catch (_) {}
    String essayTxt = '';
    try {
      final ans = attempt.essayAnswers.firstWhere(
        (a) => a.questionId == question.questionId,
      );
      essayTxt = ans.answerText;
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '${(attempt.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(attempt.timeLeft % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: attempt.timeLeft < 60 ? Colors.red : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (qIndex + 1) / widget.quiz.questions.length,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Câu ${qIndex + 1}',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.content,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (question.type == QuestionType.essay)
                    TextField(
                      key: ValueKey(question.questionId),
                      controller: TextEditingController(text: essayTxt)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: essayTxt.length),
                        ),
                      maxLines: 6,
                      decoration: const InputDecoration(
                        hintText: 'Nhập câu trả lời...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => ref
                          .read(quizAttemptProvider.notifier)
                          .inputEssayAnswer(question.questionId, v),
                    )
                  else
                    ...question.options.map((opt) {
                      final isSelected = selectedOpts.contains(opt.answerId);
                      return Card(
                        elevation: 0,
                        color: isSelected ? Colors.blue[50] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.blue
                                : Colors.grey.shade300,
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          onTap: () => ref
                              .read(quizAttemptProvider.notifier)
                              .selectAnswer(
                                question.questionId,
                                opt.answerId,
                                question.type == QuestionType.multiSelect,
                              ),
                          leading: Icon(
                            isSelected
                                ? (question.type == QuestionType.multiSelect
                                      ? Icons.check_box
                                      : Icons.radio_button_checked)
                                : (question.type == QuestionType.multiSelect
                                      ? Icons.check_box_outline_blank
                                      : Icons.radio_button_unchecked),
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(
                            opt.answerText,
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (qIndex > 0)
                  OutlinedButton(
                    onPressed: () =>
                        ref.read(quizAttemptProvider.notifier).prevQuestion(),
                    child: const Text('Quay lại'),
                  )
                else
                  const SizedBox(width: 100),

                if (qIndex < widget.quiz.questions.length - 1)
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(quizAttemptProvider.notifier).nextQuestion(),
                    child: const Text('Tiếp theo'),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await ref.read(quizAttemptProvider.notifier).submitQuiz();
                      if (context.mounted) {
                        final result = ref.read(quizAttemptProvider);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizResultScreen(
                              quiz: widget.quiz,
                              attempt: result!,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('NỘP BÀI'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
