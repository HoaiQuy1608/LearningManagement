import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:learningmanagement/service/clouddinary_service.dart';
import '../models/document_model.dart';
import 'auth_provider.dart';

final cloudinaryProvider = Provider<CloudinaryService>((ref) => CloudinaryService());

final documentUploadProvider =
    StateNotifierProvider<DocumentUploadController, AsyncValue<void>>((ref) {
  return DocumentUploadController(ref);
});

class DocumentUploadController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  DocumentUploadController(this.ref) : super(const AsyncValue.data(null));

  final dbRef = FirebaseDatabase.instance.ref("documents");

  Future<void> uploadDocument({
    required File file,
    required String title,
    required String description,
    required String subject,
    List<String> tags = const [],
    String visibility = "public",
  }) async {
    state = const AsyncValue.loading();

    try {
      final authState = ref.read(authProvider);
      final userId = authState.userId;
      final role = authState.userRole;

      if (userId == null) throw "Vui lòng đăng nhập để upload.";

      final cloudinary = ref.read(cloudinaryProvider);

      // Upload tài liệu vào preset documents
      final fileUrl = await cloudinary.uploadDocument(file);
      if (fileUrl == null) throw "Lỗi upload file.";

      // Dùng chính file PDF/Word làm preview
      final filePreviewUrl = fileUrl;

      final status = (role == 'teacher' || role == 'admin') ? 'approved' : 'pending';

      final newDocRef = dbRef.push();
      final docId = newDocRef.key!;

      final document = DocumentModel(
        docId: docId,
        uploaderId: userId,
        title: title,
        description: description,
        subject: subject,
        tags: tags,
        fileOriginalUrl: fileUrl,
        filePreviewUrl: filePreviewUrl,
        visibility: visibility,
        status: status,
        downloadCount: 0,
        createdAt: DateTime.now(),
      );

      await newDocRef.set({
        ...document.toJson(),
        "createdAt": ServerValue.timestamp,
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
