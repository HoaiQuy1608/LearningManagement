import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';
import '../../widgets/forum/post_card.dart';
import 'package:learningmanagement/providers/forum_provider.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(forumPostProvider);

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
              itemBuilder: (context, i) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: posts[i]),
                    ),
                  );
                },
                child: PostCard(post: posts[i]),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
