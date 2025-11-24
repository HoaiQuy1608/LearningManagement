import 'package:flutter/material.dart';

class AnswerOptionTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;

  const AnswerOptionTile({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isMultiSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? theme.primaryColor.withAlpha(30) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                isMultiSelect
                    ? (isSelected
                          ? Icons.check_box
                          : Icons.check_box_outline_blank)
                    : (isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked),
                color: isSelected ? theme.primaryColor : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? theme.primaryColor : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
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
