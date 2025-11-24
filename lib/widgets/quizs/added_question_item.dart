import 'package:flutter/material.dart';
import 'package:learningmanagement/models/question_model.dart';

class AddedQuestionItem extends StatelessWidget {
  final int index;
  final Question question;
  final VoidCallback onDelete;

  const AddedQuestionItem({
    super.key,
    required this.index,
    required this.question,
    required this.onDelete,
  });

  String _getTypeName(QuestionType type) {
    if (type == QuestionType.multipleChoice) return 'Trắc nghiệm (1)';
    if (type == QuestionType.multiSelect) return 'Trắc nghiệm (N)';
    return 'Tự luận';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[50],
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          question.content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${_getTypeName(question.type)} • ${question.point} điểm',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
