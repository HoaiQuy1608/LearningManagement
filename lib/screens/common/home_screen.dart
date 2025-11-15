import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/home_provider.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/screens/Student_screens/scheduler/scheduler_screen.dart';
import 'package:learningmanagement/screens/Student_screens/documents/document_list_screen.dart';
import 'package:learningmanagement/screens/Student_screens/quiz/quiz_list_screen.dart';
import 'package:learningmanagement/screens/common/forum/forum_screen.dart';
import 'package:learningmanagement/screens/authentication/profile_screen.dart';
import 'package:learningmanagement/screens/Teacher_screens/my_classes_screen.dart';
import 'package:learningmanagement/screens/Moderator_screens/moderator_home.dart';
import 'package:learningmanagement/screens/Admin_screens/admin_home.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final authState = ref.watch(authProvider);
    final role = authState.userRole ?? UserRole.sinhVien;
    final notifier = ref.read(homeProvider.notifier);
    final List<Widget> screens = _getScreensByRole(role);
    final List<BottomNavigationBarItem> navItems = _getNavItemsByRole(role);

    return Scaffold(
      appBar: AppBar(
        title: Text(homeState.appBarTitle),
        actions: [
          // Nút Search: chỉ ở tab Tài liệu (index == 1)
          if (homeState.selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          // Nút Action: có icon thì hiện
          if (homeState.actionIcon != null)
            IconButton(
              icon: Icon(homeState.actionIcon),
              onPressed: () => notifier.onActionTapped(context),
              tooltip: _getActionTooltip(homeState.selectedIndex, role),
            ),
        ],
      ),
      body: IndexedStack(index: homeState.selectedIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: homeState.selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => notifier.onItemTapped(index),
      ),
    );
  }

  // === LẤY DANH SÁCH MÀN HÌNH THEO ROLE ===
  List<Widget> _getScreensByRole(UserRole role) {
    final base = [
      const SchedulerScreen(),
      const DocumentListScreen(),
      const QuizListScreen(),
      const ForumScreen(),
      const ProfileScreen(),
    ];

    return switch (role) {
      UserRole.giangVien ||
      UserRole.troGiang => [...base, const MyClassesScreen()],
      UserRole.kiemDuyet => [...base, const ModeratorHome()],
      UserRole.admin => [...base, const AdminHome()],
      _ => base,
    };
  }

  // === LẤY DANH SÁCH TAB THEO ROLE ===
  List<BottomNavigationBarItem> _getNavItemsByRole(UserRole role) {
    final base = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today),
        label: 'Lịch học',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.document_scanner),
        label: 'Tài liệu',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
      const BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Diễn đàn'),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
    ];

    return switch (role) {
      UserRole.giangVien || UserRole.troGiang => [
        ...base,
        const BottomNavigationBarItem(icon: Icon(Icons.class_), label: 'Lớp'),
      ],
      UserRole.kiemDuyet => [
        ...base,
        const BottomNavigationBarItem(
          icon: Icon(Icons.shield),
          label: 'Kiểm duyệt',
        ),
      ],
      UserRole.admin => [
        ...base,
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Quản trị',
        ),
      ],
      _ => base,
    };
  }

  // === TOOLTIP CHO NÚT ACTION ===
  String _getActionTooltip(int index, UserRole role) {
    // Tab riêng (index >= 5)
    if (index >= 5) {
      return switch (role) {
        UserRole.giangVien || UserRole.troGiang => 'Tạo lớp học mới',
        UserRole.kiemDuyet => 'Mở kiểm duyệt',
        UserRole.admin => 'Mở quản trị',
        _ => '',
      };
    }

    // Tab chung (index 0-4)
    return switch (index) {
      0 => 'Thêm sự kiện',
      1 => 'Tải tài liệu lên',
      2 => 'Tạo quiz mới',
      3 => 'Viết bài mới',
      _ => '',
    };
  }
}
