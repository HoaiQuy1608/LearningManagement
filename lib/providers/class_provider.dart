import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:learningmanagement/models/class_model.dart';
import 'package:learningmanagement/models/class_member_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

class ClassState {
  final List<ClassModel> teachingClasses;
  final List<ClassModel> joinedClasses;
  final bool isLoading;

  const ClassState({
    this.teachingClasses = const [],
    this.joinedClasses = const [],
    this.isLoading = false,
  });
  ClassState copyWith({
    List<ClassModel>? teachingClasses,
    List<ClassModel>? joinedClasses,
    bool? isLoading,
  }) {
    return ClassState(
      teachingClasses: teachingClasses ?? this.teachingClasses,
      joinedClasses: joinedClasses ?? this.joinedClasses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ClassNotifier extends Notifier<ClassState> {
  final _db = FirebaseDatabase.instance.ref();
  String? _userId;

  @override
  ClassState build() {
    final userId = ref.watch(authProvider).userId;
    if (userId == null) return const ClassState();
    _userId = userId;
    _listenToClasses();
    return const ClassState();
  }

  void _listenToClasses() {
    if (_userId == null) return;
    _db.child('classes').onValue.listen((classEvent) {
      final classData = classEvent.snapshot.value;
      _db
          .child('classMembers')
          .orderByChild('userId')
          .equalTo(_userId)
          .onValue
          .listen((memberEvent) {
            final memberData =
                memberEvent.snapshot.value as Map<Object?, Object?>?;
            final Set<String> activeClassIds = {};
            if (memberData != null) {
              memberData.forEach((key, value) {
                final map = Map<String, dynamic>.from(value as Map);
                if (map['status'] == 'active') {
                  activeClassIds.add(map['classId']);
                }
              });
            }
            final List<ClassModel> teaching = [];
            final List<ClassModel> joined = [];
            if (classData != null) {
              void processItem(dynamic value) {
                try {
                  if (value == null) return;
                  final map = Map<String, dynamic>.from(value as Map);
                  final classModel = ClassModel.fromJson(map);
                  if (classModel.teacherId == _userId) {
                    teaching.add(classModel);
                  } else if (activeClassIds.contains(classModel.classId)) {
                    joined.add(classModel);
                  }
                } catch (e) {
                  print('Lỗi parse class: $e');
                }
              }

              if (classData is Map) {
                classData.forEach((key, value) => processItem(value));
              } else if (classData is List) {
                for (var value in classData) {
                  processItem(value);
                }
              }
            }
            teaching.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            joined.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            state = state.copyWith(
              teachingClasses: teaching,
              joinedClasses: joined,
            );
          });
    });
  }

  Future<String?> createClass({
    required String className,
    required String subject,
    required String description,
    required String visibility,
  }) async {
    if (_userId == null) return 'Chưa đăng nhập';
    state = state.copyWith(isLoading: true);
    try {
      final classId = const Uuid().v4();
      final now = DateTime.now();
      final newClass = ClassModel(
        classId: classId,
        teacherId: _userId!,
        className: className,
        subject: subject,
        description: description,
        visibility: visibility,
        createdAt: now,
      );
      String userName = 'Giảng viên';
      try {
        final snap = await _db.child('users/$_userId/displayName').get();
        if (snap.exists) userName = snap.value as String;
      } catch (_) {}
      final memberId = '${newClass.classId}_$_userId';
      final teacherMember = ClassMember(
        id: memberId,
        classId: classId,
        userId: _userId!,
        username: userName,
        roleInClass: 'teacher',
        status: 'active',
        joinedAt: now,
      );
      await _db.update({
        'classes/$classId': newClass.toJson(),
        'classMembers/$memberId': teacherMember.toJson(),
      });
      return null;
    } catch (e) {
      return 'Lỗi tạo lớp: $e';
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteClass(String classId) async {
    if (_userId == null) return;
    try {
      await _db.child('classes').child(classId).remove();
    } catch (e) {
      print('Lỗi xóa lớp: $e');
    }
  }
}

final classProvider = NotifierProvider<ClassNotifier, ClassState>(() {
  return ClassNotifier();
});

final allClassesProvider = StreamProvider.autoDispose<List<ClassModel>>((ref) {
  final dbRef = FirebaseDatabase.instance.ref('classes');

  return dbRef.onValue.map((event) {
    final data = event.snapshot.value;
    if (data == null) return [];

    final List<ClassModel> classes = [];

    void processItem(dynamic value) {
      try {
        if (value == null) return;
        final map = Map<String, dynamic>.from(value as Map);
        classes.add(ClassModel.fromJson(map));
      } catch (e) {
        print('Lỗi parse class: $e');
      }
    }

    if (data is Map) {
      data.forEach((key, value) => processItem(value));
    } else if (data is List) {
      for (var value in data) {
        processItem(value);
      }
    }
    classes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return classes;
  });
});

final myClassMembershipProvider =
    StreamProvider.autoDispose<Map<String, String>>((ref) {
      final userId = ref.watch(authProvider).userId;
      if (userId == null) return Stream.value({});

      final dbRef = FirebaseDatabase.instance.ref('classMembers');

      return dbRef.orderByChild('userId').equalTo(userId).onValue.map((event) {
        final data = event.snapshot.value as Map<Object?, Object?>?;
        if (data == null) return {};

        final Map<String, String> statusMap = {};

        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          statusMap[map['classId']] = map['status'];
        });
        return statusMap;
      });
    });
