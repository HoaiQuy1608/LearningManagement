import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/comment_model.dart';
import 'auth_provider.dart'; // lấy user từ AuthState

final commentProvider =
    StateNotifierProvider.family<CommentNotifier, List<Comment>, String>(
  (ref, postId) => CommentNotifier(postId, ref),
);

class CommentNotifier extends StateNotifier<List<Comment>> {
  final String postId;
  final Ref ref;
  final db = FirebaseDatabase.instance.ref("comments");

  CommentNotifier(this.postId, this.ref) : super([]) {
    _listenComments();
  }

  void _listenComments() {
    db.child(postId).onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null || data is!Map) {
        state = [];
        return;
      }

      final map = Map<dynamic, dynamic>.from(data);

      final comments = map.values.map((json) {
        return Comment.fromJson(Map<String, dynamic>.from(json));
      }).toList();

      // Sắp xếp tăng dần theo thời gian
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      state = comments;
    });
  }

  Future<void> addComment(String content) async {
    final authState = ref.read(authProvider);

    final userId = authState.userId;
    final displayName = authState.displayName;

    if (userId == null || displayName == null) {
      throw Exception("Người dùng chưa đăng nhập hoặc chưa có tên hiển thị");
    }

    final newRef = db.child(postId).push();
    final commentId = newRef.key!;

    final comment = Comment(
      commentId: commentId,
      postId: postId,
      userId: userId,
      authorName: displayName,
      content: content,
      createdAt: DateTime.now(),
    );

    await newRef.set(comment.toJson());
  }
}
