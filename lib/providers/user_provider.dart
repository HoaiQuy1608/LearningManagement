import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

final userProvider = StateNotifierProvider<UserNotifier, List<UserModel>>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<List<UserModel>> {
  UserNotifier() : super([]) {
    _listenUsers();
  }

  final _db = FirebaseDatabase.instance.ref("users");

  void _listenUsers() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null) {
        state = [];
        return;
      }

      final map = Map<String, dynamic>.from(data as Map);

      final users = map.entries.map((e) {
        return UserModel.fromMap(
          e.key, // uid
          Map<String, dynamic>.from(e.value),
        );
      }).toList();

      state = users;
    });
  }

  /// Kích hoạt / vô hiệu hóa user
  Future<void> toggleActive(String uid) async {
    final current = state.firstWhere((u) => u.uid == uid).isActive;
    await _db.child(uid).update({"isActive": !current});
  }

  /// Reset mật khẩu (demo)
  Future<void> resetPassword(String uid) async {
    await _db.child(uid).update({"password": "123456"});
  }

  /// Xóa user
  Future<void> deleteUser(String uid) async {
    await _db.child(uid).remove();
  }

  /// Đổi role
  Future<void> changeRole(String uid, UserRole role) async {
    await _db.child(uid).update({"role": role.name});
  }
}
