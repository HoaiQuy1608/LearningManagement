class ClassModel {
  final String classId;
  final String teacherId; // FK → User
  final String className;
  final String subject;
  final String description;
  final String visibility; // e.g., 'public', 'private'
  final DateTime createdAt;

  ClassModel({
    required this.classId,
    required this.teacherId,
    required this.className,
    required this.subject,
    required this.visibility,
    required this.description,
    required this.createdAt,
  });

  ClassModel copyWith({
    String? classId,
    String? teacherId,
    String? className,
    String? subject,
    String? description,
    String? visibility,
    DateTime? createdAt,
  }) {
    return ClassModel(
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
    classId: json['classId'] ?? '',
    teacherId: json['teacherId'] ?? '',
    className: json['className'] ?? '',
    subject: json['subject'] ?? '',
    description: json['description'] ?? '',
    visibility: json['visibility'] ?? 'public',
    createdAt: DateTime.parse(
      json['createdAt'] ?? DateTime.now().toIso8601String(),
    ),
  );

  Map<String, dynamic> toJson() => {
    'classId': classId,
    'teacherId': teacherId,
    'className': className,
    'subject': subject,
    'description': description,
    'visibility': visibility,
    'createdAt': createdAt.toIso8601String(),
  };
}
