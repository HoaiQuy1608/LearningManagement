import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/comment_model.dart';
import '../service/comment_service.dart';
import 'auth_provider.dart';

final commentProvider =
    StateNotifierProvider.family<CommentNotifier, List<Comment>, String>(
  (ref, postId) => CommentNotifier(postId, ref),
);

class CommentNotifier extends StateNotifier<List<Comment>> {
  final String postId;
  final Ref ref;
  final CommentService _service = CommentService();
  Stream<List<Comment>>? _streamSubscription;

  CommentNotifier(this.postId, this.ref) : super([]) {
    _listenComments();
  }

  void _listenComments() {
    _streamSubscription = _service.commentStream(postId);
    _streamSubscription!.listen((comments) {
      state = comments;
    });
  }

  Future<void> addComment(String content) async {
    final authState = ref.read(authProvider);
    if (authState.userId == null) return;

    final comment = Comment(
      commentId: "",
      postId: postId,
      userId: authState.userId!,
      authorName: authState.displayName ?? "Người dùng",
      content: content,
      createdAt: DateTime.now(),
      likes: [],
    );

    await _service.addComment(comment);
  }

  Future<void> deleteComment(String commentId) async {
    final authState = ref.read(authProvider);
    if (authState.userId == null) return;

    await _service.updateComment(
      postId,
      commentId,
      {
        "deleted": true,
        "deletedAt": DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> editComment(String commentId, String newContent) async {
    final authState = ref.read(authProvider);
    if (authState.userId == null) return;

    await _service.updateComment(
      postId,
      commentId,
      {
        "content": newContent,
        "editedAt": DateTime.now().toIso8601String(),
      },
    );
  }
Future<void> reportComment(String commentId, String reason) async {
  final authState = ref.read(authProvider);
  if (authState.userId == null) return;

  // Gọi service để lưu báo cáo
  await _service.reportComment(
    postId: postId,
    commentId: commentId,
    reportedByUserId: authState.userId!,
    reason: reason,
    reportedAt: DateTime.now(),
  );
}


  Future<void> toggleLike(String commentId) async {
    final authState = ref.read(authProvider);
    if (authState.userId == null) return;
    await _service.toggleLikeComment(postId, commentId, authState.userId!);
  }
}
