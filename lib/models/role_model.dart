class Role {
  final int roleId;
  final String roleName;
  final String description;

  Role({required this.roleId, required this.roleName, required this.description});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['role_id'],
      roleName: json['role_name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'role_name': roleName,
      'description': description,
    };
  }
}
