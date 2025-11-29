import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/screens/documents/document_pending.dart';
import 'package:learningmanagement/widgets/document/document_constants.dart';
import 'package:learningmanagement/widgets/document/document_item.dart';
import '../../providers/auth_provider.dart';
import '../../models/document_model.dart';
import 'upload_document_screen.dart';

class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("documents");

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;
    final role = authState.userRole; 
    //final classId = authState.classId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài liệu"),
        actions: [
          if ( role == UserRole.kiemDuyet)
            IconButton(
              icon: const Icon(Icons.pending_actions),
              onPressed: () =>
                  Navigator.pushNamed(context, "/documents/pending"),
            ),
        ],
      ),

      body: StreamBuilder(
        stream: dbRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Lỗi tải tài liệu"));
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("Không có tài liệu nào"));
          }

          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          List<DocumentModel> docs = data.entries.map((e) {
            return DocumentModel.fromJson(Map<String, dynamic>.from(e.value));
          }).toList();

          docs = docs.where((d) => d.status == statusApproved).toList();


          List<DocumentModel> filteredDocs = docs.where((d) {
            if (role == UserRole.admin || role == UserRole.kiemDuyet) {
              return true; // xem tất cả
            }

            // Giảng viên
            if (role == UserRole.giangVien) {
              return d.visibility == "public" ||

                  //(d.status == "only_class" && d.classId == classId) ||

                  (d.status == "private" && d.uploaderId == userId);
            }

            // Sinh viên
            if (role == UserRole.sinhVien) {
              return d.visibility == "public" ;//||
                  //(d.status == "only_class" && d.classId == classId);
            }

            return false;
          }).toList();

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];

            //list document(trong widget)
              return DocumentItem(
                doc: doc,
                role: authState.userRole ?? UserRole.sinhVien,
                onDelete: () => showDeleteDialog(doc),
              );
            },
          );
        },
      ),

      floatingActionButton: Builder(
        builder: (context) {
          if (role == UserRole.admin || role == UserRole.kiemDuyet) {
            return FloatingActionButton.extended(
              backgroundColor: Colors.amber,
              icon: const Icon(Icons.pending_actions),
              label: const Text("Kiểm duyệt"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PendingDocumentScreen(),
                  ),
                );
              },
            );
          }

          if (role == UserRole.giangVien || role == UserRole.sinhVien) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadDocumentScreen()),
                );
              },
              child: const Icon(Icons.upload),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
  
  void showDeleteDialog(DocumentModel doc) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Xóa tài liệu: ${doc.title}"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nhập lý do xóa",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Hủy"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Xóa"),
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) return;

              // Lưu lý do + xóa doc
              dbRef.child(doc.docId).update({
                "deletedReason": reason,
                "status": "deleted",
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
