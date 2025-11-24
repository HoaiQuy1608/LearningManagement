class Comment {
  final String commentId;
  final String postId;
  final String userId;
  final String? avatarUrl;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final List<String> likes; // danh sách userId đã like

  Comment({
    required this.commentId,
    required this.postId,
    required this.userId,
    this.avatarUrl,
    required this.authorName,
    required this.content,
    required this.createdAt,
    List<String>? likes,
  }) : likes = likes ?? [];

  Comment copyWith({
    String? commentId,
    String? postId,
    String? userId,
    String? avatarUrl,
    String? authorName,
    String? content,
    DateTime? createdAt,
    List<String>? likes,
  }) {
    return Comment(
      commentId: commentId ?? this.commentId,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? List<String>.from(this.likes),
    );
  }

  int get likeCount => likes.length;

  Map<String, dynamic> toJson() => {
        "commentId": commentId,
        "postId": postId,
        "userId": userId,
        "authorName": authorName,
        "avatarUrl" : avatarUrl,
        "content": content,
        "createdAt": createdAt.toIso8601String(),
        "likes": likes,
      };

  factory Comment.fromJson(Map<dynamic, dynamic> json) {
    return Comment(
      commentId: json["commentId"],
      postId: json["postId"],
      userId: json["userId"],
      authorName: json["authorName"] ?? "Người dùng",
      avatarUrl: json["avatarUrl"],
      content: json["content"],
      createdAt: DateTime.parse(json["createdAt"]),
      likes: (json["likes"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
