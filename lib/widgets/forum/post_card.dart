// post_card.dart
import 'package:flutter/material.dart';
import '../../models/forum_post_model.dart';
import 'post_header.dart';
import 'post_footer.dart';

class PostCard extends StatelessWidget {
  final ForumPost post;

  const PostCard({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: post.isDeleted ? Colors.grey[200] : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị thông báo nếu post bị xóa
          if (post.isDeleted)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Bài viết đã bị xóa${post.deleteReason != null ? ': ${post.deleteReason}' : ''}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          PostHeader(post: post),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(post.content),
          ),
          PostFooter(post: post),
        ],
      ),
    );
  }
}
