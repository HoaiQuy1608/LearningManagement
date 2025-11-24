import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

@immutable
class QuizState {
  final List<Quiz> quizzes;
  final bool isLoading;

  const QuizState({this.quizzes = const [], this.isLoading = false});

  QuizState copyWith({List<Quiz>? quizzes, bool? isLoading}) {
    return QuizState(
      quizzes: quizzes ?? this.quizzes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QuizNotifier extends Notifier<QuizState> {
  final _db = FirebaseDatabase.instance.ref();
  String? _userId;
  @override
  QuizState build() {
    final userId = ref.watch(authProvider).userId;

    if (userId == null) {
      return const QuizState();
    }

    _userId = userId;
    _listenToQuizzes();
    return const QuizState();
  }

  void _listenToQuizzes() {
    if (_userId == null) return;
    _db.child('quizzes').onValue.listen((event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data == null) {
        state = state.copyWith(quizzes: []);
        return;
      }
      final List<Quiz> loadedQuizzes = [];
      data.forEach((key, value) {
        if (value is! Map<Object?, Object?>) return;
        try {
          final quizMap = Map<String, dynamic>.from(value);
          final quiz = Quiz.fromJson(quizMap);

          if (quiz.creatorId == _userId || quiz.status == 'approved') {
            loadedQuizzes.add(quiz);
          }
        } catch (e) {
          print('Lỗi khi phân tích quiz: $e');
        }
      });
      loadedQuizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(quizzes: loadedQuizzes);
    });
  }

  Future<void> createQuiz({
    required String title,
    required String description,
    required String subject,
    required String visibility,
    required int timeLimit,
    required int maxAttempt,
    required bool allowRetake, // Tham số từ UI
    required bool randomQuestions,
    required bool randomAnswers,
    required bool showAnswer,
    required List<Question> questions,
  }) async {
    final currentUserId = ref.read(authProvider).userId;
    if (currentUserId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final quizId = const Uuid().v4();
      String status = (visibility == 'public') ? 'pending_review' : 'approved';
      final newQuiz = Quiz(
        quizId: quizId,
        creatorId: currentUserId,
        classId: null,
        title: title,
        description: description,
        subject: subject,
        tags: [],
        visibility: visibility,
        status: status,
        timeLimit: timeLimit,
        maxAttempt: maxAttempt,
        randomQuestions: randomQuestions,
        randomAnswers: randomAnswers,
        showAnswer: showAnswer,
        createdAt: DateTime.now(),
        questions: questions,
      );

      await _db.child('quizzes').child(quizId).set(newQuiz.toJson());
      print('Đã tạo quiz thành công: $quizId');
    } catch (e) {
      print('Lỗi tạo quiz: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(() {
  return QuizNotifier();
});
