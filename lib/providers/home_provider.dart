import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/screens/Student_screens/scheduler/add_event_screen.dart';
import 'package:learningmanagement/screens/Student_screens/documents/upload_document_screen.dart';
import 'package:learningmanagement/screens/Student_screens/quiz/create_quiz_screen.dart';
import 'package:learningmanagement/screens/Student_screens/forum/create_post_screen.dart';

@immutable
class HomeState {
  final int selectedIndex;
  final String appBarTitle;
  final IconData? actionIcon;

  const HomeState({
    required this.selectedIndex,
    required this.appBarTitle,
    this.actionIcon,
  });

  HomeState copyWith({
    int? selectedIndex,
    String? appBarTitle,
    IconData? fabIcon,
  }) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      appBarTitle: appBarTitle ?? this.appBarTitle,
      actionIcon: actionIcon,
    );
  }
}

class HomeProvider extends Notifier<HomeState> {
  final List<String> _appBarTitles = const [
    'Lịch học',
    'Tài liệu',
    'Quiz',
    'Diễn đàn',
    'Hồ sơ',
  ];
  final List<IconData?> _actionIcons = const [
    Icons.add, // Tab 0
    Icons.upload_file, // Tab 1
    Icons.add, // Tab 2
    Icons.edit, // Tab 3
    null, // Tab 4 (Không có nút)
  ];

  @override
  HomeState build() {
    return _getStateForIndex(0);
  }

  void onItemTapped(int index) {
    state = _getStateForIndex(index);
  }

  void onActionTapped(BuildContext context) {
    final index = state.selectedIndex;

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEventScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadDocumentScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        );
        break;
    }
  }

  HomeState _getStateForIndex(int index) {
    return HomeState(
      selectedIndex: index,
      appBarTitle: _appBarTitles[index],
      actionIcon: _actionIcons[index],
    );
  }
}

final homeProvider = NotifierProvider<HomeProvider, HomeState>(() {
  return HomeProvider();
});
