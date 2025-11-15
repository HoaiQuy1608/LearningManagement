import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/screens/Student_screens/scheduler/add_event_screen.dart';
import 'package:learningmanagement/screens/Student_screens/documents/upload_document_screen.dart';
import 'package:learningmanagement/screens/Student_screens/quiz/create_quiz_screen.dart';
import 'package:learningmanagement/screens/common/forum/create_post_screen.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

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
    IconData? actionIcon,
  }) {
    return HomeState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      appBarTitle: appBarTitle ?? this.appBarTitle,
      actionIcon: actionIcon ?? this.actionIcon,
    );
  }
}

class HomeProvider extends Notifier<HomeState> {
  @override
  HomeState build() {
    final role = ref.watch(authProvider).userRole ?? UserRole.sinhVien;
    return _getStateForIndex(0, role);
  }

  void onItemTapped(int index) {
    final role = ref.watch(authProvider).userRole ?? UserRole.sinhVien;
    state = _getStateForIndex(index, role);
  }

  void onActionTapped(BuildContext context) {
    final index = state.selectedIndex;
    final role = ref.watch(authProvider).userRole ?? UserRole.sinhVien;

    // Xử lý 5 tab chung
    if (index < 5) {
      _handleCommonAction(index, context);
      return;
    }
    // Xử lý tab riêng theo role
    switch (role) {
      case UserRole.giangVien:
      case UserRole.troGiang:
        if (index == 5) {
          // TODO: Điều hướng đến màn hình "Tạo lớp"
          print('Tạo lớp học mới');
        }
        break;
      case UserRole.kiemDuyet:
        if (index == 5) {
          // TODO: Mở dashboard kiểm duyệt
          print('Mở kiểm duyệt');
        }
        break;
      case UserRole.admin:
        if (index == 5) {
          // TODO: Mở admin panel
          print('Mở quản trị');
        }
        break;
      default:
        break;
    }
  }

  void _handleCommonAction(int index, BuildContext context) {
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

  HomeState _getStateForIndex(int index, UserRole role) {
    final titles = _getTitle(role);
    final actions = _getActionIcon(role);
    return HomeState(
      selectedIndex: index,
      appBarTitle: titles[index],
      actionIcon: actions[index],
    );
  }

  List<String> _getTitle(UserRole role) {
    final base = ['Lịch học', 'Tài liệu', 'Quiz', 'Diễn đàn', 'Hồ sơ'];
    switch (role) {
      case UserRole.giangVien:
      case UserRole.troGiang:
        return [...base, 'Lớp của tôi'];
      case UserRole.kiemDuyet:
        return [...base, 'Kiểm duyệt'];
      case UserRole.admin:
        return [...base, 'Quản trị'];
      default:
        return base;
    }
  }

  List<IconData?> _getActionIcon(UserRole role) {
    final base = [
      Icons.add, // Lịch
      Icons.upload_file, // Tài liệu
      Icons.add, // Quiz
      Icons.edit, // Diễn đàn
      null, // Hồ sơ
    ];

    // Thêm icon cho tab mới (nếu có)
    if (role == UserRole.giangVien || role == UserRole.troGiang) {
      return [...base, Icons.add_business];
    } else if (role == UserRole.kiemDuyet) {
      return [...base, Icons.shield];
    } else if (role == UserRole.admin) {
      return [...base, Icons.admin_panel_settings];
    }

    return base;
  }
}

final homeProvider = NotifierProvider<HomeProvider, HomeState>(() {
  return HomeProvider();
});
