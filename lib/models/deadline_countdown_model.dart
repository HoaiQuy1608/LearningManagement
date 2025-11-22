class DeadlineCountdownModel {
  final String id;
  final String scheduleId;
  final DateTime deadline;
  final bool isCompleted;
  final DateTime? completedAt;

  DeadlineCountdownModel({
    required this.id,
    required this.scheduleId,
    required this.deadline,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DeadlineCountdownModel.fromJson(Map<String, dynamic> json) {
    return DeadlineCountdownModel(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
