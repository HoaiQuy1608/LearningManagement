import 'package:flutter/material.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

class SearchFilterBar extends StatefulWidget {
  final void Function(String searchText, UserRole? role, bool? isActive) onFilterChanged;
  const SearchFilterBar({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  String _searchText = "";
  UserRole? _selectedRole;
  bool? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Tìm theo tên hoặc email...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => _searchText = value.trim());
                _applyFilter();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<UserRole?>(
              decoration: InputDecoration(
                labelText: "Vai trò",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              value: _selectedRole,
              items: [
                const DropdownMenuItem(value: null, child: Text("Tất cả")),
                ...UserRole.values.map(
                  (role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedRole = value);
                _applyFilter();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<bool?>(
              decoration: InputDecoration(
                labelText: "Trạng thái",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: null, child: Text("Tất cả")),
                DropdownMenuItem(value: true, child: Text("Hoạt động")),
                DropdownMenuItem(value: false, child: Text("Vô hiệu hóa")),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
                _applyFilter();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter() {
    widget.onFilterChanged(_searchText, _selectedRole, _selectedStatus);
  }
}
