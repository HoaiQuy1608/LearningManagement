class ScheduleModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final String? location;
  // mau hien thi tren lich
  final String color;
  final String type;
  final String? reminder;

  ScheduleModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    this.location,
    required this.color,
    required this.type,
    this.reminder,
  });

  ScheduleModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? color,
    String? type,
    String? reminder,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      color: color ?? this.color,
      type: type ?? this.type,
      reminder: reminder ?? this.reminder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
      'color': color,
      'type': type,
      'reminder': reminder,
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
      location: map['location'] as String?,
      color: map['color'] as String,
      type: map['type'] as String,
      reminder: map['reminder'] as String?,
    );
  }
}
