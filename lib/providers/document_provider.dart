import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Documents {
  final String title;
  final String description;
  final String subject;
  final String accessLevel;
  final String author;
  final double rating;
  final int downloads;
  final String? coverImageName;

  const Documents({
    required this.title,
    required this.description,
    required this.subject,
    required this.accessLevel,
    required this.author,
    required this.rating,
    required this.downloads,
    this.coverImageName,
  });
}

@immutable
class DocumentState {
  final List<Documents> documents;
  final bool isLoading;

  const DocumentState({this.documents = const [], this.isLoading = false});

  DocumentState copyWith({List<Documents>? documents, bool? isLoading}) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DocumentProvider extends Notifier<DocumentState> {
  @override
  DocumentState build() {
    return const DocumentState(
      documents: [
        Documents(
          title: 'Bài giảng Flutter',
          author: 'GV. A',
          rating: 4.5,
          downloads: 150,
          description: '...',
          subject: 'Flutter',
          accessLevel: 'Public',
        ),
        Documents(
          title: 'Giáo trình Kinh tế chính trị',
          author: 'GV. B',
          rating: 4.8,
          downloads: 500,
          description: '...',
          subject: 'Kinh tế chính trị',
          accessLevel: 'Class',
        ),
      ],
    );
  }

  Future<void> uploadDocument({
    required String title,
    required String description,
    required String subject,
    required String accessLevel,
    required String author,
    required double rating,
    required int downloads,
    required String fileName,
    String? coverImageName,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 2));
    final newDocument = Documents(
      title: title,
      description: description,
      subject: subject,
      accessLevel: accessLevel,
      author: author,
      rating: rating,
      downloads: downloads,
      coverImageName: coverImageName,
    );
    state = state.copyWith(
      isLoading: false,
      documents: [...state.documents, newDocument],
    );
  }
}

final documentProvider = NotifierProvider<DocumentProvider, DocumentState>(() {
  return DocumentProvider();
});
