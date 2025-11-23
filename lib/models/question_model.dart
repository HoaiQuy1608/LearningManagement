import 'answer_model.dart';

enum QuestionType { multipleChoice, multiSelect, essay }

class Question {
  final String questionId;
  final String quizId;
  final QuestionType type;
  final String content;
  final String? mediaUrl;
  final double point;
  final List<AnswerOption> options;

  Question({
    required this.questionId,
    required this.quizId,
    required this.type,
    required this.content,
    this.mediaUrl,
    required this.point,
    required this.options,
  });

  Question copyWith({
    String? questionId,
    String? quizId,
    QuestionType? type,
    String? content,
    String? mediaUrl,
    double? point,
    List<AnswerOption>? options,
  }) {
    return Question(
      questionId: questionId ?? this.questionId,
      quizId: quizId ?? this.quizId,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      point: point ?? this.point,
      options: options ?? this.options,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    questionId: json['questionId'] ?? '',
    quizId: json['quizId'] ?? '',
    type: QuestionType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => QuestionType.multipleChoice,
    ),
    content: json['content'] ?? '',
    mediaUrl: json['mediaUrl'],
    point: (json['point'] ?? 0).toDouble(),
    options: (json['options'] as List? ?? [])
        .map((e) => AnswerOption.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'quizId': quizId,
    'type': type.name,
    'content': content,
    'mediaUrl': mediaUrl,
    'point': point,
    'options': options.map((e) => e.toJson()).toList(),
  };
}
