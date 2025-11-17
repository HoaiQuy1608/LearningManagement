import 'essay_answer_model.dart';
class QuizAttempt {
  final String attemptId;
  final String quizId;
  final String userId;
  final double score;
  final DateTime startedAt;
  final DateTime submittedAt;
  final List<EssayAnswer> essayAnswers;

  QuizAttempt({
    required this.attemptId,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.startedAt,
    required this.submittedAt,
    required this.essayAnswers,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        attemptId: json['attemptId'],
        quizId: json['quizId'],
        userId: json['userId'],
        score: (json['score'] ?? 0).toDouble(),
        startedAt: DateTime.parse(json['startedAt']),
        submittedAt: DateTime.parse(json['submittedAt']),
        essayAnswers: (json['essayAnswers'] as List? ?? [])
            .map((e) => EssayAnswer.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'attemptId': attemptId,
        'quizId': quizId,
        'userId': userId,
        'score': score,
        'startedAt': startedAt.toIso8601String(),
        'submittedAt': submittedAt.toIso8601String(),
        'essayAnswers': essayAnswers.map((e) => e.toJson()).toList(),
      };
}


