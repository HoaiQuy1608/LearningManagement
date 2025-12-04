import 'package:flutter/material.dart';
import 'package:learningmanagement/screens/authentication/profile_screen.dart';
import 'package:learningmanagement/screens/documents/document_list_screen.dart';
import 'package:learningmanagement/screens/forum_screens/forum_screen.dart';
import 'package:learningmanagement/screens/report/moderator_report_screen.dart';

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
    const ModeratorReportScreen(),
    const ProfileScreen(),
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
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.document_scanner),
            label: "Document",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.report),
            label: "Report",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
