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
      }).toList();

      posts.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      state = posts;
    });
  }

  Future<void> createPost(ForumPost post) async {
    await _db.child(post.postId).set(post.toJson());
  }

  Future<void> togglePin(String id, bool pin) async {
    await _db.child(id).update({"isPinned": pin});
  }

  Future<void> toggleLock(String id, bool lock) async {
    await _db.child(id).update({"isLocked": lock});
  }

  Future<void> deletePost(String id) async {
    await _db.child(id).remove();
  }
}
