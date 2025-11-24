import 'package:flutter/material.dart';
import 'package:learningmanagement/screens/authentication/profile_screen.dart';
import 'package:learningmanagement/screens/forum_screens/forum_screen.dart';
import 'package:learningmanagement/screens/Teacher_screens/class_list_screen.dart';

class TeacherNav extends StatefulWidget {
  const TeacherNav({super.key});

  @override
  State<TeacherNav> createState() => _TeacherNavState();
}

class _TeacherNavState extends State<TeacherNav> {
  int index = 0;

  final screens = [
    const ForumScreen(),
    const ClassListScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.class_), label: "Lớp học"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
