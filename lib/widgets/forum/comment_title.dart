// comment_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import 'comment_footer.dart';

class CommentTile extends ConsumerWidget {
  final String postId;
  final String commentId;
  final bool highlight;

  const CommentTile({
    required this.postId,
    required this.commentId,
    this.highlight= false, 
    super.key
    });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(commentProvider(postId));
    final authState = ref.watch(authProvider);
    final userId = authState.userId ?? "";

    final comment = comments.firstWhere(
      (c) => c.commentId == commentId,
      orElse: () => Comment(
        commentId: commentId,
        postId: postId,
        userId: "",
        authorName: "Unknown",
        content: "[Bình luận đã xoá]",
        createdAt: DateTime.now(),
        likes: [],
      ),
    );

    final isOwner = comment.userId == userId;
    final isModOrAdmin =
        authState.userRole == UserRole.admin || authState.userRole == UserRole.kiemDuyet;

    void toggleLike() async {
      if (userId.isEmpty) return;
      await ref.read(commentProvider(postId).notifier).toggleLike(comment.commentId);
    }

    // Edit comment
    Future<void> editComment() async {
      final notifier = ref.read(commentProvider(postId).notifier);
      final newContent = await showDialog<String>(
        context: context,
        builder: (context) {
          String tempContent = comment.content;
          return AlertDialog(
            title: const Text("Chỉnh sửa bình luận"),
            content: TextField(
              autofocus: true,
              maxLines: null,
              onChanged: (val) => tempContent = val,
              controller: TextEditingController(text: comment.content),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
              TextButton(
                  onPressed: () => Navigator.pop(context, tempContent),
                  child: const Text("Lưu")),
            ],
          );
        },
      );

      if (newContent != null && newContent.trim().isNotEmpty) {
        await notifier.editComment(comment.commentId, newContent);
      }
    }

    // Delete comment
    Future<void> deleteComment() async {
      final notifier = ref.read(commentProvider(postId).notifier);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Xóa bình luận?"),
          content: const Text("Bạn có chắc muốn xóa bình luận này không?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
          ],
        ),
      );
      if (confirmed == true) {
        await notifier.deleteComment(comment.commentId);
      }
    }

    // Moderator delete
    Future<void> modDelete() async {
      final notifier = ref.read(commentProvider(postId).notifier);
      final reason = await showDialog<String>(
        context: context,
        builder: (context) {
          String tempReason = "";
          return AlertDialog(
            title: const Text("Xóa bình luận (moderator/admin)"),
            content: TextField(
              autofocus: true,
              maxLines: null,
              decoration: const InputDecoration(hintText: "Nhập lý do xóa"),
              onChanged: (val) => tempReason = val,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
              TextButton(onPressed: () => Navigator.pop(context, tempReason), child: const Text("Xóa")),
            ],
          );
        },
      );
      if (reason != null && reason.trim().isNotEmpty) {
        await notifier.deleteComment(comment.commentId);
      }
    }

    Future<void> reportComment() async {
      final reasonController = TextEditingController();
      final submit = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Báo cáo bình luận"),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: "Lý do báo cáo"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Gửi")),
          ],
        ),
      );

      if (submit ?? false) {
        await ref.read(commentProvider(postId).notifier)
            .reportComment(comment.commentId, reasonController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Báo cáo đã được gửi"))
        );
      }
    }

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
          CommentFooter(
            comment: comment,
            isLiked: comment.likes.contains(userId),
            onLikeTap: toggleLike,
            currentUserId: userId,
            currentUserRole: authState.userRole ?? UserRole.sinhVien,
            onEdit: isOwner ? editComment : null,
            onDelete: isOwner ? deleteComment : null,
            onReport: (!isOwner && !isModOrAdmin) ? reportComment : null,
            onModeratorDelete: (!isOwner && isModOrAdmin) ? modDelete : null,
          ),
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
        backgroundImage:
            comment.avatarUrl != null ? NetworkImage(comment.avatarUrl!) : null,
        backgroundColor: Colors.blue,
        child: comment.avatarUrl == null
            ? Text(
                comment.authorName.isNotEmpty
                    ? comment.authorName[0].toUpperCase()
                    : "U",
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
      return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    }
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
