import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/forum_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // 4. Hàm xử lý logic "Đăng bài"
  Future<void> _handleCreatePost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await ref
        .read(forumProvider.notifier)
        .createPost(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          author: 'SinhVienTest',
        );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      forumProvider.select((state) => state.isLoading),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo chủ đề mới')),
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
                  labelText: 'Tiêu đề bài đăng',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập tiêu đề'
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Vui lòng nhập nội dung'
                    : null,
              ),
              const SizedBox(height: 16.0),

              // --- TODO: Nút "Đính kèm file/ảnh" ---
              // (Theo đặc tả)
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Đính kèm (Không bắt buộc)'),
                onPressed: () {
                  print('TODO: Mở File Picker');
                },
              ),

              const SizedBox(height: 24.0),

              // --- Nút Đăng bài ---
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _handleCreatePost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Đăng bài'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
