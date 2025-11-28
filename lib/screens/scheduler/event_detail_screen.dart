import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/widgets/schedules/countdown_timer.dart';
import 'package:learningmanagement/providers/scheduler_provider.dart';
import 'package:learningmanagement/providers/deadline_countdown_provider.dart';
import 'package:learningmanagement/screens/scheduler/edit_event_screen.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final ScheduleModel event;
  const EventDetailScreen({super.key, required this.event});
  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late ScheduleModel _currentEvent;

  static const Map<ScheduleType, String> _typeName = {
    ScheduleType.lesson: 'Buổi học',
    ScheduleType.exam: 'Bài kiểm tra',
    ScheduleType.assignment: 'Bài tập',
    ScheduleType.deadline: 'Deadline',
  };

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  Future<void> _navigateToEdit() async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditEventScreen(event: _currentEvent)),
    );
    if (updatedEvent != null && updatedEvent is ScheduleModel) {
      setState(() {
        _currentEvent = updatedEvent;
      });
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa sự kiện "${_currentEvent.title}" không?',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Đóng dialog
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final schedulerNotifier = ref.read(schedulerProvider.notifier);
              await schedulerNotifier.removeEvent(_currentEvent.id);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã xóa sự kiện'),
                  action: SnackBarAction(
                    label: 'Hoàn tác',
                    onPressed: () {
                      schedulerNotifier.undoRemove();
                    },
                  ),
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final countdown = ref.watch(
      deadlineCountdownProvider.select((map) => map[_currentEvent.id]),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentEvent.title),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _navigateToEdit, icon: Icon(Icons.edit)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(
                  int.parse(_currentEvent.color.replaceFirst('#', '0xFF')),
                ).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    color: Color(
                      int.parse(_currentEvent.color.replaceFirst('#', '0xFF')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _typeName[_currentEvent.type] ?? 'Sự kiện',
                    style: TextStyle(
                      color: Color(
                        int.parse(
                          _currentEvent.color.replaceFirst('#', '0xFF'),
                        ),
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // --- ĐỒNG HỒ ĐẾM NGƯỢC (NẾU LÀ DEADLINE) ---
            if (_currentEvent.type != ScheduleType.lesson &&
                countdown != null) ...[
              Text(
                'THỜI GIAN CÒN LẠI:',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CountdownTimer(deadline: countdown.deadline),

              if (!countdown.isCompleted)
                TextButton(
                  child: const Text('Đánh dấu là đã hoàn thành'),
                  onPressed: () {
                    ref
                        .read(deadlineCountdownProvider.notifier)
                        .markAsCompleted(_currentEvent.id);
                  },
                ),
              if (countdown.isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'ĐÃ HOÀN THÀNH',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Divider(height: 24),
            ],
            // --- THÔNG TIN CHI TIẾT ---
            _buildInfoRow(
              Icons.access_time,
              'Thời gian',
              '${_currentEvent.startTime.hour}:${_currentEvent.startTime.minute.toString().padLeft(2, '0')} ${_currentEvent.endTime != null ? '- ${_currentEvent.endTime!.hour}:${_currentEvent.endTime!.minute.toString().padLeft(2, '0')}' : ''}',
            ),
            if (_currentEvent.reminder != null &&
                _currentEvent.reminder != 'Không nhắc')
              _buildInfoRow(
                Icons.notifications_active_outlined,
                'Nhắc nhở',
                _currentEvent.reminder!,
              ),
            if (_currentEvent.description != null &&
                _currentEvent.description!.isNotEmpty)
              _buildInfoRow(
                Icons.notes_outlined,
                'Ghi chú',
                _currentEvent.description!,
              ),

            const Spacer(),
            // --- NÚT XÓA ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  'Xóa sự kiện',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _showDeleteConfirmation(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
