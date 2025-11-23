import 'package:flutter/material.dart';
import 'package:learningmanagement/models/answer_model.dart';
import 'package:uuid/uuid.dart';
import 'package:learningmanagement/models/question_model.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

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
      final questionId = const Uuid().v4();
      finalOptions = _tempOptions
          .map(
            (o) => AnswerOption(
              answerId: const Uuid().v4(),
              questionId: questionId,
              answerText: o['text'],
              isCorrect: o['isCorrect'],
            ),
          )
          .toList();
    }
    final newQuestion = Question(
      questionId: const Uuid().v4(),
      quizId: '',
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
      appBar: AppBar(title: const Text('Thêm Câu Hỏi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<QuestionType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Loại',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: QuestionType.multipleChoice,
                        child: Text('Trắc nghiệm (1)'),
                      ),
                      DropdownMenuItem(
                        value: QuestionType.multiSelect,
                        child: Text('Trắc nghiệm (N)'),
                      ),
                      DropdownMenuItem(
                        value: QuestionType.essay,
                        child: Text('Tự luận'),
                      ),
                    ],
                    onChanged: (v) => setState(() {
                      _selectedType = v!;
                      for (var o in _tempOptions) o['isCorrect'] = false;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _scoreController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Điểm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nội dung câu hỏi',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            if (_selectedType != QuestionType.essay) ...[
              const Text(
                'Đáp án (Chọn câu đúng):',
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
                return Card(
                  color: opt['isCorrect'] ? Colors.green[50] : null,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: opt['isCorrect'],
                      shape: _selectedType == QuestionType.multipleChoice
                          ? const CircleBorder()
                          : null,
                      activeColor: Colors.green,
                      onChanged: (_) => _toggleCorrect(index),
                    ),
                    title: Text(opt['text']),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _removeOption(index),
                    ),
                    onTap: () => _toggleCorrect(index),
                  ),
                );
              }),
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Câu hỏi tự luận',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Xong'),
            ),
          ],
        ),
      ),
    );
  }
}
