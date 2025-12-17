import 'package:flutter/material.dart';
import 'package:learningmanagement/models/answer_model.dart';
import 'package:uuid/uuid.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/widgets/quizs/option_input_item.dart';

class AddQuestionScreen extends StatefulWidget {
  final Question? questionToEdit;
  const AddQuestionScreen({super.key, this.questionToEdit});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _contentController = TextEditingController();
  final _optionController = TextEditingController();
  final _scoreController = TextEditingController(text: '1');
  QuestionType _selectedType = QuestionType.multipleChoice;
  final List<Map<String, dynamic>> _tempOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.questionToEdit != null) {
      final q = widget.questionToEdit!;
      _contentController.text = q.content;
      _scoreController.text = q.point.toString();
      _selectedType = q.type;
      for (var opt in q.options) {
        _tempOptions.add({
          'text': opt.answerText,
          'isCorrect': opt.isCorrect,
          'id': opt.answerId,
        });
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _optionController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _addOption() {
    if (_optionController.text.trim().isEmpty) return;
    setState(() {
      _tempOptions.add({
        'text': _optionController.text.trim(),
        'isCorrect': false,
        'id': const Uuid().v4(),
      });
      _optionController.clear();
    });
  }

  void _removeOption(int index) {
    setState(() {
      _tempOptions.removeAt(index);
    });
  }

  void _toggleCorrect(int index) {
    setState(() {
      if (_selectedType == QuestionType.multipleChoice) {
        for (var i = 0; i < _tempOptions.length; i++) {
          _tempOptions[i]['isCorrect'] = (i == index);
        }
      } else {
        _tempOptions[index]['isCorrect'] = !_tempOptions[index]['isCorrect'];
      }
    });
  }

  void _handleSave() {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nội dung câu hỏi không được để trống')),
      );
      return;
    }

    List<AnswerOption> finalOptions = [];
    if (_selectedType != QuestionType.essay) {
      if (_tempOptions.length < 2) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cần ít nhất 2 đáp án')));
        return;
      }
      if (!_tempOptions.any((o) => o['isCorrect'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chọn ít nhất 1 đáp án đúng')),
        );
        return;
      }
      final questionId = widget.questionToEdit?.questionId ?? const Uuid().v4();
      finalOptions = _tempOptions
          .map(
            (o) => AnswerOption(
              answerId: o['id'] ?? const Uuid().v4(),
              questionId: questionId,
              answerText: o['text'],
              isCorrect: o['isCorrect'],
            ),
          )
          .toList();
    }
    final newQuestion = Question(
      questionId: widget.questionToEdit?.questionId ?? const Uuid().v4(),
      quizId: widget.questionToEdit?.quizId ?? '',
      type: _selectedType,
      content: _contentController.text.trim(),
      point: double.tryParse(_scoreController.text) ?? 1.0,
      options: finalOptions,
      mediaUrl: null,
    );
    Navigator.pop(context, newQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.questionToEdit != null ? 'Sửa Câu Hỏi' : 'Thêm Câu Hỏi',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SỬA LỖI OVERFLOW: XẾP DỌC THAY VÌ NGANG ---
            DropdownButtonFormField<QuestionType>(
              initialValue: _selectedType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Loại câu hỏi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: QuestionType.multipleChoice,
                  child: Text('Trắc nghiệm (1 đáp án)'),
                ),
                DropdownMenuItem(
                  value: QuestionType.multiSelect,
                  child: Text('Trắc nghiệm (Nhiều đáp án)'),
                ),
                DropdownMenuItem(
                  value: QuestionType.essay,
                  child: Text('Tự luận'),
                ),
              ],
              onChanged: (v) => setState(() {
                _selectedType = v!;
                for (var o in _tempOptions) {
                  o['isCorrect'] = false;
                }
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _scoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Điểm',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nội dung câu hỏi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            if (_selectedType != QuestionType.essay) ...[
              const Text(
                'Đáp án (Tích chọn câu đúng):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _optionController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập đáp án...',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addOption(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addOption,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._tempOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final opt = entry.value;
                return OptionInputItem(
                  text: opt['text'],
                  isCorrect: opt['isCorrect'],
                  type: _selectedType,
                  onToggle: () => _toggleCorrect(index),
                  onDelete: () => _removeOption(index),
                );
              }),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Text(
                  'Đây là câu hỏi tự luận. Sinh viên sẽ nhập câu trả lời bằng văn bản.',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF6A5AE0),
                foregroundColor: Colors.white,
              ),
              child: const Text('Lưu câu hỏi', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
