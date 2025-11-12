import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withAlpha(50),
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text('SinhVienA', style: Theme.of(context).textTheme.headlineSmall),
            Text(
              'test@gmail.com',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Chỉnh sửa thông tin cá nhân'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            print('TODO: Mở màn hình Edit Profile');
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
          title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          onTap: () {
            ref.read(authProvider.notifier).logout();
          },
        ),
      ],
    );
  }
}
