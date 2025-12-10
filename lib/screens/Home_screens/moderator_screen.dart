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
  int currentIndex = 0;

  final List<Widget> screens = [
    const ForumScreen(),                                   
    const DocumentListScreen(),             
    const ModeratorReportScreen(),                       
    const ProfileScreen(),                                 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 12,
        shadowColor: Colors.purple.withOpacity(0.15),
        indicatorColor: const Color(0xFF7C4DFF).withOpacity(0.25),
        selectedIndex: currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (int i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum_rounded),
            label: 'Diễn đàn',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded),
            label: 'Tài liệu',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: 'Báo cáo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}