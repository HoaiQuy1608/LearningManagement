import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/providers/scheduler_provider.dart';
import 'package:learningmanagement/providers/deadline_countdown_provider.dart';

class StudentStatsScreen extends ConsumerWidget {
  const StudentStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy dữ liệu từ provider
    final scheduleMap = ref.watch(schedulerProvider);
    final deadlineMap = ref.watch(deadlineCountdownProvider);

    // 2. Tính toán số liệu
    final allEvents = scheduleMap.values.expand((list) => list).toList();

    double totalStudyHours = 0.0;
    for (var event in allEvents) {
      if (event.type == ScheduleType.lesson && event.endTime != null) {
        final duration = event.endTime!.difference(event.startTime);
        totalStudyHours += duration.inMinutes / 60.0;
      }
    }

    final totalDeadlines = deadlineMap.length;
    final completedDeadlines = deadlineMap.values
        .where((d) => d.isCompleted)
        .length;
    final double progress = totalDeadlines == 0
        ? 0.0
        : completedDeadlines / totalDeadlines;

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê học tập'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- THẺ TỔNG QUAN ---
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context: context, // SỬA: Thêm tên tham số
                    title: 'Tổng sự kiện',
                    value: '${allEvents.length}',
                    icon: Icons.event,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context: context, // SỬA: Thêm tên tham số
                    title: 'Giờ học',
                    value: '${totalStudyHours.toStringAsFixed(1)}h',
                    icon: Icons.timer,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- TIẾN ĐỘ DEADLINE ---
            Text(
              'Tiến độ Deadline',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Vòng tròn tiến độ
                  SizedBox(
                    height: 150,
                    width: 150,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress, // SỬA: Thêm "value:"
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          color: Colors.green,
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const Text(
                                'Hoàn thành',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Chi tiết số liệu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildLegendItem(
                        label: 'Đã xong',
                        value: '$completedDeadlines',
                        color: Colors.green,
                      ), // SỬA: Thêm tên tham số
                      _buildLegendItem(
                        label: 'Tổng số',
                        value: '$totalDeadlines',
                        color: Colors.grey,
                      ), // SỬA: Thêm tên tham số
                      _buildLegendItem(
                        label: 'Còn lại',
                        value: '${totalDeadlines - completedDeadlines}',
                        color: Colors.red,
                      ), // SỬA: Thêm tên tham số
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SỬA: Dùng tham số có tên (named parameters) để tránh nhầm lẫn
  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withAlpha(200)),
          ),
        ],
      ),
    );
  }

  // SỬA: Dùng tham số có tên (named parameters)
  Widget _buildLegendItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
