import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:learningmanagement/models/class_model.dart';
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

    _db.child('classes').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null) {
        state = state.copyWith(teachingClasses: [], joinedClasses: []);
        return;
      }

      final List<ClassModel> teaching = [];
      final List<ClassModel> joined = [];

      void processItem(dynamic value) {
        try {
          if (value == null) return;
          final map = Map<String, dynamic>.from(value as Map);
          final classModel = ClassModel.fromJson(map);

          if (classModel.teacherId == _userId) {
            teaching.add(classModel);
          } else {
            // joined.add(classModel);
          }
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
      teaching.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(teachingClasses: teaching);
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
      final newClass = ClassModel(
        classId: classId,
        teacherId: _userId!,
        className: className,
        subject: subject,
        description: description,
        visibility: visibility,
        createdAt: DateTime.now(),
      );
      await _db.child('classes').child(classId).set(newClass.toJson());
      //(Optional) Tự add mình vào làm thành viên (role: teacher) trong bảng members
      // Để sau này dễ query danh sách lớp mình tham gia
      // await _db.child('class_members').child(classId).child(_userId!).set(...)
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
