import 'package:flutter/material.dart';
import 'package:learningmanagement/screens/authentication/profile_screen.dart';
import 'package:learningmanagement/screens/documents/document_list_screen.dart';
import 'package:learningmanagement/screens/forum_screens/forum_screen.dart';

class ModeratorNav extends StatefulWidget {
  const ModeratorNav({super.key});

  @override
  State<ModeratorNav> createState() => _ModeratorNavState();
}

class _ModeratorNavState extends State<ModeratorNav> {
  int index = 0;

  final screens = [
    const ForumScreen(),
    const DocumentListScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: "Quản lý"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
