import 'package:flutter/material.dart';
import 'package:learningmanagement/models/comment_model.dart';

class CommentFooter extends StatelessWidget {
  final Comment comment;
  final bool isLiked;
  final VoidCallback onLikeTap;

  const CommentFooter({
    required this.comment,
    required this.isLiked,
    required this.onLikeTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: onLikeTap,
            child: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: isLiked ? Colors.red : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 4),
          Text("${comment.likes.length}", style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 16),
          /*Icon(Icons.reply_outlined, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text("Trả lời", style: TextStyle(color: Colors.grey[600])),*/
        ],
      ),
    );
  }
}
