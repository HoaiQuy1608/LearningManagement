import 'package:flutter/material.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diễn đàn học tập')),
      body: const Center(child: Text('Đây là màn hình Diễn đàn học tập')),
    );
  }
}
