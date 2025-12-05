import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/forum_post_model.dart';

final postsProvider = StreamProvider<Map<String, ForumPost>>((ref) {
  final refDb = FirebaseDatabase.instance.ref("forum_posts");

  return refDb.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data == null) return {};

    return data.map((key, value) {
      final m = Map<String, dynamic>.from(value);
      return MapEntry(
        key.toString(),
        ForumPost(
          postId: key.toString(),
          userId: m["userId"] ?? "",
          title: m["title"] ?? "",
          content: m["content"] ?? "",
          tags: [],
          createdAt: DateTime.tryParse(m["createdAt"] ?? "") ?? DateTime.now(),
          isDeleted: m["isDeleted"] ?? false,
          isLocked: m["isLocked"] ?? false,
          isPinned: m["isPinned"] ?? false,
        ),
      );
    });
  });
});

// POST REPORTS
final postReportProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final refDb = FirebaseDatabase.instance.ref("forum_reports");

  return refDb.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data == null) return [];

    return data.values.map((e) {
      final m = Map<String, dynamic>.from(e);
      return {
        "reportId": m["reportId"],
        "postId": m["postId"],
        "reason": m["reason"],
        "status": m["status"] ?? "pending",
      };
    }).toList();
  });
});

// COMMENT REPORTS
final commentReportProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final refDb = FirebaseDatabase.instance.ref("commentReports");

  return refDb.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>?;

    if (data == null) return [];

    return data.values.map((e) {
      final m = Map<String, dynamic>.from(e);
      return {
        "reportId": m["reportId"],
        "postId": m["postId"],
        "commentId": m["commentId"],
        "reason": m["reason"],
        "status": m["status"] ?? "pending",
      };
    }).toList();
  });
});

final commentContentProvider = FutureProvider.family<
    String,
    (String postId, String commentId)
>((ref, params) async {

  final (postId, commentId) = params;

  final snap = await FirebaseDatabase.instance
      .ref("comments/$postId/$commentId")
      .get();

  if (!snap.exists) return "[Bình luận không còn tồn tại]";

  final data = snap.value as Map?;
  return data?["content"] ?? "[Không có nội dung]";
});

final updateReportStatusProvider =
    Provider<Function({required String reportId, required String type, required String status})>((ref) {
  return ({
    required String reportId,
    required String type,
    required String status,
  }) async {
    final db = FirebaseDatabase.instance.ref();
    await db.child("$type/$reportId").update({
      "status": status,
    });

    ref.invalidate(commentReportProvider);
    ref.invalidate(postReportProvider);
  };
});




