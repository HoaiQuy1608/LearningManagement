import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
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

  String _selectedSubject = 'Lập trình';
  String _visibility = 'Public';
  bool _randomQuestions = false;
  final bool _randomAnswers = false;
  bool _allowRetake = true;

  final List<Question> _questions = [];
  final List<String> _subjects = [
    'Lập trình',
    'Kinh tế',
    'Triết học',
    'Pháp luật',
    'Toán',
  ];

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
          maxAttempt: 1,
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
                            labelText: 'Mon hoc',
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
                    title: const Text('Cho phép làm lại'),
                    value: _allowRetake,
                    onChanged: (v) => setState(() => _allowRetake = v),
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
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(
                              q.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${_getQuestionTypeVi(q.type.name)} • ${q.point}đ',
                            ),
                            trailing: IconButton(
                              onPressed: () =>
                                  setState(() => _questions.removeAt(index)),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ),
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

  String _getQuestionTypeVi(String type) {
    if (type == 'multipleChoice') return 'Trắc nghiệm (1)';
    if (type == 'multiSelect') return 'Trắc nghiệm (N)';
    if (type == 'essay') return 'Tự luận';
    return type;
  }
}
