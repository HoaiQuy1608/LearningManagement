import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'upload_document_screen.dart';
import '/../providers/document_provider.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(documentProvider).isLoading;
    final documents = ref.watch(documentProvider).documents;
    return Stack(
      children: [
        ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final doc = documents[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: ListTile(
                leading: Icon(
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(doc.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.orange),
                        SizedBox(width: 4.0),
                        Text('${doc.rating} sao'),
                        SizedBox(width: 12.0),
                        Icon(Icons.download, size: 16, color: Colors.grey),
                        SizedBox(width: 4.0),
                        Text('${doc.downloads} lượt tải'),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14.0),
                onTap: () {
                  print('TODO: Mở tài liệu ${index + 1}');
                },
              ),
            );
          },
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadDocumentScreen(),
                ),
              );
            },
            child: const Icon(Icons.upload_file),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withAlpha(77),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
