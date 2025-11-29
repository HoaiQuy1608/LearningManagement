import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/document_model.dart';

class DocumentDownloadButton extends StatefulWidget {
  final DocumentModel doc;

  const DocumentDownloadButton({
    super.key,
    required this.doc,
  });

  @override
  State<DocumentDownloadButton> createState() => _DocumentDownloadButtonState();
}

class _DocumentDownloadButtonState extends State<DocumentDownloadButton> {
  late int downloadCount;

  @override
  void initState() {
    super.initState();
    downloadCount = widget.doc.downloadCount ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _downloadDocument(context),
        ),
        Text(
          "$downloadCount",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _downloadDocument(BuildContext context) async {
    final url = widget.doc.fileOriginalUrl;
    final dbRef =
        FirebaseDatabase.instance.ref("documents").child(widget.doc.docId);

    // Tăng downloadCount trong DB
    final countSnap = await dbRef.child("downloadCount").get();
    int count = (countSnap.value ?? 0) as int;

    await dbRef.child("downloadCount").set(count + 1);

    // Cập nhật lại UI
    setState(() {
      downloadCount = count + 1;
    });

    // Mở link
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint("Download error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không mở được file")),
        );
      }
    }
  }
}
