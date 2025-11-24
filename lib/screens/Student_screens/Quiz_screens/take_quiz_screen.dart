import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/answer_model.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/providers/quiz_attempt_provider.dart';
import 'package:learningmanagement/widgets/quizs/answer_option_tile.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/quiz_result_screen.dart';

class TakeQuizScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  const TakeQuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<TakeQuizScreen> createState() => _TakeQuizScreenState();
}

class _TakeQuizScreenState extends ConsumerState<TakeQuizScreen> {
  late List<Question> _processedQuestions;
  @override
  void initState() {
    super.initState();
    _processedQuestions = List.from(widget.quiz.questions);
    if (widget.quiz.randomQuestions) {
      _processedQuestions.shuffle();
    }
    if (widget.quiz.randomAnswers) {
      _processedQuestions = _processedQuestions.map((q) {
        if (q.type == QuestionType.essay) return q;

        final shuffledOptions = List<AnswerOption>.from(q.options);
        shuffledOptions.shuffle();

        return q.copyWith(options: shuffledOptions);
      }).toList();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizAttemptProvider.notifier).startQuiz(widget.quiz);
    });
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(quizAttemptProvider);
    if (attempt == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final qIndex = attempt.currentQuestionIndex;
    final question = _processedQuestions[qIndex];

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
                _formatTime(attempt.timeLeft),
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
            value: (qIndex + 1) / _processedQuestions.length,
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
                      return AnswerOptionTile(
                        text: opt.answerText,
                        isSelected: selectedOpts.contains(opt.answerId),
                        isMultiSelect:
                            question.type == QuestionType.multiSelect,
                        onTap: () => ref
                            .read(quizAttemptProvider.notifier)
                            .selectAnswer(
                              question.questionId,
                              opt.answerId,
                              question.type == QuestionType.multiSelect,
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

                if (qIndex < _processedQuestions.length - 1)
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
