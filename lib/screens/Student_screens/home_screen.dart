import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/home_provider.dart';
import 'package:learningmanagement/screens/Student_screens/scheduler/scheduler_screen.dart';
import 'package:learningmanagement/screens/authentication/profile_screen.dart';
import 'package:learningmanagement/screens/Student_screens/quiz/quiz_list_screen.dart';
import 'package:learningmanagement/screens/Student_screens/documents/document_list_screen.dart';
import 'package:learningmanagement/screens/Student_screens/forum/forum_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Widget> _widgetOptions = <Widget>[
    SchedulerScreen(),
    DocumentListScreen(),
    QuizListScreen(),
    ForumScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(homeState.appBarTitle),
        actions: [
          if (homeState.selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search
              },
            ),
          if (homeState.actionIcon != null)
            IconButton(
              icon: Icon(homeState.actionIcon),
              onPressed: () => notifier.onActionTapped(context),
              tooltip: _getActionTooltip(homeState.selectedIndex),
            ),
        ],
      ),
      body: IndexedStack(
        index: homeState.selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Tài liệu',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Diễn đàn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
        currentIndex: homeState.selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => notifier.onItemTapped(index),
      ),
    );
  }

  String _getActionTooltip(int index) {
    switch (index) {
      case 0:
        return 'Thêm sự kiện';
      case 1:
        return 'Tải tài liệu lên';
      case 2:
        return 'Tạo quiz mới';
      case 3:
        return 'Viết bài mới';
      default:
        return '';
    }
  }
}
