import 'package:flutter/material.dart';
import 'package:learningmanagement/models/question_model.dart';

class OptionInputItem extends StatelessWidget {
  final String text;
  final bool isCorrect;
  final QuestionType type;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const OptionInputItem({
    super.key,
    required this.text,
    required this.isCorrect,
    required this.type,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isCorrect ? Colors.green[50] : null,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isCorrect ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        onTap: onToggle,
        leading: Checkbox(
          value: isCorrect,
          shape: type == QuestionType.multipleChoice
              ? const CircleBorder()
              : null,
          activeColor: Colors.green,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          text,
          style: TextStyle(
            fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
            color: isCorrect ? Colors.green[900] : Colors.black,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Xóa đáp án này',
        ),
      ),
    );
  }
}
