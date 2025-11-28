import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:learningmanagement/models/class_member_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/models/class_model.dart';

final classMemberProvider = StreamProvider.autoDispose
    .family<List<ClassMember>, String>((ref, classId) {
      final dbRef = FirebaseDatabase.instance.ref('classMembers');

      return dbRef.orderByChild('classId').equalTo(classId).onValue.map((
        event,
      ) {
        final data = event.snapshot.value as Map<Object?, Object?>?;
        if (data == null) return [];

        final List<ClassMember> members = [];
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          members.add(ClassMember.fromJson(map));
        });
        members.sort((a, b) {
          if (a.status == 'pending' && b.status != 'pending') return -1;
          if (a.status != 'pending' && b.status == 'pending') return 1;
          return a.username.compareTo(b.username);
        });
        return members;
      });
    });

final classMemberAction = Provider((ref) => ClassMemberAction(ref));

class ClassMemberAction {
  final Ref ref;
  final _db = FirebaseDatabase.instance.ref();

  ClassMemberAction(this.ref);

  Future<String?> joinClass(ClassModel classInfo) async {
    final user = ref.read(authProvider);
    if (user.userId == null) return 'Chưa đăng nhập';

    String userName = 'Sinh viên';
    try {
      final snapshot = await _db
          .child('users/${user.userId}/displayName')
          .get();
      if (snapshot.exists) {
        userName = snapshot.value as String;
      }
    } catch (_) {}

    final status = (classInfo.visibility == 'Public') ? 'active' : 'pending';

    final memberId = '${classInfo.classId}_${user.userId}';

    final member = ClassMember(
      id: memberId,
      classId: classInfo.classId,
      userId: user.userId!,
      username: userName,
      roleInClass: 'student',
      status: status,
      joinedAt: DateTime.now(),
    );

    await _db.child('classMembers').child(memberId).set(member.toJson());
    if (status == 'active') return null;
    return 'Đã gửi yêu cầu tham gia. Chờ giảng viên duyệt.';
  }

  Future<void> approveMember(String memmberId) async {
    await _db.child('classMembers').child(memmberId).update({
      'status': 'active',
    });
  }

  Future<void> removeMember(String memberId) async {
    await _db.child('classMembers').child(memberId).remove();
  }
}
