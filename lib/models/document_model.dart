class DocumentModel {
  final String docId;
  final String uploaderId;
  final String? classId;
  final String title;
  final String description;
  final String subject;
  final List<String> tags;
  final String fileUrl;
  final String? coverImage;
  final String visibility; //Trạng thái của tài liệu upload//riêng tư //công khai // chỉ trong lớp
  final String status; // trạng thái phê duyệt
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
    required this.fileUrl,
    this.coverImage,
    required this.visibility,
    required this.status,
    required this.downloadCount,
    required this.createdAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        docId: json['docId'],
        uploaderId: json['uploaderId'],
        classId: json['classId'],
        title: json['title'],
        description: json['description'],
        subject: json['subject'],
        tags: List<String>.from(json['tags'] ?? []),
        fileUrl: json['fileUrl'],
        coverImage: json['coverImage'],
        visibility: json['visibility'],
        status: json['status'],
        downloadCount: json['downloadCount'] ?? 0,
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'docId': docId,
        'uploaderId': uploaderId,
        'classId': classId,
        'title': title,
        'description': description,
        'subject': subject,
        'tags': tags,
        'fileUrl': fileUrl,
        'coverImage': coverImage,
        'visibility': visibility,
        'status': status,
        'downloadCount': downloadCount,
        'createdAt': createdAt.toIso8601String(),
      };
}
