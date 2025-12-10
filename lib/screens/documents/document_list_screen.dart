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
  final bool showAppBar;
  const DocumentListScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref("documents");
  Widget _buildBodyContent() {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;
    final role = authState.userRole;

    return StreamBuilder(
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
          if (role == UserRole.admin || role == UserRole.kiemDuyet) return true;
          if (role == UserRole.giangVien) {
            return d.visibility == "public" ||
                (d.status == "private" && d.uploaderId == userId);
          }
          if (role == UserRole.sinhVien) {
            return d.visibility == "public";
          }
          return false;
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            return DocumentItem(
              doc: doc,
              role: authState.userRole ?? UserRole.sinhVien,
              onDelete: () => showDeleteDialog(doc),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final role = authState.userRole;
    final bodyWithFab = Scaffold(
      body: _buildBodyContent(),
      floatingActionButton: Builder(builder: (context) {
        if (role == UserRole.admin || role == UserRole.kiemDuyet) {
          return FloatingActionButton.extended(
            backgroundColor: Colors.amber,
            icon: const Icon(Icons.pending_actions),
            label: const Text("Kiểm duyệt"),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PendingDocumentScreen()),
            ),
          );
        }
        if (role == UserRole.giangVien || role == UserRole.sinhVien) {
          return FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadDocumentScreen()),
            ),
            child: const Icon(Icons.upload),
          );
        }
        return const SizedBox();
      }),
    );

    if (!widget.showAppBar) {
      return bodyWithFab;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài liệu", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          if (role == UserRole.kiemDuyet)
            IconButton(
              icon: const Icon(Icons.pending_actions),
              onPressed: () => Navigator.pushNamed(context, "/documents/pending"),
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A5AE0), Color(0xFF8A63D2)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      body: bodyWithFab.body,
      floatingActionButton: bodyWithFab.floatingActionButton,
    );
  }

  void showDeleteDialog(DocumentModel doc) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Xóa tài liệu: ${doc.title}"),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: "Nhập lý do xóa")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) return;
              dbRef.child(doc.docId).update({"deletedReason": reason, "status": "deleted"});
              Navigator.pop(context);
            },
            child: const Text("Xóa"),
          ),
        ],
      ),
    );
  }
}