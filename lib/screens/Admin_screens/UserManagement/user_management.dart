import 'package:flutter/material.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'user_detail_panel.dart';

class UserManagementScreen extends StatefulWidget {
  final List<UserModel> users;
  final void Function(String uid) onToggleActive;
  final void Function(String uid) onResetPassword;
  final void Function(String uid) onDeleteUser;
  final void Function(String uid, UserRole newRole) onChangeRole;

  const UserManagementScreen({
    super.key,
    required this.users,
    required this.onToggleActive,
    required this.onResetPassword,
    required this.onDeleteUser,
    required this.onChangeRole,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final filteredUsers = widget.users.where((u) {
      final nameMatch = (u.displayName ?? "").toLowerCase().contains(_searchText.toLowerCase());
      final emailMatch = u.email.toLowerCase().contains(_searchText.toLowerCase());
      return nameMatch || emailMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quản lý người dùng",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A5AE0), Color(0xFF8A63D2)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Tìm kiếm theo tên hoặc email",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) => setState(() => _searchText = val.trim()),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredUsers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                        ? Text(
                            (user.displayName ?? "?")[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(user.displayName ?? "Chưa có tên"),
                  subtitle: Text(user.email),
                  trailing: Icon(
                    user.isActive ? Icons.check_circle : Icons.cancel,
                    color: user.isActive ? Colors.green : Colors.red,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: const Text("Chi tiết người dùng"),
                          ),
                          body: UserDetailPanel(
                            user: user,
                            onToggleActive: () => widget.onToggleActive(user.uid),
                            onResetPassword: () => widget.onResetPassword(user.uid),
                            onDeleteUser: () => widget.onDeleteUser(user.uid),
                            onChangeRole: (newRole) => widget.onChangeRole(user.uid, newRole),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}