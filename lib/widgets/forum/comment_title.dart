import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/service/comment_service.dart';
import 'package:learningmanagement/widgets/forum/comment_footer.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';

class CommentTile extends ConsumerStatefulWidget {
  final Comment comment;
  final String postId;

  const CommentTile({required this.comment, required this.postId, super.key});

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  late Comment comment;

  @override
  void initState() {
    super.initState();
    comment = widget.comment;
  }

  bool _isLiked(String userId) {
    return comment.likes.contains(userId);
  }

  void _toggleLike() async {
    final authState = ref.read(authProvider);

    if (authState.userId == null) return;

    await CommentService().toggleLikeComment(
      widget.postId,
      comment.commentId,
      authState.userId!,
    );

    // Cập nhật UI tạm thời
    setState(() {
      if (_isLiked(authState.userId!)) {
        comment.likes.remove(authState.userId);
      } else {
        comment.likes.add(authState.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(authProvider);
    final userId = authState.userId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentHeader(comment: comment),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(comment.content),
          ),
          CommentFooter(comment: comment, isLiked: _isLiked(userId ?? ""), onLikeTap: _toggleLike),
        ],
      ),
    );
  }
}

class _CommentHeader extends StatelessWidget {
  final Comment comment;
  const _CommentHeader({required this.comment});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: comment.avatarUrl != null ? NetworkImage(comment.avatarUrl!) : null,
        backgroundColor: Colors.blue,
        child: comment.avatarUrl == null
            ? Text(
                (comment.authorName.isNotEmpty ? comment.authorName[0] : "U").toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),

      title: Text(comment.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        _formatDate(comment.createdAt),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return "${date.hour}:${date.minute.toString().padLeft(2,'0')}";
    }
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2,'0')}";
  }
}


