class ClassMember {
  final String id;
  final String classId;
  final String userId;
  final String roleInClass; // student, ta
  final DateTime joinedAt;

  ClassMember({
    required this.id,
    required this.classId,
    required this.userId,
    required this.roleInClass,
    required this.joinedAt,
  });

  factory ClassMember.fromJson(Map<String, dynamic> json) => ClassMember(
        id: json['id'],
        classId: json['classId'],
        userId: json['userId'],
        roleInClass: json['roleInClass'],
        joinedAt: DateTime.parse(json['joinedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'classId': classId,
        'userId': userId,
        'roleInClass': roleInClass,
        'joinedAt': joinedAt.toIso8601String(),
      };
}
