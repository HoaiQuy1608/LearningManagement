class Schedule {
  final String scheduleId;
  final String userId;
  final String title;
  final String description;
  final String type; // lesson, quiz, assignment, deadline
  final DateTime startTime;
  final DateTime endTime;
  final int remindBefore; // phút
  final bool isCompleted;
  final DateTime createdAt;

  Schedule({
    required this.scheduleId,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.remindBefore,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        scheduleId: json['scheduleId'],
        userId: json['userId'],
        title: json['title'],
        description: json['description'],
        type: json['type'],
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        remindBefore: json['remindBefore'] ?? 0,
        isCompleted: json['isCompleted'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'scheduleId': scheduleId,
        'userId': userId,
        'title': title,
        'description': description,
        'type': type,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'remindBefore': remindBefore,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };
}
