import 'package:flutter/material.dart';

class DocumentListScreen extends StatelessWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài liệu học tập')),
      body: const Center(child: Text('Đây là màn hình Tài liệu học tập')),
    );
  }
}
