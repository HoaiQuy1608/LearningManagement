class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        commentId: json['commentId'],
        postId: json['postId'],
        userId: json['userId'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'commentId': commentId,
        'postId': postId,
        'userId': userId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };
}
