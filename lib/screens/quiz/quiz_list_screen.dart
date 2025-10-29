import 'package:flutter/material.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Câu hỏi quiz')),
      body: const Center(child: Text('Đây là màn hình Câu hỏi quiz')),
    );
  }
}
