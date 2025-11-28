import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/document_model.dart';

final pendingDocumentsProvider =
    StreamProvider<List<DocumentModel>>((ref) {
  final db = FirebaseDatabase.instance.ref("documents");

  return db.onValue.map((event) {
    final raw = event.snapshot.value;
    if (raw == null) return <DocumentModel>[];

    final map = Map<String, dynamic>.from(raw as Map);
    return map.entries.map((e) {
      final docData = Map<String, dynamic>.from(e.value);
      docData["docId"] = e.key;
      if (docData["createdAt"] is int) {
        docData["createdAt"] =
            DateTime.fromMillisecondsSinceEpoch(docData["createdAt"]);
      } else if (docData["createdAt"] is String) {
        docData["createdAt"] = DateTime.parse(docData["createdAt"]);
      }

      return DocumentModel.fromJson(docData);
    }).where((doc) => doc.status == "pending").toList();
  });
});

final documentActionProvider = Provider((ref) {
  final db = FirebaseDatabase.instance.ref("documents");
  return DocumentAction(db);
});

class DocumentAction {
  final DatabaseReference db;
  DocumentAction(this.db);

  Future<void> approve(String docId) async {
    await db.child(docId).update({"status": "approved"});
  }

  Future<void> reject(String docId, String uploaderId, String reason) async {
    // Gửi notification
    await FirebaseDatabase.instance.ref("notifications/$uploaderId").push().set({
      "title": "Tài liệu bị từ chối",
      "message": "Tài liệu của bạn bị từ chối.\nLý do: $reason",
      "timestamp": ServerValue.timestamp,
      "type": "rejected",
    });

    // Xóa document
    await db.child(docId).remove();
  }
}
