class AnswerOption {
  final String answerId;
  final String questionId;
  final String answerText;
  final bool isCorrect;

  AnswerOption({
    required this.answerId,
    required this.questionId,
    required this.answerText,
    required this.isCorrect,
  });

  AnswerOption copyWith({
    String? answerId,
    String? questionId,
    String? answerText,
    bool? isCorrect,
  }) {
    return AnswerOption(
      answerId: answerId ?? this.answerId,
      questionId: questionId ?? this.questionId,
      answerText: answerText ?? this.answerText,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  factory AnswerOption.fromJson(Map<String, dynamic> json) => AnswerOption(
    answerId: json['answerId'] ?? '',
    questionId: json['questionId'] ?? '',
    answerText: json['answerText'] ?? '',
    isCorrect: json['isCorrect'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'answerId': answerId,
    'questionId': questionId,
    'answerText': answerText,
    'isCorrect': isCorrect,
  };
}
