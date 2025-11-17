class ClassModel {
  final String classId;
  final String teacherId; // FK → User
  final String className;
  final String description;
  final DateTime createdAt;

  ClassModel({
    required this.classId,
    required this.teacherId,
    required this.className,
    required this.description,
    required this.createdAt,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
        classId: json['classId'],
        teacherId: json['teacherId'],
        className: json['className'],
        description: json['description'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'classId': classId,
        'teacherId': teacherId,
        'className': className,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };
}
