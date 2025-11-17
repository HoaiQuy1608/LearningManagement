import 'answer_model.dart';
class Question {
  final String questionId;
  final String quizId;
  final String type; // multiple_choice / multi_select / essay
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

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        questionId: json['questionId'],
        quizId: json['quizId'],
        type: json['type'],
        content: json['content'],
        mediaUrl: json['mediaUrl'],
        point: (json['point'] ?? 0).toDouble(),
        options: (json['options'] as List? ?? [])
            .map((e) => AnswerOption.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'quizId': quizId,
        'type': type,
        'content': content,
        'mediaUrl': mediaUrl,
        'point': point,
        'options': options.map((e) => e.toJson()).toList(),
      };
}