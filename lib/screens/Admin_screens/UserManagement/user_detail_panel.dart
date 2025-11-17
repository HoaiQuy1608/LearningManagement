import 'package:flutter/material.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

class UserDetailPanel extends StatefulWidget {
  final UserModel user;
  final void Function(UserRole newRole) onChangeRole;
  final VoidCallback onToggleActive; // parent will wrap uid -> call provider
  final VoidCallback onResetPassword;
  final VoidCallback onDeleteUser;

  const UserDetailPanel({
    super.key,
    required this.user,
    required this.onChangeRole,
    required this.onToggleActive,
    required this.onResetPassword,
    required this.onDeleteUser,
  });

  @override
  State<UserDetailPanel> createState() => _UserDetailPanelState();
}

class _UserDetailPanelState extends State<UserDetailPanel> {
  late UserRole _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void didUpdateWidget(covariant UserDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.uid != widget.user.uid) {
      _selectedRole = widget.user.role;
      _isActive = widget.user.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + name + email
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage:
                      user.avatarUrl != null && user.avatarUrl!.isNotEmpty ? NetworkImage(user.avatarUrl!) : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty ? const Icon(Icons.person, size: 32) : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName ?? "Không có tên",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(user.email),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Change role
            const Text("Vai trò", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              items: UserRole.values
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedRole = value);
                widget.onChangeRole(value);
              },
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), isDense: true),
            ),

            const SizedBox(height: 18),

            // Active toggle + actions
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: Text(_isActive ? "Hoạt động" : "Vô hiệu hóa"),
                    value: _isActive,
                    onChanged: (val) {
                      setState(() => _isActive = val);
                      widget.onToggleActive();
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onResetPassword,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset pass"),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await _confirmDelete(context);
                    if (ok == true) widget.onDeleteUser();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Xóa user"),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Personal info
            const Text("Thông tin cá nhân", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _infoRow("Số điện thoại", user.phoneNumber),
            _infoRow("MSSV", user.studentId),
            _infoRow("Khoa / Bộ môn", user.department),
            _infoRow("Email xác thực", user.isEmailVerified ? "Đã xác thực" : "Chưa xác thực"),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            const Text("Lịch sử hoạt động", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _infoRow("Ngày tạo", user.createdAt.toLocal().toString()),
            _infoRow("Lần đăng nhập cuối", user.lastLoginAt?.toLocal().toString() ?? "Chưa có"),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value ?? "-", style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa tài khoản này? Hành động không thể hoàn tác."),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
