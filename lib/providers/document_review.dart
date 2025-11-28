import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/document_model.dart';

final documentReviewProvider = Provider((ref) => DocumentReviewProvider());

class DocumentReviewProvider {
  final db = FirebaseDatabase.instance.ref("documents");
  final notifDb = FirebaseDatabase.instance.ref("notifications");

  Future<void> rejectDocument({
    required DocumentModel doc,
    required String reason,
  }) async {
    try {
      // 1. Gửi thông báo
      final notifId = DateTime.now().millisecondsSinceEpoch.toString();

      await notifDb.child(doc.uploaderId).child(notifId).set({
        "title": "Tài liệu bị từ chối",
        "message": "Tài liệu '${doc.title}' đã bị từ chối.\nLý do: $reason",
        "timestamp": ServerValue.timestamp,
        "type": "document_rejected",
      });

      // 2. XÓA document khỏi Realtime DB
      await db.child(doc.docId).remove();

    } catch (e) {
      print("Reject failed: $e");
      rethrow;
    }
  }
}
