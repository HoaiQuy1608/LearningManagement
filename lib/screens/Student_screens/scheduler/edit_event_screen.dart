import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/scheduler_provider.dart';
import 'package:learningmanagement/models/schedule_model.dart';
import 'package:learningmanagement/providers/deadline_countdown_provider.dart';
import 'package:learningmanagement/widgets/schedules/datetime_selection_tile.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  final ScheduleModel event;
  const EditEventScreen({super.key, required this.event});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  late final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(text: widget.event.title);
  late final _notesController = TextEditingController(
    text: widget.event.description ?? '',
  );

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  TimeOfDay? _endTime;
  DateTime? _endDate;
  late String _selectedType;
  late String? _selectedReminder;
  late String _selectedColor;
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

  final Map<ScheduleType, String> _reverseTypeMap = {
    ScheduleType.lesson: 'Buổi học',
    ScheduleType.exam: 'Bài kiểm tra',
    ScheduleType.assignment: 'Bài tập',
    ScheduleType.deadline: 'Deadline',
  };

  bool _didFetchDeadline = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.event.startTime;
    _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
    _endDate = widget.event.endTime;
    _endTime = widget.event.endTime != null
        ? TimeOfDay.fromDateTime(widget.event.endTime!)
        : null;
    _selectedType = _reverseTypeMap[widget.event.type] ?? 'Buổi học';
    _selectedReminder = widget.event.reminder;
    _selectedColor = widget.event.color;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_didFetchDeadline) {
      final countdown = ref.read(deadlineCountdownProvider)[widget.event.id];
      _deadline = countdown?.deadline;
      _didFetchDeadline = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Cập nhật sự kiện'), centerTitle: true),
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
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
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
              // === GIỜ ===
              // === 1. BẮT ĐẦU ===
              DateTimeSelectionTile(
                title: 'Bắt đầu',
                icon: Icons.play_circle_outline,
                iconColor: Colors.green,
                date: _selectedDate,
                time: _startTime,
                onDateTimeSelected: (date, time) {
                  setState(() {
                    _selectedDate = date;
                    _startTime = time;
                    if (_endDate != null && _endTime != null) {
                      final start = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      final end = DateTime(
                        _endDate!.year,
                        _endDate!.month,
                        _endDate!.day,
                        _endTime!.hour,
                        _endTime!.minute,
                      );
                      if (end.isBefore(start)) {
                        _endDate = null;
                        _endTime = null;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã reset ngày kết thúc'),
                          ),
                        );
                      }
                    }
                  });
                },
              ),
              const Divider(height: 1),
              // === 2. KẾT THÚC ===
              DateTimeSelectionTile(
                title: 'Kết thúc',
                icon: Icons.stop_circle_outlined,
                iconColor: Colors.red,
                isOptional: true,
                date: _endDate,
                time: _endTime,
                onClear: () => setState(() {
                  _endDate = null;
                  _endTime = null;
                }),
                onDateTimeSelected: (date, time) {
                  setState(() {
                    _endDate = date;
                    _endTime = time;
                  });
                },
              ),
              const SizedBox(height: 16),
              // === DEADLINE ===
              if (_selectedType != 'Buổi học') ...[
                const Divider(height: 1),
                DateTimeSelectionTile(
                  title: 'Hạn chót (Deadline)',
                  icon: Icons.flag,
                  iconColor: Colors.red,
                  isOptional: false,
                  date: _deadline,
                  time: _deadline != null
                      ? TimeOfDay.fromDateTime(_deadline!)
                      : null,
                  onDateTimeSelected: (date, time) {
                    setState(() {
                      _deadline = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
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

              // === MÀU ===
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

              // === NÚT CẬP NHẬT ===
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

                      final updatedEvent = widget.event.copyWith(
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

                      // 1. CẬP NHẬT SỰ KIỆN
                      await ref
                          .read(schedulerProvider.notifier)
                          .editEvent(updatedEvent);

                      // 2. CẬP NHẬT DEADLINE COUNTDOWN
                      if (_selectedType != 'Buổi học') {
                        if (_deadline != null) {
                          final existing = ref.read(
                            deadlineCountdownProvider,
                          )[widget.event.id];
                          if (existing != null) {
                            // Cập nhật deadline
                            await ref
                                .read(deadlineCountdownProvider.notifier)
                                .createOrUpdate(widget.event.id, _deadline!);
                          } else {
                            // Tạo mới
                            await ref
                                .read(deadlineCountdownProvider.notifier)
                                .createOrUpdate(widget.event.id, _deadline!);
                          }
                        }
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context, updatedEvent);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cập nhật',
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
