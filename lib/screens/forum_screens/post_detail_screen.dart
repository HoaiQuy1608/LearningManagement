import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/widgets/forum/comment_input.dart';
import 'package:learningmanagement/widgets/forum/comment_title.dart';
import 'package:learningmanagement/widgets/forum/post_card.dart';
import '../../models/forum_post_model.dart';
import '../../providers/comment_provider.dart' as cp;

class PostDetailScreen extends ConsumerStatefulWidget {
  final ForumPost post;
  final String? scrollToCommentId; 

  const PostDetailScreen({
    required this.post,
    this.scrollToCommentId,
    super.key,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.scrollToCommentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToComment(widget.scrollToCommentId!);
      });
    }
  }

  void _scrollToComment(String commentId) {
    final comments = ref.read(cp.commentProvider(widget.post.postId));
    final visibleComments = comments.where((c) => c.deleted != true).toList();
    final index = visibleComments.indexWhere((c) => c.commentId == commentId);

    if (index != -1) {
      _scrollController.animateTo(
        250.0 + index * 100.0, 
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(cp.commentProvider(widget.post.postId));
    final visibleComments = comments.where((c) => c.deleted != true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết bài viết"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 70),
              children: [
                PostCard(post: widget.post),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Bình luận",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                if (comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("Chưa có bình luận nào"),
                  ),
                ...visibleComments
                    .map((c) => CommentTile(
                        postId: widget.post.postId, commentId: c.commentId))
                    .toList(),
              ],
            ),
          ),
          CommentInput(postId: widget.post.postId),
        ],
      ),
    );
  }
}

