import 'package:flutter/material.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/screens/Admin_screens/UserManagement/user_management.dart';
import 'admin_home.dart';

class AdminMainScreen extends StatefulWidget {
  final List<UserModel> users;

  const AdminMainScreen({super.key, required this.users});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  void _onToggleActive(String uid) {
    // logic ở provider
  }

  void _onResetPassword(String uid) {
    // logic ở provider
  }

  void _onDeleteUser(String uid) {
    // logic ở provider
  }

  void _onChangeRole(String uid, UserRole role) {
    // logic ở provider
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const AdminHome(),
      UserManagementScreen(
        users: widget.users,
        onToggleActive: _onToggleActive,
        onResetPassword: _onResetPassword,
        onDeleteUser: _onDeleteUser,
        onChangeRole: _onChangeRole,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Người dùng',
          ),
        ],
      ),
    );
  }
}
