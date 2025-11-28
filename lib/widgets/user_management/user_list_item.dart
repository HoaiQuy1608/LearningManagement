import 'package:flutter/material.dart';
import 'package:learningmanagement/models/user_model.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final bool selected;
  final VoidCallback? onTap;

  const UserListItem({
    super.key,
    required this.user,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String name = user.displayName ?? "Chưa có tên";
    final String email = user.email;
    final bool active = user.isActive;
    final String roleName = user.role.name;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? Colors.blue.shade50 : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              backgroundColor: Colors.blue.shade100,
              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(email, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(roleName, style: const TextStyle(fontSize: 12)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: active ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    active ? "Hoạt động" : "Vô hiệu hóa",
                    style: TextStyle(color: active ? Colors.green : Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
