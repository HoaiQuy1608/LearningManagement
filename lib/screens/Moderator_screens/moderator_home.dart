import 'package:flutter/material.dart';

class ModeratorHome extends StatelessWidget {
  const ModeratorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Trang chủ Kiểm duyệt viên',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
