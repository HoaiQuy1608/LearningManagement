import 'package:flutter/material.dart';
import 'package:learningmanagement/screens/forum_screens/forum_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForumScreen()),
          );
        },
        child: const Text("Đi đến Forum"),
      ),
    );
  }
}
