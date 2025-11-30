import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/reply_model.dart';
import '../models/comment_model.dart';

class CommentService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref("comments");
  final DatabaseReference _userDb = FirebaseDatabase.instance.ref("users");
  final _reportsCollection = FirebaseDatabase.instance.ref('commentReports');
  Stream<List<Comment>> commentStream(String postId) async* {
    final dbRef = _db.child(postId);
    await for (final event in dbRef.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        yield [];
        continue;
      }
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

  Future<void> updateComment(
    String postId,
    String commentId,
    Map<String, dynamic> data,
  ) async {
    final ref = _db.child(postId).child(commentId);
    await ref.update(data);
  }


  
//===========================================================================================================
  Future<void> reportComment({
  required String postId,
  required String commentId,
  required String reportedByUserId,
  required String reason,
  required DateTime reportedAt,
}) async {
  final newRef = _reportsCollection.push(); 
  await newRef.set({
    "postId": postId,
    "commentId": commentId,
    "reportedBy": reportedByUserId,
    "reason": reason,
    "reportedAt": reportedAt.toIso8601String(),
    "status": "pending", 
  });
}
  Stream<List<Map<String, dynamic>>> reportStream() async* {
    await for (final event in _reportsCollection.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        yield [];
        continue;
      }

      final reports = data.entries.map((e) {
        final map = Map<String, dynamic>.from(e.value);
        map["reportId"] = e.key;
        return map;
      }).toList();

      yield reports;
    }
  }

//==============================================================================================================
  Future<void> addReply(String postId, String commentId, Reply reply) async {
    final replyRef = _db.child(postId).child(commentId).child('replies').push();
    final replyId = replyRef.key!;
    final replyWithId = reply.copyWith(replyId: replyId);
    await replyRef.set(replyWithId.toJson());
  }
  Future<void> toggleLikeReply(String postId, String commentId, String replyId, String userId) async {
    final likeRef = _db.child(postId).child(commentId).child('replies').child(replyId).child('likes');
    final snapshot = await likeRef.get();
    final likes = snapshot.value as Map<dynamic,dynamic>? ?? {};

    if(likes.containsKey(userId)) {
      await likeRef.child(userId).remove();
    } else {
      await likeRef.child(userId).set(true);
    }
  }
  Stream<List<Reply>> replyStream(String postId, String commentId) async* {
    final ref = _db.child(postId).child(commentId).child('replies');

    await for (final event in ref.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        yield [];
        continue;
      }
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
      final replies = data.values.map((json) {
        final map = Map<String, dynamic>.from(json);
        final uid = map['userId'] as String;

        final likesMap = (map['likes'] as Map<dynamic, dynamic>?) ?? {};
        final likes = likesMap.keys.cast<String>().toList();

        return Reply.fromJson({
          ...map,
          'authorName': userMap[uid]?['displayName'] ?? "Người dùng",
          'avatarUrl': userMap[uid]?['avatarUrl'],
          'likes': likes,
        });
      }).toList();
      replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      yield replies;
    }
  }
}
