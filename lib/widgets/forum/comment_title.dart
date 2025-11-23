import 'package:flutter/material.dart';
import 'package:learningmanagement/widgets/time_ago.dart';
import '../../models/comment_model.dart';

class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: Text(comment.content),
      subtitle: Text(
        timeAgo(comment.createdAt),
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
