
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'deadline': deadline.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DeadlineCountdownModel.fromMap(Map<String, dynamic> map) {
    return DeadlineCountdownModel(
      id: map['id'] as String,
      scheduleId: map['scheduleId'] as String,
      deadline: DateTime.parse(map['deadline'] as String),
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }
}
