import 'package:flutter/material.dart';
import 'package:learningmanagement/models/comment_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

class CommentFooter extends StatelessWidget {
  final Comment comment;
  final bool isLiked;
  final VoidCallback onLikeTap;

  final String currentUserId;
  final UserRole currentUserRole;

  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onReport;
  final VoidCallback? onModeratorDelete;

  const CommentFooter({
    required this.comment,
    required this.isLiked,
    required this.onLikeTap,
    required this.currentUserId,
    required this.currentUserRole,
    this.onDelete,
    this.onEdit,
    this.onReport,
    this.onModeratorDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOwner = comment.userId == currentUserId;
    final bool isModOrAdmin = currentUserRole == UserRole.admin || currentUserRole == UserRole.kiemDuyet;

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

          const Spacer(),


          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 18),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  if (onEdit != null) onEdit!();
                  break;
                case 'delete':
                  if (onDelete != null) onDelete!();
                  break;
                case 'report':
                  if (onReport != null) onReport!();
                  break;
                case 'modDelete':
                  if (onModeratorDelete != null) onModeratorDelete!();
                  break;
              }
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> items = [];

              if (isOwner) {
                items.add(
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Chỉnh sửa")],
                    ),
                  ),
                );
                items.add(
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [Icon(Icons.delete, size: 18), SizedBox(width: 8), Text("Xóa")],
                    ),
                  ),
                );
              }
              if (!isOwner && isModOrAdmin) {
                items.add(
                  const PopupMenuItem(
                    value: 'modDelete',
                    child: Row(
                      children: [Icon(Icons.delete_forever, size: 18), SizedBox(width: 8), Text("Xóa (kèm lý do)")],
                    ),
                  ),
                );
              }
              if (!isOwner && !isModOrAdmin) {
                items.add(
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [Icon(Icons.flag, size: 18), SizedBox(width: 8), Text("Báo cáo")],
                    ),
                  ),
                );
              }
              return items;
            },
          ),
        ],
      ),
    );
  }
}
