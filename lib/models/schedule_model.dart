
enum ScheduleType { lesson, exam, assignment, deadline }

class ScheduleModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  // mau hien thi tren lich
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

  Map<String, dynamic> toMap() {
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

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    final endTimeStr = map['endTime'] as String?;
    return ScheduleModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: endTimeStr != null ? DateTime.parse(endTimeStr) : null,
      color: map['color'] as String,
      type: ScheduleType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ScheduleType.lesson,
      ),
      reminder: map['reminder'] as String?,
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'] as String)
          : null,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}
