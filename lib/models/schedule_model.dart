enum ScheduleType { lesson, exam, assignment, deadline }

class ScheduleModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String color;
  final ScheduleType type;
  final String? reminder;
  final DateTime? deadline;
  final bool isCompleted;

  ScheduleModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.color,
    required this.type,
    this.reminder,
    this.deadline,
    this.isCompleted = false,
  });

  ScheduleModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? color,
    ScheduleType? type,
    String? reminder,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      type: type ?? this.type,
      reminder: reminder ?? this.reminder,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'color': color,
      'type': type.name,
      'reminder': reminder,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final endTimeStr = json['endTime'] as String?;
    return ScheduleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: endTimeStr != null ? DateTime.parse(endTimeStr) : null,
      color: json['color'] as String,
      type: ScheduleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ScheduleType.lesson,
      ),
      reminder: json['reminder'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
