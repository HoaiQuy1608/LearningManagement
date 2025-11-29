class DocumentModel {
  final String docId;
  final String uploaderId;
  final String? classId;
  final String title;
  final String description;
  final String subject;
  final List<String> tags;
  final String fileOriginalUrl; // link gốc
  final String filePreviewUrl;  // link PDF để preview
  final String visibility;
  final String status;
  final int downloadCount;
  final DateTime createdAt;

  DocumentModel({
    required this.docId,
    required this.uploaderId,
    this.classId,
    required this.title,
    required this.description,
    required this.subject,
    required this.tags,
    required this.fileOriginalUrl,
    required this.filePreviewUrl,
    required this.visibility,
    required this.status,
    required this.downloadCount,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
  final createdAtRaw = json['createdAt'];
  DateTime created;

  if (createdAtRaw == null) {
    created = DateTime.now(); // fallback
  } else if (createdAtRaw is int) {
    created = DateTime.fromMillisecondsSinceEpoch(createdAtRaw);
  } else if (createdAtRaw is String) {
    created = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
  } else {
    created = DateTime.now();
  }

  return DocumentModel(
    docId: json['docId'] ?? '',
    uploaderId: json['uploaderId'] ?? '',
    classId: json['classId'],
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    subject: json['subject'] ?? '',
    tags: List<String>.from(json['tags'] ?? []),
    fileOriginalUrl: json['fileOriginalUrl'] ?? '',
    filePreviewUrl: json['filePreviewUrl'] ?? '',
    visibility: json['visibility'] ?? 'public',
    status: json['status'] ?? 'pending',
    downloadCount: json['downloadCount'] ?? 0,
    createdAt: created,
  );
}


    Map<String, dynamic> toJson() => {
      'docId': docId,
      'uploaderId': uploaderId,
      'classId': classId,
      'title': title,
      'description': description,
      'subject': subject,
      'tags': tags,
      'fileOriginalUrl': fileOriginalUrl,
      'filePreviewUrl': filePreviewUrl,
      'visibility': visibility,
      'status': status,
      'downloadCount': downloadCount,
      'createdAt': createdAt.millisecondsSinceEpoch, 
    };
}
