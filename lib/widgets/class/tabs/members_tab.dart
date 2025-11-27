import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/class_member_provider.dart';
import 'package:learningmanagement/models/class_member_model.dart';

class MembersTab extends ConsumerWidget {
  final String classId;
  final bool isTeacher;
  const MembersTab({super.key, required this.classId, required this.isTeacher});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(classMemberProvider(classId));

    return memberAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (members) {
        if (members.isEmpty) {
          return const Center(child: Text('Chưa có thành viên nào.'));
        }
        final pendingMembers = members
            .where((m) => m.status == 'pending')
            .toList();
        final activeMembers = members
            .where((m) => m.status == 'active')
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- PHẦN 1: YÊU CẦU THAM GIA (Chỉ GV thấy) ---
            if (isTeacher && pendingMembers.isNotEmpty) ...[
              _buildHeader(
                'Yêu cầu tham gia (${pendingMembers.length})',
                Colors.orange,
              ),
              ...pendingMembers.map(
                (m) => _buildMemberItem(context, ref, m, true),
              ),
              const SizedBox(height: 20),
            ],

            // --- PHẦN 2: DANH SÁCH LỚP ---
            _buildHeader(
              'Danh sách lớp (${activeMembers.length})',
              Colors.blue,
            ),
            if (activeMembers.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Chưa có học viên chính thức.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...activeMembers.map(
                (m) => _buildMemberItem(context, ref, m, false),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(
    BuildContext context,
    WidgetRef ref,
    ClassMember member,
    bool isPending,
  ) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPending ? Colors.orange[100] : Colors.blue[100],
          child: Text(
            member.username.isNotEmpty ? member.username[0].toUpperCase() : '?',
            style: TextStyle(
              color: isPending ? Colors.orange[800] : Colors.blue[800],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isPending
              ? 'Chờ duyệt...'
              : (member.roleInClass == 'teacher' ? 'Giảng viên' : 'Học viên'),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),

        // Nút thao tác (Chỉ dành cho Giảng viên)
        trailing: isTeacher && member.roleInClass != 'teacher'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPending)
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      tooltip: 'Duyệt',
                      onPressed: () {
                        ref.read(classMemberAction).approveMember(member.id);
                      },
                    ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    tooltip: isPending ? 'Từ chối' : 'Xóa khỏi lớp',
                    onPressed: () {
                      _showDeleteConfirm(context, ref, member);
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    WidgetRef ref,
    ClassMember member,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn muốn mời ${member.username} ra khỏi lớp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(classMemberAction).removeMember(member.id);
            },
            child: const Text('Đồng ý', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
