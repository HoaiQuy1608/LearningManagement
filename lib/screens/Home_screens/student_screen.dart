import 'package:flutter/material.dart';
import 'package:learningmanagement/screens/authentication/profile_screen.dart';
import 'package:learningmanagement/screens/documents/upload_document_screen.dart';
import 'package:learningmanagement/screens/forum_screens/forum_screen.dart';
import 'package:learningmanagement/screens/Quiz_screens/quiz_list_screen.dart';

class StudentNav extends StatefulWidget {
  const StudentNav({super.key});

  @override
  State<StudentNav> createState() => _StudentNavState();
}

class _StudentNavState extends State<StudentNav> {
  int index = 0;

  final screens = [
    const ForumScreen(),
    const QuizListScreen(),
    const ProfileScreen(),
    const UploadDocumentScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: "Forum",
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: "Quiz",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.document_scanner),
            label: "Document",
          ),
        ],
      ),
    );
  }
}
