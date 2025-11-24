import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/screens/Home_screens/student_screen.dart';
import 'package:learningmanagement/screens/Home_screens/teacher_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading || authState.userRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    switch (authState.userRole!) {
      case UserRole.giangVien:
        return const TeacherNav();

      case UserRole.kiemDuyet:
        return const Scaffold(
          body: Center(child: Text("Màn hình Kiểm duyệt (Đang phát triển)")),
        );

      case UserRole.admin:
        return const Scaffold(
          body: Center(child: Text("Màn hình Admin (Đang phát triển)")),
        );

      case UserRole.troGiang:
        return const TeacherNav();

      case UserRole.sinhVien:
      default:
        return const StudentNav();
    }
  }
}
