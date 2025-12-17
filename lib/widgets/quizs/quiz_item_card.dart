import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/quiz_attempt_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
import 'package:learningmanagement/screens/Quiz_screens/edit_quiz_screen.dart';

class QuizItemCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = attempt != null;
    final iconColor = isDone ? Colors.green : Colors.blue;
    final bgColor = isDone ? Colors.green[50] : Colors.blue[50];
    final currentUserId = ref.watch(authProvider).userId;
    final isOwner = currentUserId != null && quiz.creatorId == currentUserId;

    final isPublic = quiz.visibility.toLowerCase() == 'public';

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quiz.subject,
                          style: TextStyle(
                            color: _getSubjectColor(quiz.subject),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isOwner && !isPublic)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.visibility_off,
                                  size: 12,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Riêng tư',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isOwner)
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditQuizScreen(quiz: quiz),
                                  ),
                                );
                              } else if (value == 'toggle_visibility') {
                                _showHideDialog(context, ref, isPublic);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Sửa Quiz'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle_visibility',
                                child: Row(
                                  children: [
                                    Icon(
                                      isPublic
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 20,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(isPublic ? 'Ẩn Quiz' : 'Công khai'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green[100]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isDone
                                ? '${attempt!.score}đ'
                                : '${quiz.timeLimit}p',
                            style: TextStyle(
                              color: isDone
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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
                  if (isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isDone
                            ? 'Kết quả: ${attempt!.score}đ'
                            : '${quiz.timeLimit} phút',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone
                              ? Colors.green[800]
                              : Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Text(
                          isDone ? 'Xem kết quả' : 'Làm bài ngay',
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: iconColor,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHideDialog(BuildContext context, WidgetRef ref, bool isPublic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isPublic ? 'Chuyển sang riêng tư?' : 'Công khai bài này?'),
        content: Text(
          isPublic
              ? 'Người khác sẽ không nhìn thấy bài kiểm tra này nữa.'
              : 'Mọi người sẽ có thể nhìn thấy và làm bài kiểm tra này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (isPublic) {
                await ref.read(quizProvider.notifier).hideQuiz(quiz.quizId);
              } else {
                await ref
                    .read(quizProvider.notifier)
                    .toggleVisibility(quiz.quizId);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPublic ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isPublic ? 'Ẩn ngay' : 'Công khai'),
          ),
        ],
      ),
    );
  }
}
