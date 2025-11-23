import 'package:flutter/material.dart';
import 'package:learningmanagement/models/forum_post_model.dart';
import 'package:learningmanagement/widgets/time_ago.dart';

class PostHeader extends StatelessWidget {
  final ForumPost post;

  const PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: Text(post.title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(timeAgo(post.createdAt)),
      trailing: post.isPinned
          ? Icon(Icons.push_pin, color: Colors.orange)
          : null,
    );
  }
}
