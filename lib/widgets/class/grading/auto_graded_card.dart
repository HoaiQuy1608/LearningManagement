import 'package:flutter/material.dart';
import 'package:learningmanagement/models/question_model.dart';

class AutoGradedCard extends StatelessWidget {
  final int index;
  final Question question;

  const AutoGradedCard({
    super.key,
    required this.index,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.computer, color: Colors.grey),
        title: Text(
          'Câu ${index + 1} (Trắc nghiệm)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            const Text(
              'Máy đã tự chấm điểm.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.green,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${question.point}đ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
