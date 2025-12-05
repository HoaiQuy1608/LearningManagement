import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/forum_post_model.dart';
import '../../providers/report_provider.dart';
import '../forum_screens/post_detail_screen.dart';

class ModeratorReportScreen extends ConsumerStatefulWidget {
  const ModeratorReportScreen({super.key});

  @override
  ConsumerState createState() => _ModeratorReportScreenState();
}

class _ModeratorReportScreenState extends ConsumerState<ModeratorReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController tab;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 2, vsync: this);
  }

  Color _statusBackground(String status) {
    switch (status) {
      case "pending":
        return Colors.amber.shade100;
      case "resolved":
        return Colors.green.shade100;
      case "rejected":
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
  Color _statusTextColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange.shade900;
      case "resolved":
        return Colors.green.shade900;
      case "rejected":
        return Colors.red.shade900;
      default:
        return Colors.grey.shade900;
    }
  }

  String _statusVN(String status) {
    switch (status) {
      case "pending":
        return "Chờ xử lý";
      case "resolved":
        return "Đã xử lý";
      case "rejected":
        return "Từ chối";
      default:
        return "Không xác định";
    }
  }

  Widget _statusChip(String status) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _statusBackground(status),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      _statusVN(status),
      style: TextStyle(
        color: _statusTextColor(status),
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider).value ?? {};
    final postReports = ref.watch(postReportProvider).value ?? [];
    final commentReports = ref.watch(commentReportProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý báo cáo"),
        bottom: TabBar(
          controller: tab,
          labelColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: "Comment Report"),
            Tab(text: "Post Report"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tab,
        children: [
          _buildCommentReports(commentReports, posts),
          _buildPostReports(postReports, posts),
        ],
      ),
    );
  }

  Widget _buildPostReports(
      List<Map<String, dynamic>> reports, Map<String, ForumPost> posts) {
    if (reports.isEmpty) {
      return const Center(child: Text("Không có báo cáo bài viết"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reports.length,
      itemBuilder: (_, i) {
        final r = reports[i];
        final post = posts[r["postId"]];
        final status = r["status"] ?? "pending";

        return _animatedCard(
          child: ListTile(
            title: Text(
              "Bài viết: ${post?.title ?? "[Đã xoá]"}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📌 Lý do: ${r["reason"]}"),
                  const SizedBox(height: 6),
                  _statusChip(status),
                ],
              ),
            ),
            onTap: post == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: post),
                      ),
                    ),
          ),
        );
      },
    );
  }

  Widget _buildCommentReports(
    List<Map<String, dynamic>> reports,
    Map<String, ForumPost> posts,
  ) {
    if (reports.isEmpty) {
      return const Center(child: Text("Không có báo cáo bình luận"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reports.length,
      itemBuilder: (_, i) {
        final r = reports[i];
        final post = posts[r["postId"]];
        final status = r["status"] ?? "pending";

        return Consumer(
          builder: (_, ref, __) {
            final asyncContent = ref.watch(
              commentContentProvider((r["postId"], r["commentId"])),
            );

            return asyncContent.when(
              loading: () => _animatedCard(
                child: const ListTile(
                  title: Text("Đang tải bình luận..."),
                ),
              ),
              error: (_, __) => _animatedCard(
                child: const ListTile(
                  title: Text("Không thể tải bình luận"),
                ),
              ),
              data: (content) => _animatedCard(
                child: ListTile(
                  title: Text(
                    "Thuộc bài viết: ${post?.title ?? "[Đã xoá]"}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("💬 Bình luận: $content"),
                        Text("📌 Lý do: ${r["reason"]}"),
                        const SizedBox(height: 6),
                        _statusChip(status),
                      ],
                    ),
                  ),
                  onTap: post == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailScreen(
                                post: post,
                                scrollToCommentId: r["commentId"],
                              ),
                            ),
                          );
                          Future.delayed(Duration.zero, () {
                            ref.read(updateReportStatusProvider).call(
                              reportId: r["reportId"],
                              type: "commentReports",
                              status: "resolved",
                            );
                          });
                        },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _animatedCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
