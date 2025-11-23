import 'package:flutter/material.dart';
import 'package:learningmanagement/models/forum_post_model.dart';
import 'post_header.dart';
import 'post_footer.dart';

class PostCard extends StatelessWidget {
  final ForumPost post;

  const PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(post: post),
          Padding(
            padding: EdgeInsets.all(12),
            child: Text(post.content),
          ),
          PostFooter(post: post),
        ],
      ),
    );
  }
}
