import 'package:flutter/material.dart';
import 'package:learningmanagement/models/class_model.dart';
import 'dart:math';

class ClassItemCard extends StatelessWidget {
  final ClassModel classModel;
  final VoidCallback onTap;

  const ClassItemCard({
    super.key,
    required this.classModel,
    required this.onTap,
  });

  LinearGradient _getGradient(String id) {
    final random = Random(id.hashCode);
    final colors = [
      [Colors.blue.shade400, Colors.blue.shade800],
      [Colors.orange.shade400, Colors.deepOrange.shade800],
      [Colors.teal.shade400, Colors.teal.shade800],
      [Colors.purple.shade400, Colors.deepPurple.shade800],
      [Colors.red.shade400, Colors.red.shade800],
      [Colors.indigo.shade400, Colors.indigo.shade800],
    ];
    final choice = colors[random.nextInt(colors.length)];
    return LinearGradient(
      colors: choice,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // Cắt góc ảnh nền
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. PHẦN HEADER MÀU SẮC (Tên lớp, Môn học)
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: _getGradient(classModel.classId),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          classModel.className,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge Public/Private
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              classModel.visibility == 'Private'
                                  ? Icons.lock
                                  : Icons.public,
                              color: Colors.white70,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              classModel.visibility,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    classModel.subject,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 2. PHẦN BODY (Mô tả ngắn)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (classModel.description.isNotEmpty) ...[
                    Text(
                      classModel.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Dòng thông tin phụ
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '0 học viên',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ), // Placeholder
                      const Spacer(),
                      Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
