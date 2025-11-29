class Reply {
  final String replyId;
  final String commentId;
  final String userId;
  final String? avatarUrl;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final List<String> likes;

  Reply({
    required this.replyId,
    required this.commentId,
    required this.userId,
    this.avatarUrl,
    required this.authorName,
    required this.content,
    required this.createdAt,
    List<String>? likes,
  }) : likes = likes ?? [];

  Reply copyWith({
    String? replyId,
    String? commentId,
    String? userId,
    String? avatarUrl,
    String? authorName,
    String? content,
    DateTime? createdAt,
    List<String>? likes,
  }) {
    return Reply(
      replyId: replyId ?? this.replyId,
      commentId: commentId ?? this.commentId,
      userId: userId ?? this.userId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? List<String>.from(this.likes),
    );
  }

  Map<String, dynamic> toJson() => {
        "replyId": replyId,
        "commentId": commentId,
        "userId": userId,
        "avatarUrl": avatarUrl,
        "authorName": authorName,
        "content": content,
        "createdAt": createdAt.toIso8601String(),
        "likes": likes,
      };

  factory Reply.fromJson(Map<dynamic, dynamic> json) {
    return Reply(
      replyId: json["replyId"],
      commentId: json["commentId"],
      userId: json["userId"],
      avatarUrl: json["avatarUrl"],
      authorName: json["authorName"] ?? "Người dùng",
      content: json["content"],
      createdAt: DateTime.parse(json["createdAt"]),
      likes: (json["likes"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
