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
    // Không cần reload nữa, stream tự cập nhật
  }

  Future<void> toggleLike(String commentId) async {
    final authState = ref.read(authProvider);
    if (authState.userId == null) return;
    await _service.toggleLikeComment(postId, commentId, authState.userId!);
    // Stream sẽ tự cập nhật state mới
  }
}
