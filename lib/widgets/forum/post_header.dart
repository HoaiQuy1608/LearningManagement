import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import '../../models/forum_post_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class PostHeader extends ConsumerWidget {
  final ForumPost post;

  const PostHeader({required this.post, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(userProvider);

    // Tìm user tương ứng với userId của post
    final user = users.firstWhere(
      (u) => u.uid == post.userId,
      orElse: () => UserModel(
        uid: post.userId,
        displayName: "Người dùng",
        email: "",
        role: UserRole.sinhVien,
        createdAt: DateTime.now(),
        isActive: true,
        isEmailVerified: false,
      ),
    );

    return ListTile(
      leading: CircleAvatar(
        child: Text(user.displayName ?? ""),
      ),
      title: Text(user.displayName ?? ""),
      subtitle: Text(
        "${post.createdAt.toLocal()}".split(' ')[0],
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
