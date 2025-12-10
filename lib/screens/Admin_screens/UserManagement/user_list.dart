import 'package:flutter/material.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:learningmanagement/widgets/user_management/user_list_item.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

class UserList extends StatelessWidget {
  final List<UserModel> users;
  final UserModel? selectedUser;
  final void Function(UserModel user) onTapUser;
  final void Function(String searchText, UserRole? role, bool? isActive) onFilterChanged;

  const UserList({
    super.key,
    required this.users,
    this.selectedUser,
    required this.onTapUser,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: users.isEmpty
              ? const Center(child: Text("Không có người dùng", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return UserListItem(
                      user: u,
                      selected: selectedUser != null && selectedUser!.uid == u.uid,
                      onTap: () => onTapUser(u),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
