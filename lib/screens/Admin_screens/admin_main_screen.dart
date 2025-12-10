import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/providers/user_provider.dart';
import 'package:learningmanagement/screens/Admin_screens/UserManagement/user_management.dart';
import 'package:learningmanagement/screens/authentication/profile_screen.dart';
import 'package:learningmanagement/screens/forum_screens/forum_screen.dart';

class AdminMainScreen extends ConsumerStatefulWidget {
  const AdminMainScreen({super.key});

  @override
  ConsumerState<AdminMainScreen> createState() => _AdminMainScreenState();
}


class _AdminMainScreenState extends ConsumerState<AdminMainScreen> {
  int _currentIndex = 0;

  void _onToggleActive(String uid) {
   ref.read(userProvider.notifier).toggleActive(uid);
  }

  void _onResetPassword(String uid) {
    ref.read(userProvider.notifier).resetPassword(uid);
  }

  void _onDeleteUser(String uid) {
    ref.read(userProvider.notifier).deleteUser(uid);
  }

  void _onChangeRole(String uid, UserRole role) {
    ref.read(userProvider.notifier).changeRole(uid, role);
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userProvider);
    final pages = [
      const ForumScreen(),
      UserManagementScreen(
        users: users,
        onToggleActive: _onToggleActive,
        onResetPassword: _onResetPassword,
        onDeleteUser: _onDeleteUser,
        onChangeRole: _onChangeRole,
      ),
      const ProfileScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
