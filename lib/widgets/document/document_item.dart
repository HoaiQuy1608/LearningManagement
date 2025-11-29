import 'package:flutter/material.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import '../../models/document_model.dart';
import '../../screens/documents/pdf_preview_screen.dart';
import '../../widgets/document/download_document.dart';
import 'package:firebase_database/firebase_database.dart';

class DocumentItem extends StatelessWidget {
  final DocumentModel doc;
  final UserRole role;
  final VoidCallback onDelete;

  const DocumentItem({
    super.key,
    required this.doc,
    required this.role,
    required this.onDelete,
  });

  Future<Map<String, dynamic>?> _getUser() async {
    
    final ref = FirebaseDatabase.instance.ref("users/${doc.uploaderId}");
    final snapshot = await ref.get();
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        final avatarUrl = user?["avatarUrl"];
        final displayName = user?["displayName"] ?? "Không rõ người đăng";

        final avatar = avatarUrl == null || avatarUrl.isEmpty
            ? "https://ui-avatars.com/api/?name=${displayName}"
            : avatarUrl;

        final uploadedDate = doc.createdAt;


        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(avatar),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Ngày đăng: $uploadedDate",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  doc.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  doc.subject,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    Row(
                      children: [
                        DocumentDownloadButton(doc: doc),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfPreviewScreen(
                                  url: doc.filePreviewUrl,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text("Preview"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),

                    if (role == UserRole.kiemDuyet)
                      IconButton(
                        tooltip: "Xóa",
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: onDelete,
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
}
