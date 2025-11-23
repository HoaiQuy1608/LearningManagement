import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/screens/Home_screens/moderator_screen.dart';
import 'package:learningmanagement/screens/Home_screens/student_screen.dart';
import 'package:learningmanagement/screens/Home_screens/teacher_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (user.userRole) {
      case "moderator":
        return const ModeratorNav();

      case "teacher":
        return const TeacherNav();

      case "student":
      default:
        return const StudentNav();
    }
  }
}
