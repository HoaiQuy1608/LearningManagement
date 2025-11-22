import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

final profileProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.userId;

  if (userId == null) {
    return Stream.value(null);
  }
  final databaseRef = FirebaseDatabase.instance.ref('users/$userId');

  return databaseRef.onValue.map((event) {
    final data = event.snapshot.value;
    if (data == null) return null;
    return UserModel.fromMap(userId, Map<Object, Object>.from(data as Map));
  });
});
