import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/widgets/forum/comment_title.dart';
import '../../models/forum_post_model.dart';
import '../../providers/comment_provider.dart' as cp;
import '../../widgets/forum/post_card.dart';
import '../../widgets/forum/comment_input.dart';

class PostDetailScreen extends ConsumerWidget {
  final ForumPost post;

  const PostDetailScreen({required this.post, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(cp.commentProvider(post.postId));

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết bài viết"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 70),
              children: [
                // Hiển thị bài viết
                PostCard(post: post),

                const Divider(),

                // Tiêu đề comment
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Bình luận",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

                // Nếu chưa có bình luận
                if (comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("Chưa có bình luận nào"),
                  ),

                // Danh sách comment
                ...comments.map((c) => CommentTile(comment: c, postId: post.postId)).toList(),
              ],
            ),
          ),

          // Input thêm comment
          CommentInput(postId: post.postId),
        ],
      ),
    );
  }
}
