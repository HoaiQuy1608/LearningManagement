import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/document_provider.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  _UploadDocumentScreenState createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSubject;
  String? _selectedAccessLevel;
  String? _pickedFileName;
  String? _coverImageName;
  final List<String> _subjects = [
    'Kinh tế chính trị',
    'Triết học',
    'Pháp luật',
    'Flutter',
  ];
  final List<String> _accessLevels = ['Public', 'Class', 'Private'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(documentProvider.notifier)
        .uploadDocument(
          title: _titleController.text.trim(),
          author: 'Who',
          rating: 0.0,
          downloads: 0,
          description: _descriptionController.text.trim(),
          subject: _selectedSubject ?? '',
          accessLevel: _selectedAccessLevel ?? '',
          fileName: _pickedFileName ?? '',
          coverImageName: _coverImageName,
        );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _pickFile() {
    setState(() {
      _pickedFileName = 'gia-trinh-kinh-te.pdf';
    });
  }

  void _pickCoverImage() {
    setState(() {
      _coverImageName = 'anh-bia.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      documentProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tải lên tài liệu')),
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
                  labelText: 'Tiêu đề tài liệu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập tiêu đề'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập mô tả'
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
                items: _subjects
                    .map(
                      (String subject) => DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedSubject = newValue),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn môn học' : null,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                initialValue: _selectedAccessLevel,
                hint: const Text('Chọn quyền truy cập'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_open_outlined),
                ),
                items: _accessLevels
                    .map(
                      (String level) => DropdownMenuItem<String>(
                        value: level,
                        child: Text(level),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedAccessLevel = newValue),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn quyền truy cập' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Chọn file (pdf/doc/zip...)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.attach_file),
                  hintText: _pickedFileName ?? 'Chưa chọn file',
                ),
                onTap: _pickFile,
                validator: (value) =>
                    _pickedFileName == null ? 'Vui lòng chọn một file' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Chọn ảnh bìa (Không bắt buộc)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.image_outlined),
                  hintText: _coverImageName ?? 'Chưa chọn ảnh',
                ),
                onTap: _pickCoverImage,
              ),
              const SizedBox(height: 24.0),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16.0),
                      ),
                      icon: const Icon(Icons.upload),
                      label: const Text('Tải lên'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
