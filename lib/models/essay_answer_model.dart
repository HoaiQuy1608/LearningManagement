class EssayAnswer {
  final String essayId;
  final String attemptId;
  final String questionId;
  final String answerText;
  final double teacherScore;
  final String? teacherComment;

  EssayAnswer({
    required this.essayId,
    required this.attemptId,
    required this.questionId,
    required this.answerText,
    required this.teacherScore,
    this.teacherComment,
  });

  EssayAnswer copyWith({
    String? essayId,
    String? attemptId,
    String? questionId,
    String? answerText,
    double? teacherScore,
    String? teacherComment,
  }) {
    return EssayAnswer(
      essayId: essayId ?? this.essayId,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      answerText: answerText ?? this.answerText,
      teacherScore: teacherScore ?? this.teacherScore,
      teacherComment: teacherComment ?? this.teacherComment,
    );
  }

  factory EssayAnswer.fromJson(Map<String, dynamic> json) => EssayAnswer(
    essayId: json['essayId'] ?? '',
    attemptId: json['attemptId'] ?? '',
    questionId: json['questionId'] ?? '',
    answerText: json['answerText'] ?? '',
    teacherScore: (json['teacherScore'] ?? 0).toDouble(),
    teacherComment: json['teacherComment'],
  );

  Map<String, dynamic> toJson() => {
    'essayId': essayId,
    'attemptId': attemptId,
    'questionId': questionId,
    'answerText': answerText,
    'teacherScore': teacherScore,
    'teacherComment': teacherComment,
  };
}
