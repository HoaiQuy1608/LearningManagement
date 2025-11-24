import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
import 'package:learningmanagement/widgets/quizs/added_question_item.dart';
import 'package:learningmanagement/screens/Student_screens/Quiz_screens/add_question_screen.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final _questionCountController = TextEditingController(text: '0');
  final _maxAttemptController = TextEditingController(text: '3');

  String _selectedSubject = 'Lập trình';
  String _visibility = 'Public';
  bool _randomQuestions = false;
  bool _randomAnswers = false;
  bool _allowRetake = false;

  final List<Question> _questions = [];
  final List<String> _subjects = [
    'Lập trình',
    'Kinh tế',
    'Triết học',
    'Pháp luật',
    'Toán',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    _questionCountController.dispose();
    _maxAttemptController.dispose();
    super.dispose();
  }

  Future<void> _navigateToAddQuestion() async {
    final Question? newQuestion = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddQuestionScreen()),
    );
    if (newQuestion != null) {
      setState(() => _questions.add(newQuestion));
    }
  }

  Future<void> _handleSaveQuiz() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa có câu hỏi nào')));
      return;
    }
    int finalMaxAttempt = 1;
    if (_allowRetake) {
      final val = int.tryParse(_maxAttemptController.text);
      if (val == null || val < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Số lần làm lại phải lớn hơn 1')),
        );
        return;
      }
      finalMaxAttempt = val;
    }
    await ref
        .read(quizProvider.notifier)
        .createQuiz(
          title: _titleController.text.trim(),
          subject: _selectedSubject,
          description: '',
          visibility: 'Public',
          timeLimit: int.tryParse(_timeLimitController.text) ?? 0,
          questions: _questions,
          allowRetake: _allowRetake,
          randomQuestions: _randomQuestions,
          randomAnswers: _randomAnswers,
          showAnswer: true,
          maxAttempt: finalMaxAttempt,
        );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu Quiz!')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(quizProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo Quiz mới')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader('Thông tin chung'),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField(
                          initialValue: _selectedSubject,
                          decoration: const InputDecoration(
                            labelText: 'Môn học',
                            border: OutlineInputBorder(),
                          ),
                          items: _subjects
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() => _selectedSubject = v!);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _timeLimitController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Thời gian (phút)',
                            border: OutlineInputBorder(),
                            suffixText: 'phút',
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Nhập thời gian' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    initialValue: _visibility,
                    decoration: const InputDecoration(
                      labelText: 'Quyền truy cập',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.public),
                    ),
                    items: ['Public', 'Private', 'Class']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _visibility = v!),
                  ),

                  _buildHeader('Cấu hình Quiz'),
                  SwitchListTile(
                    title: const Text('Đảo câu hỏi'),
                    value: _randomQuestions,
                    onChanged: (v) => setState(() => _randomQuestions = v),
                  ),
                  SwitchListTile(
                    title: const Text('Đảo đáp án'),
                    value: _randomAnswers,
                    onChanged: (v) => setState(() => _randomAnswers = v),
                  ),
                  SwitchListTile(
                    title: const Text('Cho phép làm lại'),
                    subtitle: _allowRetake
                        ? const Text('Sinh viên được làm bài nhiều lần')
                        : const Text('Chỉ được làm 1 lần duy nhất'),
                    value: _allowRetake,
                    onChanged: (v) => setState(() => _allowRetake = v),
                  ),
                  if (_allowRetake)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextFormField(
                        controller: _maxAttemptController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Số lần tối đa',
                          hintText: 'VD: 3',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.repeat),
                          helperText: 'Nhập số lần làm bài',
                        ),
                        validator: (v) {
                          if (!_allowRetake) return null;
                          if (v == null || v.isEmpty)
                            return 'Vui lòng nhập số lần';
                          if (int.parse(v) < 2) return 'Phải lớn hơn 1';
                          return null;
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeader('Danh sách câu hỏi (${_questions.length})'),
                      TextButton.icon(
                        onPressed: _navigateToAddQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm'),
                      ),
                    ],
                  ),
                  if (_questions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Chưa có câu hỏi nào được thêm vào',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _questions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final q = _questions[index];
                        return AddedQuestionItem(
                          index: index,
                          question: q,
                          onDelete: () {
                            setState(() {
                              _questions.removeAt(index);
                              _questionCountController.text = _questions.length
                                  .toString();
                            });
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSaveQuiz,
                  child: const Text('Lưu Quiz'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
