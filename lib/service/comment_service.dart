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

      // Lấy danh sách userId để truy xuất displayName và avatarUrl
      final userIds = data.values
          .map((e) => (e as Map)['userId'] as String)
          .toSet()
          .toList();

      final userSnapshots = await Future.wait(userIds.map((uid) async {
        final userSnap = await _userDb.child(uid).get();
        final userMap = userSnap.value as Map?;
        final displayName = userMap?['displayName'] as String? ?? "Người dùng";
        final avatarUrl = userMap?['avatarUrl'] as String?;
        return MapEntry(uid, {'displayName': displayName, 'avatarUrl': avatarUrl});
      }));

      final userMap = Map<String, Map<String, String?>>.fromEntries(userSnapshots);

      final comments = data.values.map((json) {
        final map = Map<String, dynamic>.from(json);
        final uid = map['userId'] as String;

        // Lấy danh sách likes
        final likesMap = (map['likes'] as Map<dynamic, dynamic>?) ?? {};
        final likes = likesMap.keys.cast<String>().toList();

        return Comment.fromJson({
          ...map,
          'authorName': userMap[uid]?['displayName'] ?? "Người dùng",
          'avatarUrl': userMap[uid]?['avatarUrl'],
          'likes': likes,
        });
      }).toList();

      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      yield comments;
    }
  }

  // Thêm comment mới
  Future<void> addComment(Comment comment) async {
    final userSnap = await _userDb.child(comment.userId).get();
    final userMap = userSnap.value as Map?;
    final avatarUrl = userMap?['avatarUrl'] as String?;

    final newRef = _db.child(comment.postId).push();
    final commentId = newRef.key!;
    final commentWithId = comment.copyWith(commentId: commentId, avatarUrl: avatarUrl);

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
