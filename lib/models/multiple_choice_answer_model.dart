class MultipleChoiceAnswer {
  final String answerId;
  final String attemptId;
  final String questionId;
  final List<String> selectedOptions;
  final double score;

  MultipleChoiceAnswer({
    required this.answerId,
    required this.attemptId,
    required this.questionId,
    required this.selectedOptions,
    required this.score,
  });

  MultipleChoiceAnswer copyWith({
    String? answerId,
    String? attemptId,
    String? questionId,
    List<String>? selectedOptions,
    double? score,
  }) {
    return MultipleChoiceAnswer(
      answerId: answerId ?? this.answerId,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      score: score ?? this.score,
    );
  }

  factory MultipleChoiceAnswer.fromJson(Map<String, dynamic> json) =>
      MultipleChoiceAnswer(
        answerId: json['answerId'] ?? '',
        attemptId: json['attemptId'] ?? '',
        questionId: json['questionId'] ?? '',
        selectedOptions: List<String>.from(json['selectedOptions'] ?? []),
        score: (json['score'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'answerId': answerId,
    'attemptId': attemptId,
    'questionId': questionId,
    'selectedOptions': selectedOptions,
    'score': score,
  };
}
