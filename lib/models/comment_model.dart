class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "commentId": commentId,
        "postId": postId,
        "userId": userId,
        "authorName": authorName,
        "content": content,
        "createdAt": createdAt.toIso8601String(),
      };

  factory Comment.fromJson(Map<dynamic, dynamic> json) {
    return Comment(
      commentId: json["commentId"],
      postId: json["postId"],
      userId: json["userId"],
      authorName: json["authorName"],
      content: json["content"],
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
