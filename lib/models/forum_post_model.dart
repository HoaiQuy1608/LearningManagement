class ForumPost {
  final String postId;
  final String userId;
  final String? classId;
  final String title;
  final String content;
  final List<String> tags;
  final bool isPinned;
  final bool isLocked;
  final bool isDeleted;
  final String? deletedBy;
  final String? deleteReason;
  final DateTime? deletedAt;

  final DateTime createdAt;

  ForumPost({
    required this.postId,
    required this.userId,
    this.classId,
    required this.title,
    required this.content,
    required this.tags,
    this.isPinned = false,
    this.isLocked = false,
    this.isDeleted = false,
    this.deletedBy,
    this.deleteReason,
    this.deletedAt,
    required this.createdAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) => ForumPost(
        postId: json['postId'],
        userId: json['userId'],
        classId: json['classId'],
        title: json['title'],
        content: json['content'],
        tags: List<String>.from(json['tags'] ?? []),
        isPinned: json['isPinned'] ?? false,
        isLocked: json['isLocked'] ?? false,
        isDeleted: json['isDeleted'] ?? false,
        deletedBy: json['deletedBy'],
        deleteReason: json['deleteReason'],
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'userId': userId,
        'classId': classId,
        'title': title,
        'content': content,
        'tags': tags,
        'isPinned': isPinned,
        'isLocked': isLocked,
        'isDeleted': isDeleted,
        'deletedBy': deletedBy,
        'deleteReason': deleteReason,
        'deletedAt': deletedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  ForumPost copyWith({
    String? postId,
    String? userId,
    String? classId,
    String? title,
    String? content,
    List<String>? tags,
    bool? isPinned,
    bool? isLocked,
    bool? isDeleted,
    String? deletedBy,
    String? deleteReason,
    DateTime? deletedAt,
    DateTime? createdAt,
  }) {
    return ForumPost(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      classId: classId ?? this.classId,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedBy: deletedBy ?? this.deletedBy,
      deleteReason: deleteReason ?? this.deleteReason,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
