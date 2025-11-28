import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/document_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/file_picker.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  ConsumerState<UploadDocumentScreen> createState() =>
      _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen> {
  File? selectedFile;

  final titleC = TextEditingController();
  final descC = TextEditingController();
  final subjectC = TextEditingController();

  String visibility = "public";

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(documentUploadProvider);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Upload Document")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final file = await FilePickerUtil.pickDocument();
          setState(() => selectedFile = file);
        },
        child: const Icon(Icons.attach_file),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: descC,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: subjectC,
              decoration: const InputDecoration(labelText: "Subject"),
            ),
            const SizedBox(height: 16),

            DropdownButton(
              value: visibility,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "public", child: Text("Public")),
                DropdownMenuItem(value: "private", child: Text("Private")),
                DropdownMenuItem(value: "onlyClass", child: Text("Only Class")),
              ],
              onChanged: (v) => setState(() => visibility = v!),
            ),

            const SizedBox(height: 20),

            // File area
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                selectedFile == null
                    ? "No file selected"
                    : selectedFile!.path.split("/").last,
              ),
            ),

            const SizedBox(height: 30),

            uploadState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text("Lỗi: $e"),
              data: (_) => ElevatedButton(
                onPressed: (auth.userId == null || selectedFile == null)
                    ? null
                    : () async {
                        await ref
                            .read(documentUploadProvider.notifier)
                            .uploadDocument(
                              file: selectedFile!,
                              title: titleC.text.trim(),
                              description: descC.text.trim(),
                              subject: subjectC.text.trim(),
                              visibility: visibility,
                            );

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Upload Successfully!")),
                        );
                        //Navigator.pop(context);
                      },
                child: const Text("Upload"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
