import 'package:flutter/material.dart';
import 'package:learningmanagement/models/question_model.dart';

class ManualGradingCard extends StatefulWidget {
  final int index;
  final Question question;
  final String studentAnswer;
  final double currentScore;
  final Function(String) onSaveScore;

  const ManualGradingCard({
    super.key,
    required this.index,
    required this.question,
    required this.studentAnswer,
    required this.currentScore,
    required this.onSaveScore,
  });
  @override
  State<ManualGradingCard> createState() => _ManualGradingCardState();
}

class _ManualGradingCardState extends State<ManualGradingCard> {
  late TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: widget.currentScore.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant ManualGradingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentScore != oldWidget.currentScore) {
      if (_scoreController.text != widget.currentScore.toString()) {
        _scoreController.text = widget.currentScore.toString();
      }
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu ${widget.index + 1} (Tự luận)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Max: ${widget.question.point}đ',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(widget.question.content, style: const TextStyle(fontSize: 15)),
            const Divider(height: 24),

            // Bài làm
            const Text(
              'Bài làm sinh viên:',
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Text(
                widget.studentAnswer.isEmpty
                    ? '(Bỏ trống)'
                    : widget.studentAnswer,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Ô nhập điểm
            Row(
              children: [
                const Text(
                  'Chấm điểm:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _scoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      suffixText: 'đ',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final score = double.tryParse(_scoreController.text) ?? 0;
                    if (score > widget.question.point) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Điểm quá lớn!')),
                      );
                      return;
                    }
                    // Gửi ra ngoài
                    widget.onSaveScore(_scoreController.text);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
