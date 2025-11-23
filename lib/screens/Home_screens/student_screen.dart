import 'package:flutter/material.dart';
import 'package:learningmanagement/screens/authentication/profile_screen.dart';
import 'package:learningmanagement/screens/forum_screens/forum_screen.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/quiz_list_screen.dart';

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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Forum"),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
