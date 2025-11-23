import 'package:firebase_database/firebase_database.dart';
import '../models/comment_model.dart';

class CommentService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref("comments");
  final DatabaseReference _userDb = FirebaseDatabase.instance.ref("users");

  // Stream realtime comment
  Stream<List<Comment>> commentStream(String postId) async* {
    final dbRef = _db.child(postId);
    await for (final event in dbRef.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        yield [];
        continue;
      }

      // Lấy danh sách userId để truy xuất displayName
      final userIds = data.values
          .map((e) => (e as Map)['userId'] as String)
          .toSet()
          .toList();

      final userSnapshots = await Future.wait(userIds.map((uid) async {
        final userSnap = await _userDb.child(uid).get();
        final displayName =
            (userSnap.value as Map?)?['displayName'] as String? ?? "Người dùng";
        return MapEntry(uid, displayName);
      }));

      final userMap = Map<String, String>.fromEntries(userSnapshots);

      final comments = data.values.map((json) {
        final map = Map<String, dynamic>.from(json);
        final uid = map['userId'] as String;
        // Lấy danh sách likes
        final likesMap = (map['likes'] as Map<dynamic, dynamic>?) ?? {};
        final likes = likesMap.keys.cast<String>().toList();

        return Comment.fromJson({
          ...map,
          'authorName': userMap[uid] ?? "Người dùng",
          'likes': likes,
        });
      }).toList();

      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      yield comments;
    }
  }

  // Thêm comment mới
  Future<void> addComment(Comment comment) async {
    final newRef = _db.child(comment.postId).push();
    final commentId = newRef.key!;
    final commentWithId = comment.copyWith(commentId: commentId);
    await newRef.set(commentWithId.toJson());
  }

  // Toggle like/unlike
  Future<void> toggleLikeComment(
      String postId, String commentId, String userId) async {
    final likeRef = _db.child(postId).child(commentId).child('likes');

    final snapshot = await likeRef.get();
    final likes = snapshot.value as Map<dynamic, dynamic>? ?? {};

    if (likes.containsKey(userId)) {
      await likeRef.child(userId).remove();
    } else {
      await likeRef.child(userId).set(true);
    }
  }
}
