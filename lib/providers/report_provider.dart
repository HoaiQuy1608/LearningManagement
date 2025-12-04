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

final commentContentProvider =
    FutureProvider.family<String, Map<String, String>>((ref, data) async {
  final postId = data["postId"]!;
  final commentId = data["commentId"]!;

  final snap =
      await FirebaseDatabase.instance.ref("comments/$postId/$commentId").get();

  if (!snap.exists) return "[Bình luận đã bị xoá]";

  final m = Map<String, dynamic>.from(snap.value as Map);
  return m["content"] ?? "[Không có nội dung]";
});

