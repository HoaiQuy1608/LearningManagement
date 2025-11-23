import 'package:flutter/material.dart';
import 'package:learningmanagement/models/forum_post_model.dart';

class PostFooter extends StatelessWidget {
  final ForumPost post;

  const PostFooter({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.comment),
        ),
      ],
    );
  }
}
