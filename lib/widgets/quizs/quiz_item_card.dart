import 'package:flutter/material.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';

class QuizItemCard extends StatelessWidget {
  final Quiz quiz;
  final QuizAttempt? attempt;
  final VoidCallback onTap;

  const QuizItemCard({
    super.key,
    required this.quiz,
    this.attempt,
    required this.onTap,
  });

  Color _getSubjectColor(String subject) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.redAccent,
    ];
    return colors[subject.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDone = attempt != null;
    final iconColor = isDone ? Colors.green : Colors.blue;
    final bgColor = isDone ? Colors.green[50] : Colors.blue[50];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDone ? Icons.check_circle : Icons.school,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          quiz.subject,
                          style: TextStyle(
                            color: _getSubjectColor(quiz.subject),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDone ? Colors.green[100] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isDone ? '${attempt!.score}đ' : '${quiz.timeLimit}p',
                      style: TextStyle(
                        color: isDone ? Colors.green[800] : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.questions.length} câu hỏi',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    isDone ? 'Xem kết quả' : 'Làm bài ngay',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: iconColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
