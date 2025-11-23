import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/forum_post_model.dart';
import '../../providers/like_provider.dart';
import '../../providers/comment_provider.dart' as cp;

class PostFooter extends ConsumerWidget {
  final ForumPost post;
  const PostFooter({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeStateAsync = ref.watch(likeProvider(post.postId));
    final comments = ref.watch(cp.commentProvider(post.postId)); // <-- Lấy danh sách comment

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          likeStateAsync.when(
            data: (likeState) => Row(
              children: [
                IconButton(
                  icon: Icon(
                    likeState.isLikedByUser ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: likeState.isLikedByUser ? Colors.blue : null,
                  ),
                  onPressed: () => ref.read(likeNotifierProvider(post.postId)).toggleLike(),
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

          /// Số comment dựa trên danh sách từ provider
          Text("${comments.length}"),
        ],
      ),
    );
  }
}
