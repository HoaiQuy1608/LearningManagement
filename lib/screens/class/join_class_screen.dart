import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/class_model.dart';
import 'package:learningmanagement/providers/class_provider.dart';
import 'package:learningmanagement/providers/class_member_provider.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/screens/class/class_detail_screen.dart';

class JoinClassScreen extends ConsumerStatefulWidget {
  const JoinClassScreen({super.key});

  @override
  ConsumerState<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends ConsumerState<JoinClassScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleJoinClass(ClassModel classItem) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final resultMessage = await ref
        .read(classMemberAction)
        .joinClass(classItem);
    if (!mounted) return;
    if (resultMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tham gia lớp thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ClassDetailScreen(classModel: classItem),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đã gửi yêu cầu'),
          content: Text(resultMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allClassesAsync = ref.watch(allClassesProvider);
    final membershipAsync = ref.watch(myClassMembershipProvider);
    final myId = ref.watch(authProvider).userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Tìm Lớp Học')),
      body: Column(
        children: [
          // Ô TÌM KIẾM
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập tên lớp hoặc môn học...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),

          // DANH SÁCH LỚP
          Expanded(
            child: allClassesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
              data: (allClasses) {
                final classesToShow = allClasses.where((c) {
                  final isNotMyClass = c.teacherId != myId;
                  final matchesSearch =
                      c.className.toLowerCase().contains(_searchQuery) ||
                      c.subject.toLowerCase().contains(_searchQuery);
                  return isNotMyClass && matchesSearch;
                }).toList();

                if (classesToShow.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy lớp học nào.'),
                  );
                }

                final myStatusMap = membershipAsync.value ?? {};

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: classesToShow.length,
                  itemBuilder: (context, index) {
                    final classItem = classesToShow[index];
                    final isPrivate = classItem.visibility == 'Private';

                    final myStatus = myStatusMap[classItem.classId];

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isPrivate
                                ? Colors.orange[50]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isPrivate ? Icons.lock : Icons.public,
                            color: isPrivate ? Colors.orange : Colors.blue,
                          ),
                        ),
                        title: Text(
                          classItem.className,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(classItem.subject),
                            const SizedBox(height: 4),
                            Text(
                              'GV ID: ...${classItem.teacherId.substring(classItem.teacherId.length - 4)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),

                        trailing: _buildActionButton(
                          context,
                          classItem,
                          myStatus,
                          isPrivate,
                        ),

                        onTap: myStatus == 'active'
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClassDetailScreen(
                                      classModel: classItem,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ClassModel classItem,
    String? status,
    bool isPrivate,
  ) {
    if (status == 'active') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.green.withOpacity(0.7),
          disabledForegroundColor: Colors.white,
        ),
        onPressed: null, // Disable nút
        icon: const Icon(Icons.check, size: 16),
        label: const Text('Đã tham gia'),
      );
    }

    if (status == 'pending') {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.grey[700],
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[700],
        ),
        onPressed: null,
        icon: const Icon(Icons.hourglass_empty, size: 16),
        label: const Text('Chờ duyệt'),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrivate ? Colors.orange : Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => _handleJoinClass(classItem),
      child: Text(isPrivate ? 'Xin vào' : 'Tham gia'),
    );
  }
}
