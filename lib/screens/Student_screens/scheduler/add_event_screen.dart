import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/scheduler_provider.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:uuid/uuid.dart';
import 'package:learningmanagement/providers/deadline_countdown_provider.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay? _endTime;
  String _selectedType = 'Buổi học';
  String? _selectedReminder;
  String _selectedColor = '#FF6B6B';
  DateTime? _deadline;

  final _types = ['Buổi học', 'Bài kiểm tra', 'Bài tập', 'Deadline'];
  final _reminders = [
    'Không nhắc',
    'Trước 1 phút',
    'Trước 5 phút',
    'Trước 1 giờ',
    'Trước 1 ngày',
  ];
  final _colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57'];

  final Map<String, ScheduleType> _typeMap = {
    'Buổi học': ScheduleType.lesson,
    'Bài kiểm tra': ScheduleType.exam,
    'Bài tập': ScheduleType.assignment,
    'Deadline': ScheduleType.deadline,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm sự kiện'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // === TIÊU ĐỀ ===
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),

              // === LOẠI SỰ KIỆN ===
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Loại sự kiện',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),

              // === NGÀY ===
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 8),

              // === GIỜ BẮT ĐẦU / KẾT THÚC ===
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text('Bắt đầu: ${_startTime.format(context)}'),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (time != null) setState(() => _startTime = time);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        _endTime != null
                            ? 'Kết thúc: ${_endTime!.format(context)}'
                            : 'Kết thúc (tùy chọn)',
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _startTime,
                        );
                        if (time != null) setState(() => _endTime = time);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // === DEADLINE (chỉ hiện khi không phải Buổi học) ===
              if (_selectedType != 'Buổi học')
                Column(
                  children: [
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.flag, color: Colors.red),
                      title: Text(
                        _deadline == null
                            ? 'Chọn deadline'
                            : 'Deadline: ${_deadline!.day}/${_deadline!.month} ${_deadline!.hour}:${_deadline!.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030),
                        );
                        if (date == null) return;
                        if (!context.mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() {
                            _deadline = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // === NHẮC NHỞ ===
              DropdownButtonFormField<String>(
                initialValue: _selectedReminder,
                decoration: InputDecoration(
                  labelText: 'Nhắc nhở',
                  prefixIcon: const Icon(Icons.notifications),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _reminders
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedReminder = v),
              ),
              const SizedBox(height: 16),

              // === GHI CHÚ ===
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // === CHỌN MÀU ===
              const Text(
                'Chọn màu:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _colors.map((c) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == c
                              ? Colors.black
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // === NÚT LƯU ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final start = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _startTime.hour,
                        _startTime.minute,
                      );
                      final end = _endTime != null
                          ? DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              _endTime!.hour,
                              _endTime!.minute,
                            )
                          : null;

                      final eventType =
                          _typeMap[_selectedType] ?? ScheduleType.lesson;

                      final event = ScheduleModel(
                        id: const Uuid().v4(),
                        title: _titleController.text,
                        description: _notesController.text.isEmpty
                            ? null
                            : _notesController.text,
                        startTime: start,
                        endTime: end,
                        color: _selectedColor,
                        type: eventType,
                        reminder: _selectedReminder,
                        deadline: _deadline,
                      );

                      // 1. LƯU SỰ KIỆN
                      await ref
                          .read(schedulerProvider.notifier)
                          .addEvent(event);

                      // 2. TẠO DEADLINE COUNTDOWN (nếu có)
                      if (_deadline != null && _selectedType != 'Buổi học') {
                        await ref
                            .read(deadlineCountdownProvider.notifier)
                            .createOrUpdate(event.id, _deadline!);
                      }
                      if (!context.mounted) return;
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lưu sự kiện',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
