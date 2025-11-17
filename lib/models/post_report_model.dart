class PostReport {
  final String reportId;
  final String postId;
  final String reporterId;
  final String reason;
  final String status; // pending, resolved, rejected
  final DateTime createdAt;

  PostReport({
    required this.reportId,
    required this.postId,
    required this.reporterId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory PostReport.fromJson(Map<String, dynamic> json) => PostReport(
        reportId: json['reportId'],
        postId: json['postId'],
        reporterId: json['reporterId'],
        reason: json['reason'],
        status: json['status'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'postId': postId,
        'reporterId': reporterId,
        'reason': reason,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };
}
