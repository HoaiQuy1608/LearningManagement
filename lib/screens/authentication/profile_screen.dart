import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/providers/profile_provider.dart';
import 'package:learningmanagement/screens/authentication/edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (user) {
        if (user == null) return const Center(child: Text('Chưa đăng nhập'));
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Column(
              children: [
                CircleAvatar(
                  
                  radius: 50,
                  backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.email,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Chỉnh sửa thông tin cá nhân'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(user: user),
                  ),
                );
                if (result == true) {
                  ref.refresh(profileProvider);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Đổi mật khẩu'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                print('TODO: Mở màn hình Change Password');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Cài đặt'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                print('TODO: Mở màn hình Settings');
              },
            ),

            const Divider(),

            // 8. NÚT ĐĂNG XUẤT
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                _showLogoutConfirmation(context, ref);
              },
            ),
          ],
        );
      },
    );
  }
}
