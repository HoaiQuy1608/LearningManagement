import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:learningmanagement/models/forum_post_model.dart';

final forumPostProvider =
    StateNotifierProvider<ForumPostNotifier, List<ForumPost>>(
  (ref) => ForumPostNotifier(),
);

class ForumPostNotifier extends StateNotifier<List<ForumPost>> {
  ForumPostNotifier() : super([]) {
    _listenPosts();
  }

  final _db = FirebaseDatabase.instance.ref("forum_posts");
  final _reportDb = FirebaseDatabase.instance.ref("forum_reports");
  final _notificationDb = FirebaseDatabase.instance.ref("notifications"); 

  void _listenPosts() {
  _db.onValue.listen((event) {
    final data = event.snapshot.value;
    if (data == null) {
      state = [];
      return;
    }

    final map = Map<String, dynamic>.from(data as Map);
    final posts = map.values.map((e) {
      return ForumPost.fromJson(Map<String, dynamic>.from(e));
    }).where((post) => !post.isDeleted) 
      .toList();

    posts.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    state = posts;
  });
}

  // Tạo bài viết mới
  Future<void> createPost(ForumPost post) async {
    await _db.child(post.postId).set(post.toJson());
  }

  // Cập nhật bài viết
  Future<void> updatePost(ForumPost post) async {
    await _db.child(post.postId).update({
      "title": post.title,
      "content": post.content,
      "tags": post.tags,
    });
  }

  Future<void> deletePost({
    required ForumPost post,
    required String deletedByUserId,
    String? reason,
  }) async {

    await _db.child(post.postId).update({
      "isDeleted": true,
      "deletedBy": deletedByUserId,
      "deleteReason": reason ?? "",
      "deletedAt": DateTime.now().toIso8601String(),
    });

    final notificationRef = _notificationDb.push();
    await notificationRef.set({
      "userId": post.userId, 
      "type": "post_deleted",
      "postId": post.postId,
      "deletedBy": deletedByUserId,
      "reason": reason ?? "",
      "createdAt": DateTime.now().toIso8601String(),
      "isRead": false,
    });
  }

  Future<void> togglePin(String id, bool pin) async {
    await _db.child(id).update({"isPinned": pin});
  }

  Future<void> toggleLock(String id, bool lock) async {
    await _db.child(id).update({"isLocked": lock});
  }

  Future<void> reportPost(String postId, String reason) async {
    final newReportRef = _reportDb.push();
    await newReportRef.set({
      "postId": postId,
      "reason": reason,
      "createdAt": DateTime.now().toIso8601String(),
    });
  }
}
