// forum_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/forum/post_card.dart';
import 'create_post_screen.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(forumPostProvider);
    final currentUser = ref.watch(authProvider);

    // Nếu user chưa load xong, show loading
    if (currentUser.userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forum"),
        centerTitle: true,
      ),
      body: posts.isEmpty
          ? const Center(child: Text("Không có bài viết nào"))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: posts.length,
              itemBuilder: (context, i) {
                final post = posts[i];

                // User thường: không hiển thị post đã xóa
                final canSeeDeleted = currentUser.userRole == UserRole.kiemDuyet ||
                    currentUser.userRole == UserRole.admin;

                if (post.isDeleted && !canSeeDeleted) {
                  return const SizedBox.shrink(); // bỏ qua post
                }

                return GestureDetector(
                  onTap: () {
                    // TODO: mở chi tiết post nếu cần
                  },
                  child: PostCard(post: post),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
