import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/forum_provider.dart';
import 'package:learningmanagement/screens/forum_screens/create_post_screen.dart';
import '../../models/forum_post_model.dart';
import '../../providers/like_provider.dart';
import '../../providers/comment_provider.dart' as cp;
import '../../providers/auth_provider.dart';

class PostFooter extends ConsumerWidget {
  final ForumPost post;
  const PostFooter({required this.post, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeStateAsync = ref.watch(likeProvider(post.postId));
    final comments = ref.watch(cp.commentProvider(post.postId));
    final currentUser = ref.watch(authProvider); 

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              likeStateAsync.when(
                data: (likeState) => Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        likeState.isLikedByUser ? Icons.favorite : Icons.favorite_border,
                        color: likeState.isLikedByUser ? Colors.red : null,
                      ),
                      onPressed: () =>
                          ref.read(likeNotifierProvider(post.postId)).toggleLike(),
                    ),
                    Text("${likeState.likesCount}"),
                  ],
                ),
                loading: () => const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Icon(Icons.error),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.comment_outlined),
              const SizedBox(width: 4),
              Text("${comments.length}"),
            ],
          ),

          PopupMenuButton<String>(
            onSelected: (value) async {
              final isOwner = currentUser.userId == post.userId;
              final isModerator = currentUser.userRole == UserRole.kiemDuyet;

              if (value == 'edit' && isOwner) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePostScreen(editPost: post),
                  ),
                );
              } else if (value == 'delete' && (isOwner || isModerator)) {
                String? reason;

                if (isModerator && !isOwner) {
                  final reasonController = TextEditingController();
                  final submit = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Xóa bài viết"),
                      content: TextField(
                        controller: reasonController,
                        decoration: const InputDecoration(labelText: "Lý do xóa"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Hủy"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (!(submit ?? false)) return;
                  reason = reasonController.text.trim();
                } else {
                  // Chủ bài viết -> confirm xóa
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Xóa bài viết"),
                      content: const Text("Bạn có chắc chắn muốn xóa bài viết này?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Hủy"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Xóa", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (!(confirm ?? false)) return;
                }

                await ref.read(forumPostProvider.notifier).deletePost(
                      post: post,
                      deletedByUserId: currentUser.userId!,
                      reason: reason,
                    );
              } else if (value == 'report') {
                final reasonController = TextEditingController();
                final submit = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Báo cáo bài viết"),
                    content: TextField(
                      controller: reasonController,
                      decoration: const InputDecoration(labelText: "Lý do báo cáo"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Gửi", style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                );
                if (submit ?? false) {
                  await ref
                      .read(forumPostProvider.notifier)
                      .reportPost(post.postId, reasonController.text);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Báo cáo đã được gửi")));
                }
              }
            },

            itemBuilder: (BuildContext context) {
              final isOwner = currentUser.userId == post.userId;
              final isModerator = currentUser.userRole == UserRole.kiemDuyet;

              List<PopupMenuEntry<String>> items = [];

              if (isOwner) {
                items.add(const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')));
                items.add(const PopupMenuItem(value: 'delete', child: Text('Xóa')));
              } else if (isModerator) {
                // Moderator có thể xóa bài người khác
                items.add(const PopupMenuItem(value: 'delete', child: Text('Xóa')));
              }
              if(!isModerator){
                items.add(const PopupMenuItem(value: 'report', child: Text('Báo cáo')));
              }
              return items;
            },
            icon: const Icon(Icons.more_vert),
          )

        ],
      ),
    );
  }
}
