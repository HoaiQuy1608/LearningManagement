import 'essay_answer_model.dart';
import 'multiple_choice_answer_model.dart';

class QuizAttempt {
  final String attemptId;
  final String quizId;
  final String userId;
  final double score;
  final DateTime startedAt;
  final DateTime submittedAt;
  final List<EssayAnswer> essayAnswers;
  final List<MultipleChoiceAnswer> multipleChoiceAnswers;
  final int currentQuestionIndex;
  final int timeLeft;
  final bool isSubmitting;

  QuizAttempt({
    required this.attemptId,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.startedAt,
    required this.submittedAt,
    required this.essayAnswers,
    required this.multipleChoiceAnswers,
    this.currentQuestionIndex = 0,
    this.timeLeft = 0,
    this.isSubmitting = false,
  });

  QuizAttempt copyWith({
    String? attemptId,
    String? quizId,
    String? userId,
    double? score,
    DateTime? startedAt,
    DateTime? submittedAt,
    List<EssayAnswer>? essayAnswers,
    List<MultipleChoiceAnswer>? multipleChoiceAnswers,
    int? currentQuestionIndex,
    int? timeLeft,
    bool? isSubmitting,
  }) {
    return QuizAttempt(
      attemptId: attemptId ?? this.attemptId,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      essayAnswers: essayAnswers ?? this.essayAnswers,
      multipleChoiceAnswers:
          multipleChoiceAnswers ?? this.multipleChoiceAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      timeLeft: timeLeft ?? this.timeLeft,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
    attemptId: json['attemptId'] ?? '',
    quizId: json['quizId'] ?? '',
    userId: json['userId'] ?? '',
    score: (json['score'] ?? 0).toDouble(),
    startedAt: DateTime.parse(json['startedAt']),
    submittedAt: DateTime.parse(json['submittedAt']),
    essayAnswers: (json['essayAnswers'] as List? ?? [])
        .map((e) => EssayAnswer.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    multipleChoiceAnswers: (json['multipleChoiceAnswers'] as List? ?? [])
        .map((e) => MultipleChoiceAnswer.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    currentQuestionIndex: 0,
    timeLeft: 0,
    isSubmitting: false,
  );

  Map<String, dynamic> toJson() => {
    'attemptId': attemptId,
    'quizId': quizId,
    'userId': userId,
    'score': score,
    'startedAt': startedAt.toIso8601String(),
    'submittedAt': submittedAt.toIso8601String(),
    'essayAnswers': essayAnswers.map((e) => e.toJson()).toList(),
    'multipleChoiceAnswers': multipleChoiceAnswers
        .map((e) => e.toJson())
        .toList(),
  };
}
