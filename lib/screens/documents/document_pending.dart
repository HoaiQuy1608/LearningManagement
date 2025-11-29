import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/document_model.dart';
import 'package:learningmanagement/providers/document_pending_provider.dart';
import 'package:learningmanagement/screens/documents/pdf_preview_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PendingDocumentScreen extends ConsumerWidget {
  const PendingDocumentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingDocsAsync = ref.watch(pendingDocumentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Tài liệu đang chờ duyệt")),
      body: pendingDocsAsync.when(
        data: (docs) {
          if (docs.isEmpty) return const Center(child: Text("Không có tài liệu chờ duyệt"));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _DocumentCard(doc: docs[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class _DocumentCard extends ConsumerWidget {
  final DocumentModel doc;
  const _DocumentCard({required this.doc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: FirebaseDatabase.instance.ref("users/${doc.uploaderId}").get(),
      builder: (context, snapshot) {
        String name = "Unknown";
        String avatar = "";

        if (snapshot.hasData && snapshot.data!.exists) {
          final raw = snapshot.data!.value as Map<Object?, Object?>;
          final userMap = raw.map((k, v) => MapEntry(k.toString(), v));
          name = userMap['displayName']?.toString() ?? "Unknown";
          avatar = userMap['avatarUrl']?.toString() ?? "";
        }

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                      child: avatar.isEmpty ? const Icon(Icons.person, size: 30) : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        Text("Requested: ${_formatDate(doc.createdAt)}",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(doc.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(doc.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text("Subject: ${doc.subject}"),
                const SizedBox(height: 14),

                // Buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(80, 36),
                      ),
                      icon: const Icon(Icons.remove_red_eye, size: 18),
                      label: const Text(
                        "Preview",
                        style: TextStyle(fontSize: 14),
                      ),
                      onPressed: () async {
                        final url = doc.filePreviewUrl ?? '';
                        if (url.isEmpty) return;
                        final extension = url.split('.').last.toLowerCase();
                        if (extension == 'pdf') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfPreviewScreen(url: url),
                            ),
                          );
                        } else {
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text("Không thể mở file này")));
                          }
                        }
                      },
                    ),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(80, 36),
                      ),
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      label: const Text("Reject",
                          style: TextStyle(fontSize: 14, color: Colors.red)),
                      onPressed: () => _showRejectDialog(context, ref, doc),
                    ),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: const Size(80, 36),
                      ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text("Approve", style: TextStyle(fontSize: 14)),
                      onPressed: () async {
                        await ref.read(documentActionProvider).approve(doc.docId);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text("Approved")));
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, DocumentModel doc) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Document"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: "Nhập lý do từ chối..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(documentActionProvider)
                  .reject(doc.docId, doc.uploaderId, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} "
        "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
  }
}
