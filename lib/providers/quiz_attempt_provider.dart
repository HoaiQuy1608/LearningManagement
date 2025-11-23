import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/models/essay_answer_model.dart';
import 'package:learningmanagement/models/multiple_choice_answer_model.dart';

class QuizAttemptProvider extends Notifier<QuizAttempt?> {
  final _db = FirebaseDatabase.instance.ref();
  Timer? _timer;
  Quiz? _currentQuiz;

  @override
  QuizAttempt? build() {
    return null;
  }

  void startQuiz(Quiz quiz) {
    _currentQuiz = quiz;
    final userId = ref.read(authProvider).userId ?? 'guest';

    state = QuizAttempt(
      attemptId: const Uuid().v4(),
      quizId: quiz.quizId,
      userId: userId,
      score: 0,
      startedAt: DateTime.now(),
      submittedAt: DateTime.now(),
      essayAnswers: [],
      multipleChoiceAnswers: [],
      timeLeft: quiz.timeLimit * 60,
      currentQuestionIndex: 0,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      if (state!.timeLeft > 0) {
        state = state!.copyWith(timeLeft: state!.timeLeft - 1);
      } else {
        timer.cancel();
        submitQuiz();
      }
    });
  }

  void selectAnswer(String questionId, String answerId, bool isMultiSelect) {
    if (state == null) return;
    final currentList = List<MultipleChoiceAnswer>.from(
      state!.multipleChoiceAnswers,
    );
    final index = currentList.indexWhere((a) => a.questionId == questionId);

    List<String> selectedOptions = [];
    String currentAnswerId = const Uuid().v4();

    if (index != -1) {
      selectedOptions = List.from(currentList[index].selectedOptions);
      currentAnswerId = currentList[index].answerId;
    }
    if (isMultiSelect) {
      if (selectedOptions.contains(answerId)) {
        selectedOptions.remove(answerId);
      } else {
        selectedOptions.add(answerId);
      }
    } else {
      selectedOptions = [answerId];
    }

    final newAnswer = MultipleChoiceAnswer(
      answerId: currentAnswerId,
      attemptId: state!.attemptId,
      questionId: questionId,
      selectedOptions: selectedOptions,
      score: 0,
    );

    if (index != -1) {
      currentList[index] = newAnswer;
    } else {
      currentList.add(newAnswer);
    }
    state = state!.copyWith(multipleChoiceAnswers: currentList);
  }

  void inputEssayAnswer(String questionId, String text) {
    if (state == null) return;
    final currentList = List<EssayAnswer>.from(state!.essayAnswers);
    final index = currentList.indexWhere((a) => a.questionId == questionId);
    String currentEssayId = const Uuid().v4();
    if (index != -1) {
      currentEssayId = currentList[index].essayId;
    }
    final newAnswer = EssayAnswer(
      essayId: currentEssayId,
      attemptId: state!.attemptId,
      questionId: questionId,
      answerText: text,
      teacherScore: 0,
    );
    if (index != -1) {
      currentList[index] = newAnswer;
    } else {
      currentList.add(newAnswer);
    }
    state = state!.copyWith(essayAnswers: currentList);
  }

  void nextQuestion() {
    if (state != null &&
        _currentQuiz != null &&
        state!.currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      state = state!.copyWith(
        currentQuestionIndex: state!.currentQuestionIndex + 1,
      );
    }
  }

  void prevQuestion() {
    if (state != null && state!.currentQuestionIndex > 0) {
      state = state!.copyWith(
        currentQuestionIndex: state!.currentQuestionIndex - 1,
      );
    }
  }

  Future<void> submitQuiz() async {
    if (state == null || state!.isSubmitting || _currentQuiz == null) return;
    state = state!.copyWith(isSubmitting: true);
    double totalScore = 0;
    final calculatedMcq = state!.multipleChoiceAnswers.map((ans) {
      final question = _currentQuiz!.questions.firstWhere(
        (q) => q.questionId == ans.questionId,
      );
      final correctIds = question.options
          .where((o) => o.isCorrect)
          .map((o) => o.answerId)
          .toSet();
      final userIds = ans.selectedOptions.toSet();
      final isCorrect =
          (userIds.length == correctIds.length) &&
          userIds.containsAll(correctIds);
      final points = isCorrect ? question.point : 0.0;
      totalScore += points;

      return ans.copyWith(score: points);
    }).toList();

    state = state!.copyWith(
      score: totalScore,
      submittedAt: DateTime.now(),
      multipleChoiceAnswers: calculatedMcq,
    );

    try {
      await _db
          .child('quiz_attempts')
          .child(state!.quizId)
          .child(state!.attemptId)
          .set(state!.toJson());
    } catch (e) {
      print('Lỗi nộp bài quiz: $e');
    } finally {
      state = state!.copyWith(isSubmitting: false);
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}

final quizAttemptProvider = NotifierProvider<QuizAttemptProvider, QuizAttempt?>(
  () {
    return QuizAttemptProvider();
  },
);
