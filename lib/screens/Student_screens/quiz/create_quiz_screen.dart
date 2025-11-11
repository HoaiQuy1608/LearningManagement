import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart'; // 1. Import để dùng "lọc số"

// 2. Import "Bộ não"
import 'package:learningmanagement/providers/quiz_provider.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionCountController = TextEditingController();
  final _timeLimitController = TextEditingController();

  final List<String> _subjects = [
    'Kinh tế chính trị',
    'Triết học',
    'Pháp luật',
    'Flutter',
  ];
  String? _selectedSubject;

  @override
  void dispose() {
    _titleController.dispose();
    _questionCountController.dispose();
    _timeLimitController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(quizProvider.notifier)
        .createQuiz(
          title: _titleController.text.trim(),
          subject: _selectedSubject!,
          questionCount: int.tryParse(_questionCountController.text) ?? 0,
          timeLimitMinutes: int.tryParse(_timeLimitController.text) ?? 0,
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      quizProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Quiz mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề Quiz',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập tiêu đề'
                    : null,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                hint: const Text('Chọn môn học'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: _subjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSubject = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Vui lòng chọn môn học' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _questionCountController,
                decoration: const InputDecoration(
                  labelText: 'Số lượng câu hỏi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.question_answer_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập số câu'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _timeLimitController,
                decoration: const InputDecoration(
                  labelText: 'Thời gian làm bài (phút)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập thời gian'
                    : null,
              ),
              const SizedBox(height: 16.0),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Thêm câu hỏi (Trắc nghiệm/Tự luận)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  print('TODO: Mở màn hình "Thêm câu hỏi"');
                },
              ),
              const SizedBox(height: 24.0),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _handleSaveQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu Quiz'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
