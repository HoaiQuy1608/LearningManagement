import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

@immutable
class Quiz {
  final String title;
  final String subject;
  final int questionCount;
  final int timeLimitMinutes;

  const Quiz({
    required this.title,
    required this.subject,
    required this.questionCount,
    required this.timeLimitMinutes,
  });
}

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
  @override
  QuizState build() {
    return const QuizState(
      quizzes: [
        Quiz(
          title: 'De kiem tra 15 phut',
          subject: 'Kinh te chinh tri',
          questionCount: 20,
          timeLimitMinutes: 15,
        ),
        Quiz(
          title: 'De kiem tra giua ky',
          subject: 'Mon hoc moi',
          questionCount: 30,
          timeLimitMinutes: 10,
        ),
        Quiz(
          title: 'De kiem tra cuoi ky',
          subject: 'Mon hoc moi',
          questionCount: 40,
          timeLimitMinutes: 20,
        ),
      ],
    );
  }

  Future<void> createQuiz({
    required String title,
    required String subject,
    required int questionCount,
    required int timeLimitMinutes,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    final newQuiz = Quiz(
      title: title,
      subject: 'Mon hoc moi',
      questionCount: questionCount,
      timeLimitMinutes: 10,
    );

    state = state.copyWith(
      isLoading: false,
      quizzes: [newQuiz, ...state.quizzes],
    );
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(() {
  return QuizNotifier();
});
