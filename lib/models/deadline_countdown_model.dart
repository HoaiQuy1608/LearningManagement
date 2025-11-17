class DeadlineCountdown {
  final String countdownId;
  final String userId;
  final String title;
  final DateTime deadline;
  final bool isDone;

  DeadlineCountdown({
    required this.countdownId,
    required this.userId,
    required this.title,
    required this.deadline,
    this.isDone = false,
  });

  factory DeadlineCountdown.fromJson(Map<String, dynamic> json) =>
      DeadlineCountdown(
        countdownId: json['countdownId'],
        userId: json['userId'],
        title: json['title'],
        deadline: DateTime.parse(json['deadline']),
        isDone: json['isDone'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'countdownId': countdownId,
        'userId': userId,
        'title': title,
        'deadline': deadline.toIso8601String(),
        'isDone': isDone,
      };
}
