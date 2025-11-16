import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/providers/scheduler_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  final ScheduleModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(
                  int.parse(event.color.replaceFirst('#', '0xFF')),
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    color: Color(
                      int.parse(event.color.replaceFirst('#', '0xFF')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    event.type,
                    style: TextStyle(
                      color: Color(
                        int.parse(event.color.replaceFirst('#', '0xFF')),
                      ),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.access_time,
              'Thời gian',
              '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} ${event.endTime != null ? '- ${event.endTime!.hour}:${event.endTime!.minute.toString().padLeft(2, '0')}' : ''}',
            ),
            if (event.reminder != null && event.reminder != 'Không nhắc')
              _buildInfoRow(Icons.notifications, 'Nhắc nhở', event.reminder!),
            if (event.description != null)
              _buildInfoRow(Icons.note, 'Ghi chú', event.description!),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text('Xóa sự kiện'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  ref
                      .read(schedulerProvider.notifier)
                      .removeEvent(event.id, context);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
