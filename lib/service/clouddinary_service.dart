import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  /// Preset documents
  final CloudinaryPublic documentsCloud =
      CloudinaryPublic('dzym4wxma', 'documents', cache: false);

  /// Preset avatar
  final CloudinaryPublic avatarCloud =
      CloudinaryPublic('dzym4wxma', 'study_management', cache: false);

  Future<String?> uploadDocument(File file) async {
    try {
      final response = await documentsCloud.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Raw, 
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Error (Document): $e");
      return null;
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      final response = await avatarCloud.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Error (Avatar): $e");
      return null;
    }
  }
}
