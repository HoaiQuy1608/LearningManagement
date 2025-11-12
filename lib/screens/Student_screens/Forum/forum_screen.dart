import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/forum_provider.dart';
import 'create_post_screen.dart';

class ForumScreen extends ConsumerWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forumState = ref.watch(forumProvider);
    final posts = forumState.posts;

    return Stack(
      children: [
        ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
                  child: Text(
                    post.author.length >= 2 ? post.author.substring(0, 2) : '?',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(post.title),
                subtitle: Text(
                  'Tác giả: ${post.author} | ${post.replyCount} trả lời | ${post.likeCount} thích',
                ),

                trailing: const Icon(Icons.arrow_forward_ios, size: 14.0),
                onTap: () {
                  print('TODO: Mở chi tiết bài đăng ${post.title}');
                },
              ),
            );
          },
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );
            },
            child: const Icon(Icons.edit),
          ),
        ),
        if (forumState.isLoading)
          Container(
            color: Colors.black.withAlpha(77),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
