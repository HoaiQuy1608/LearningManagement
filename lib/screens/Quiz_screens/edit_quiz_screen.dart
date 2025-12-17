import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/providers/quiz_provider.dart';
import 'package:learningmanagement/widgets/quizs/added_question_item.dart';
import 'package:learningmanagement/screens/Quiz_screens/add_question_screen.dart';

class EditQuizScreen extends ConsumerStatefulWidget {
  final Quiz quiz;
  const EditQuizScreen({super.key, required this.quiz});

  @override
  ConsumerState<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends ConsumerState<EditQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  late TextEditingController _questionCountController;
  late TextEditingController _maxAttemptController;

  late String _selectedSubject;
  late String _visibility;
  late bool _randomQuestions;
  late bool _randomAnswers;
  late bool _allowRetake;
  late List<Question> _questions;

  final List<String> _subjects = [
    'Lập trình',
    'Kinh tế',
    'Triết học',
    'Pháp luật',
    'Toán',
  ];

  final List<String> _visibilityOptions = ['Public', 'Private', 'Class'];

  @override
  void initState() {
    super.initState();
    final q = widget.quiz;

    _titleController = TextEditingController(text: q.title);
    _timeLimitController = TextEditingController(text: q.timeLimit.toString());
    _questionCountController = TextEditingController(
      text: q.questions.length.toString(),
    );
    _maxAttemptController = TextEditingController(
      text: q.maxAttempt.toString(),
    );

    if (_subjects.contains(q.subject)) {
      _selectedSubject = q.subject;
    } else {
      _selectedSubject = _subjects.first;
    }

    String normalizedVis = q.visibility;
    if (normalizedVis.isNotEmpty) {
      normalizedVis =
          normalizedVis[0].toUpperCase() +
          normalizedVis.substring(1).toLowerCase();
    }
    if (_visibilityOptions.contains(normalizedVis)) {
      _visibility = normalizedVis;
    } else if (_visibilityOptions.contains(q.visibility)) {
      _visibility = q.visibility;
    } else {
      _visibility = 'Public';
    }
    _randomQuestions = q.randomQuestions;
    _randomAnswers = q.randomAnswers;
    _allowRetake = q.maxAttempt > 1;
    _questions = List.from(q.questions);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    _questionCountController.dispose();
    _maxAttemptController.dispose();
    super.dispose();
  }

  Future<void> _navigateToQuestionEditor({
    Question? questionToEdit,
    int? index,
  }) async {
    final Question? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddQuestionScreen(questionToEdit: questionToEdit),
      ),
    );

    if (result != null) {
      setState(() {
        if (questionToEdit != null && index != null) {
          _questions[index] = result;
        } else {
          _questions.add(result);
        }
        _questionCountController.text = _questions.length.toString();
      });
    }
  }

  Future<void> _handleUpdateQuiz() async {
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

    final error = await ref
        .read(quizProvider.notifier)
        .updateQuiz(
          quizId: widget.quiz.quizId,
          title: _titleController.text.trim(),
          subject: _selectedSubject,
          description: widget.quiz.description,
          visibility: _visibility,
          timeLimit: int.tryParse(_timeLimitController.text) ?? 0,
          questions: _questions,
          randomQuestions: _randomQuestions,
          randomAnswers: _randomAnswers,
          showAnswer: true,
          maxAttempt: finalMaxAttempt,
        );

    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã cập nhật Quiz!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(quizProvider).isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa Quiz",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A5AE0), Color(0xFF8A63D2)],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin chung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Môn học',
                      border: OutlineInputBorder(),
                    ),
                    items: _subjects
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSubject = v!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _timeLimitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Thời gian',
                      border: OutlineInputBorder(),
                      suffixText: 'phút',
                    ),
                    validator: (v) => v!.isEmpty ? 'Nhập thời gian' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _visibility,
                    decoration: const InputDecoration(
                      labelText: 'Quyền truy cập',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.public),
                    ),
                    items: _visibilityOptions
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) => setState(() => _visibility = v!),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Cấu hình Quiz',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
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
                        ),
                        validator: (v) {
                          if (!_allowRetake) return null;
                          if (v == null || v.isEmpty) {
                            return 'Vui lòng nhập số lần';
                          }
                          if (int.parse(v) < 2) return 'Phải lớn hơn 1';
                          return null;
                        },
                      ),
                    ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách câu hỏi (${_questions.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _navigateToQuestionEditor(),
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
                        'Chưa có câu hỏi nào',
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
                        return InkWell(
                          onTap: () => _navigateToQuestionEditor(
                            questionToEdit: q,
                            index: index,
                          ),
                          child: AddedQuestionItem(
                            index: index,
                            question: q,
                            onDelete: () {
                              setState(() {
                                _questions.removeAt(index);
                                _questionCountController.text = _questions
                                    .length
                                    .toString();
                              });
                            },
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
                  onPressed: isLoading ? null : _handleUpdateQuiz,
                  child: const Text('Lưu thay đổi'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
