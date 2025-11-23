import 'package:firebase_database/firebase_database.dart';

class LikeService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Lấy stream realtime likes
  Stream<Map<String, bool>> streamLikes(String postId) {
    return _db.child('likes/$postId').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      // Chuyển về Map<String, bool>
      return data.map((key, value) => MapEntry(key.toString(), value as bool));
    });
  }

  // Like/unlike
  Future<void> toggleLike(String postId, String userId) async {
    final ref = _db.child("likes/$postId/$userId");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      await ref.remove(); // unlike
    } else {
      await ref.set(true); // like
    }
  }
}
