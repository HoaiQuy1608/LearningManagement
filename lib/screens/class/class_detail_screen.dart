import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/class_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/widgets/class/tabs/members_tab.dart';
import 'package:learningmanagement/widgets/class/tabs/exercises_tab.dart';
import 'package:learningmanagement/screens/Home_screens/student_screen.dart';

class ClassDetailScreen extends ConsumerStatefulWidget {
  final ClassModel classModel;
  const ClassDetailScreen({super.key, required this.classModel});

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentId = ref.watch(authProvider).userId;
    final isTeacher = widget.classModel.teacherId == currentId;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 140.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.blue.shade800,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const StudentNav()),
                    );
                  }
                },
              ),

              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: 56,
                  bottom: 50,
                  right: 16,
                ),
                centerTitle: false,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.classModel.className,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.classModel.subject,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade900, Colors.blue.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Transform.rotate(
                        angle: -0.2,
                        child: Icon(
                          Icons.school,
                          size: 160,
                          color: Colors.white.withAlpha(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Thông tin lớp'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SelectableText(
                              'Mã lớp: ${widget.classModel.classId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Mô tả: ${widget.classModel.description}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (isTeacher)
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
              ],

              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Bảng tin'),
                  Tab(text: 'Bài tập'),
                  Tab(text: 'Thành viên'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            const Center(child: Text('Chưa có bài đăng nào')),
            // Tab 1
            ExercisesTab(
              classId: widget.classModel.classId,
              isTeacher: isTeacher,
            ),
            // Tab 2
            MembersTab(
              classId: widget.classModel.classId,
              isTeacher: isTeacher,
            ),
          ],
        ),
      ),
    );
  }
}
