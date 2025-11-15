import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/scheduler_provider.dart';
import 'package:learningmanagement/models/schedule_model.dart';

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
  late TimeOfDay? _endTime;
  late String _selectedType;
  late String? _selectedReminder;
  late String _selectedColor;

  final _types = ['Buổi học', 'Bài kiểm tra', 'Bài tập', 'Deadline'];
  final _reminders = [
    'Không nhắc',
    'Trước 5 phút',
    'Trước 1 giờ',
    'Trước 1 ngày',
  ];
  final _colors = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FECA57'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.event.startTime;
    _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
    _endTime = widget.event.endTime != null
        ? TimeOfDay.fromDateTime(widget.event.endTime!)
        : null;
    _selectedType = widget.event.type;
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
                initialValue:
                    _selectedType, // ← DÙNG value, KHÔNG DÙNG initialValue
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
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
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

              // === NHẮC NHỞ ===
              DropdownButtonFormField<String>(
                initialValue: _selectedReminder, // ← DÙNG value
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

              // === NÚT CẬP NHẬT ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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

                      final updatedEvent = widget.event.copyWith(
                        title: _titleController.text,
                        description: _notesController.text.isEmpty
                            ? null
                            : _notesController.text,
                        startTime: start,
                        endTime: end,
                        color: _selectedColor,
                        type: _selectedType,
                        reminder: _selectedReminder,
                      );

                      // GỌI editEvent → UI + DB cập nhật ngay
                      ref
                          .read(schedulerProvider.notifier)
                          .editEvent(updatedEvent);
                      Navigator.pop(context);
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
