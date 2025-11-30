import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../models/forum_post_model.dart';
import '../../screens/forum_screens/post_detail_screen.dart';

class ModeratorReportScreen extends ConsumerStatefulWidget {
  const ModeratorReportScreen({super.key});

  @override
  ConsumerState<ModeratorReportScreen> createState() => _ModeratorReportScreenState();
}

class _ModeratorReportScreenState extends ConsumerState<ModeratorReportScreen> {
  final _postsRef = FirebaseDatabase.instance.ref("posts");
  final _reportsRef = FirebaseDatabase.instance.ref("commentReports");

  Map<String, ForumPost> allPosts = {}; 
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _listenReports();
  }

  void _loadPosts() async {
    final snapshot = await _postsRef.get();
    final data = snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      final map = data.map((key, value) {
        final postMap = Map<String, dynamic>.from(value);
        return MapEntry(
          key.toString(),
          ForumPost(
            postId: key.toString(),
            userId: postMap['userId'] ?? '',
            title: postMap['title'] ?? '[Không có tiêu đề]',
            content: postMap['content'] ?? '',
            tags: List<String>.from(postMap['tags'] ?? []),
            createdAt: DateTime.tryParse(postMap['createdAt'] ?? '') ?? DateTime.now(),
          ),
        );
      });
      setState(() {
        allPosts = map;
      });
    }
  }

  void _listenReports() {
    _reportsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        final list = data.values.map((e) {
          final report = Map<String, dynamic>.from(e);
          return {
            "reportId": report['reportId'] ?? '',
            "postId": report['postId'] ?? '',
            "commentId": report['commentId'] ?? '',
            "reason": report['reason'] ?? '',
            "status": report['status'] ?? 'pending',
          };
        }).toList();

        setState(() {
          reports = list;
        });
      } else {
        setState(() {
          reports = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo cáo bình luận"),
      ),
      body: reports.isEmpty
          ? const Center(child: Text("Chưa có báo cáo nào"))
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final post = allPosts[report['postId']] ??
                    ForumPost(
                      postId: report['postId'],
                      userId: '',
                      title: '[Bài viết đã xóa]',
                      content: '',
                      tags: [],
                      createdAt: DateTime.now(),
                    );

                return ListTile(
                  title: Text("CommentID: ${report['commentId']}"),
                  subtitle: Text("Lý do: ${report['reason']}"),
                  trailing: Text(report['status']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(
                          post: post,
                          scrollToCommentId: report['commentId'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
