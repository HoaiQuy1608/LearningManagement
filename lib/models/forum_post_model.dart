class ForumPost {
  final String postId;
  final String userId;
  final String? classId;
  final String title;
  final String content;
  final List<String> tags;
  final bool isPinned;
  final bool isLocked;
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
        'createdAt': createdAt.toIso8601String(),
      };
}
