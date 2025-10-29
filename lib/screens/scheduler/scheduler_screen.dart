import 'package:flutter/material.dart';

class SchedulerScreen extends StatelessWidget {
  const SchedulerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch học')),
      body: const Center(child: Text('Đây là màn hình Lịch học')),
    );
  }
}
