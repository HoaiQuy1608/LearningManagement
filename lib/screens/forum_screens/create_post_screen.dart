import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/forum_post_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/providers/forum_provider.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final ForumPost? editPost; // Nếu khác null -> chỉnh sửa

  const CreatePostScreen({this.editPost, super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  late TextEditingController titleCtrl;
  late TextEditingController contentCtrl;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.editPost?.title ?? "");
    contentCtrl = TextEditingController(text: widget.editPost?.content ?? "");
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
      title: Text(
        widget.editPost != null ? "Chỉnh sửa bài viết" : "Tạo bài viết",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white, 
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF8A63D2)], 
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
      ),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Tiêu đề"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 6,
              decoration: const InputDecoration(labelText: "Nội dung"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (authState.userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lỗi: chưa đăng nhập")),
                  );
                  return;
                }

                final trimmedTitle = titleCtrl.text.trim();
                final trimmedContent = contentCtrl.text.trim();
                if (trimmedTitle.isEmpty || trimmedContent.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Vui lòng điền đầy đủ tiêu đề và nội dung")),
                  );
                  return;
                }

                if (widget.editPost != null) {
                  final updatedPost = widget.editPost!.copyWith(
                    title: trimmedTitle,
                    content: trimmedContent,
                  );
                  ref.read(forumPostProvider.notifier).updatePost(updatedPost);
                } else {
                  final newPost = ForumPost(
                    postId: const Uuid().v4(),
                    userId: authState.userId!,
                    classId: null,
                    title: trimmedTitle,
                    content: trimmedContent,
                    tags: [],
                    createdAt: DateTime.now(),
                  );
                  ref.read(forumPostProvider.notifier).createPost(newPost);
                }

                Navigator.pop(context);
              },
              child: Text(widget.editPost != null ? "Cập nhật" : "Đăng bài"),
            )
          ],
        ),
      ),
    );
  }
}
