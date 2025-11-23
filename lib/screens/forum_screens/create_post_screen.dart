import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/forum_post_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/providers/forum_provider.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tạo bài viết")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: "Tiêu đề"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 6,
              decoration: InputDecoration(labelText: "Nội dung"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final authState = ref.read(authProvider); // Lấy trạng thái đăng nhập hiện tại
                if (authState.userId == null) {
                  // Nếu chưa có userId, báo lỗi
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Lỗi: chưa đăng nhập")),
                  );
                  return;
                }

                final post = ForumPost(
                  postId: Uuid().v4(),
                  userId: authState.userId!, 
                  classId: null,
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  tags: [],
                  createdAt: DateTime.now(),
                );

                ref.read(forumPostProvider.notifier).createPost(post);
                Navigator.pop(context);
              },
              child: Text("Đăng bài"),
            )
          ],
        ),
      ),
    );
  }
}
