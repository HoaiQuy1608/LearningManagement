import 'package:learningmanagement/providers/auth_provider.dart';

class UserModel {
  final String uid;
  final String email;
  final UserRole role;
  // Thông tin cá nhân
  final String? displayName;
  final String? avatarUrl;
  final String? phoneNumber;
  // Trạng thái tài khoản
  final bool isActive;
  final bool isEmailVerified;
  // Thời gian
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  // Dành riêng theo vai trò
  final String? studentId; // Dành cho sinh viên
  final String? department; // Dành cho giảng viên, trợ giảng
  // Dành cho thông báo đẩy
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.avatarUrl,
    this.phoneNumber,
    this.isActive = true,
    this.isEmailVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.studentId,
    this.department,
    this.fcmToken,
  });

  factory UserModel.fromMap(String uid, Map<Object?, Object?> map) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      role: _stringToRole(map['role'] as String? ?? 'sinhVien'),
      displayName: map['displayName'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      isActive: (map['isActive'] as bool?) ?? true,
      isEmailVerified: (map['isEmailVerified'] as bool?) ?? false,
      createdAt: DateTime.parse(
        map['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      studentId: map['studentId'] as String?,
      department: map['department'] as String?,
      fcmToken: map['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': _roleToString(role),
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt.toIso8601String(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt?.toIso8601String(),
      if (studentId != null) 'studentId': studentId,
      if (department != null) 'department': department,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    UserRole? role,
    String? displayName,
    String? avatarUrl,
    String? phoneNumber,
    bool? isActive,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? studentId,
    String? department,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, role: $role, name: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

UserRole _stringToRole(String role) {
  return UserRole.values.firstWhere(
    (e) => e.name == role,
    orElse: () => UserRole.sinhVien,
  );
}

String _roleToString(UserRole role) => role.name;
