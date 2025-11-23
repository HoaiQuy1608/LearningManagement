import 'question_model.dart';

class Quiz {
  final String quizId;
  final String creatorId;
  final String? classId; // nullable
  final String title;
  final String description;
  final String subject;
  final List<String> tags;
  final String visibility; // private, class, public
  final String status; // draft, pending_review, approved, rejected
  final int timeLimit; // phút
  final int maxAttempt;
  final bool randomQuestions;
  final bool randomAnswers;
  final bool showAnswer;
  final DateTime createdAt;
  final List<Question> questions;

  Quiz({
    required this.quizId,
    required this.creatorId,
    this.classId,
    required this.title,
    required this.description,
    required this.subject,
    required this.tags,
    required this.visibility,
    required this.status,
    required this.timeLimit,
    required this.maxAttempt,
    required this.randomQuestions,
    required this.randomAnswers,
    required this.showAnswer,
    required this.createdAt,
    required this.questions,
  });

  Quiz copyWith({
    String? quizId,
    String? creatorId,
    String? classId,
    String? title,
    String? description,
    String? subject,
    List<String>? tags,
    String? visibility,
    String? status,
    int? timeLimit,
    int? maxAttempt,
    bool? randomQuestions,
    bool? randomAnswers,
    bool? showAnswer,
    DateTime? createdAt,
    List<Question>? questions,
  }) {
    return Quiz(
      quizId: quizId ?? this.quizId,
      creatorId: creatorId ?? this.creatorId,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      timeLimit: timeLimit ?? this.timeLimit,
      maxAttempt: maxAttempt ?? this.maxAttempt,
      randomQuestions: randomQuestions ?? this.randomQuestions,
      randomAnswers: randomAnswers ?? this.randomAnswers,
      showAnswer: showAnswer ?? this.showAnswer,
      createdAt: createdAt ?? this.createdAt,
      questions: questions ?? this.questions,
    );
  }

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
    quizId: json['quizId'] ?? '',
    creatorId: json['creatorId'] ?? '',
    classId: json['classId'],
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    subject: json['subject'] ?? '',
    tags: List<String>.from(json['tags'] ?? []),
    visibility: json['visibility'] ?? 'Public',
    status: json['status'] ?? 'pending',
    timeLimit: (json['timeLimit'] ?? 0) as int,
    maxAttempt: (json['maxAttempt'] ?? 1) as int,
    randomQuestions: json['randomQuestions'] ?? false,
    randomAnswers: json['randomAnswers'] ?? false,
    showAnswer: json['showAnswer'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    questions: (json['questions'] as List? ?? [])
        .map((e) => Question.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'quizId': quizId,
    'creatorId': creatorId,
    'classId': classId,
    'title': title,
    'description': description,
    'subject': subject,
    'tags': tags,
    'visibility': visibility,
    'status': status,
    'timeLimit': timeLimit,
    'maxAttempt': maxAttempt,
    'randomQuestions': randomQuestions,
    'randomAnswers': randomAnswers,
    'showAnswer': showAnswer,
    'createdAt': createdAt.toIso8601String(),
    'questions': questions.map((e) => e.toJson()).toList(),
  };
}
