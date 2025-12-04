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
      itemCount: reports.length,
      itemBuilder: (_, i) {
        final r = reports[i];
        final post = posts[r["postId"]];

        return Card(
          child: ListTile(
            title: Text(post?.title ?? "[Bài viết không tồn tại]"),
            subtitle: Text("Lý do: ${r["reason"]}"),
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
      List<Map<String, dynamic>> reports, Map<String, ForumPost> posts) {
    if (reports.isEmpty) {
      return const Center(child: Text("Không có báo cáo bình luận"));
    }

    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (_, i) {
        final r = reports[i];
        final post = posts[r["postId"]];

        return Card(
          child: ListTile(
            title: Text(post?.title ?? "[Bài viết không tồn tại]"),
            subtitle: Text("Comment ID: ${r["commentId"]}\nLý do: ${r["reason"]}"),
            onTap: post == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(
                          post: post,
                          scrollToCommentId: r["commentId"],
                        ),
                      ),
                    ),
          ),
        );
      },
    );
  }
}
