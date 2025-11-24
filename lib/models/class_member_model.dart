class ClassMember {
  final String id;
  final String classId;
  final String userId;
  final String username;
  final String roleInClass; // student, ta
  final String status;
  final DateTime joinedAt;

  ClassMember({
    required this.id,
    required this.classId,
    required this.userId,
    required this.username,
    required this.roleInClass,
    required this.status,
    required this.joinedAt,
  });

  ClassMember copyWith({
    String? id,
    String? classId,
    String? userId,
    String? username,
    String? roleInClass,
    String? status,
    DateTime? joinedAt,
  }) {
    return ClassMember(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      roleInClass: roleInClass ?? this.roleInClass,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  factory ClassMember.fromJson(Map<String, dynamic> json) => ClassMember(
    id: json['id'] ?? '',
    classId: json['classId'] ?? '',
    userId: json['userId'] ?? '',
    username: json['username'] ?? 'Unknown',
    roleInClass: json['roleInClass'] ?? 'student',
    status: json['status'] ?? 'active',
    joinedAt: DateTime.parse(
      json['joinedAt'] ?? DateTime.now().toIso8601String(),
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'classId': classId,
    'userId': userId,
    'username': username,
    'roleInClass': roleInClass,
    'status': status,
    'joinedAt': joinedAt.toIso8601String(),
  };
}
