import 'package:flutter/material.dart';

class DateTimeSelectionTile extends StatelessWidget {
  final String title;
  final DateTime? date;
  final TimeOfDay? time;
  final IconData icon;
  final Color iconColor;
  final bool isOptional;
  final VoidCallback? onClear;
  final Function(DateTime date, TimeOfDay time) onDateTimeSelected;

  const DateTimeSelectionTile({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.onDateTimeSelected,
    this.isOptional = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = date != null && time != null;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        hasValue
            ? '${date!.day}/${date!.month}/${date!.year} lúc ${time!.format(context)}'
            : (isOptional ? 'Chạm để chọn (Tùy chọn)' : 'Chưa chọn'),
        style: TextStyle(
          fontSize: 16,
          fontWeight: hasValue ? FontWeight.bold : FontWeight.normal,
          color: hasValue ? Colors.black : Colors.grey,
        ),
      ),
      trailing: (isOptional && hasValue)
          ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: onClear,
            )
          : const Icon(Icons.calendar_month, color: Colors.blue),
      onTap: () async {
        // 1. Chọn Ngày
        final initialDate = date ?? DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime(2030),
        );

        if (pickedDate == null) return;
        if (!context.mounted) return;

        // 2. Chọn Giờ
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );

        if (pickedTime != null) {
          // Trả về cả 2 giá trị
          onDateTimeSelected(pickedDate, pickedTime);
        }
      },
    );
  }
}
