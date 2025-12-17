import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'package:learningmanagement/models/quiz_model.dart';
import 'package:learningmanagement/models/question_model.dart';
import 'package:learningmanagement/providers/auth_provider.dart';

@immutable
class QuizState {
  final List<Quiz> quizzes;
  final bool isLoading;

  const QuizState({this.quizzes = const [], this.isLoading = false});

  QuizState copyWith({List<Quiz>? quizzes, bool? isLoading}) {
    return QuizState(
      quizzes: quizzes ?? this.quizzes,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class QuizNotifier extends Notifier<QuizState> {
  final _db = FirebaseDatabase.instance.ref();
  String? _userId;
  @override
  QuizState build() {
    final userId = ref.watch(authProvider).userId;

    if (userId == null) {
      return const QuizState();
    }

    _userId = userId;
    _listenToQuizzes();
    return const QuizState();
  }

  void _listenToQuizzes() {
    if (_userId == null) return;
    _db.child('quizzes').onValue.listen((event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data == null) {
        state = state.copyWith(quizzes: []);
        return;
      }
      final List<Quiz> loadedQuizzes = [];
      data.forEach((key, value) {
        if (value is! Map<Object?, Object?>) return;
        try {
          final quizMap = Map<String, dynamic>.from(value);
          final quiz = Quiz.fromJson(quizMap);

          if (quiz.creatorId == _userId ||
              quiz.status == 'approved' ||
              (quiz.classId != null && quiz.classId!.isNotEmpty)) {
            loadedQuizzes.add(quiz);
          }
        } catch (e) {
          print('Lỗi khi phân tích quiz: $e');
        }
      });
      loadedQuizzes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = state.copyWith(quizzes: loadedQuizzes);
    });
  }

  Future<String?> createQuiz({
    required String title,
    required String description,
    required String subject,
    required String visibility,
    required int timeLimit,
    required int maxAttempt,
    required bool allowRetake,
    required bool randomQuestions,
    required bool randomAnswers,
    required bool showAnswer,
    required List<Question> questions,
  }) async {
    final currentUserId = ref.read(authProvider).userId;
    if (currentUserId == null) return 'Người dùng chưa đăng nhập';
    state = state.copyWith(isLoading: true);
    try {
      final quizId = const Uuid().v4();
      String status = (visibility == 'public') ? 'pending_review' : 'approved';
      final newQuiz = Quiz(
        quizId: quizId,
        creatorId: currentUserId,
        classId: null,
        title: title,
        description: description,
        subject: subject,
        tags: [],
        visibility: visibility,
        status: status,
        timeLimit: timeLimit,
        maxAttempt: maxAttempt,
        randomQuestions: randomQuestions,
        randomAnswers: randomAnswers,
        showAnswer: showAnswer,
        createdAt: DateTime.now(),
        questions: questions,
      );

      await _db.child('quizzes').child(quizId).set(newQuiz.toJson());
      print('Đã tạo quiz thành công: $quizId');
      return null;
    } catch (e) {
      print('Lỗi tạo quiz: $e');
      return 'Lỗi tạo quiz: $e';
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<String?> updateQuiz({
    required String quizId,
    required String title,
    required String description,
    required String subject,
    required String visibility,
    required int timeLimit,
    required int maxAttempt,
    required bool randomQuestions,
    required bool randomAnswers,
    required bool showAnswer,
    required List<Question> questions,
  }) async {
    final currentUserId = ref.read(authProvider).userId;
    if (currentUserId == null) return 'Chưa đăng nhập';
    final quiz = state.quizzes.firstWhere(
      (q) => q.quizId == quizId,
      orElse: () => Quiz(
        quizId: '',
        creatorId: '',
        title: '',
        description: '',
        subject: '',
        visibility: '',
        status: '',
        timeLimit: 0,
        maxAttempt: 0,
        randomQuestions: false,
        randomAnswers: false,
        showAnswer: false,
        createdAt: DateTime.now(),
        tags: [],
        questions: [],
      ),
    );
    if (quiz.quizId.isEmpty) return 'Không tìm thấy Quiz';
    if (quiz.creatorId != currentUserId)
      return 'Bạn không có quyền sửa Quiz này';
    state = state.copyWith(isLoading: true);
    try {
      String status = (visibility == 'public') ? 'pending_review' : 'approved';
      final updatedQuiz = Quiz(
        quizId: quizId,
        creatorId: currentUserId,
        classId: quiz.classId,
        title: title,
        description: description,
        subject: subject,
        tags: quiz.tags,
        visibility: visibility,
        status: status,
        timeLimit: timeLimit,
        maxAttempt: maxAttempt,
        randomQuestions: randomQuestions,
        randomAnswers: randomAnswers,
        showAnswer: showAnswer,
        createdAt: quiz.createdAt,
        questions: questions,
      );
      await _db.child('quizzes').child(quizId).set(updatedQuiz.toJson());
      print('Đã cập nhật quiz: $quizId');
      return null;
    } catch (e) {
      print('Lỗi sửa quiz: $e');
      return 'Lỗi: $e';
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> hideQuiz(String quizId) async {
    final currentUserId = ref.read(authProvider).userId;
    if (currentUserId == null) return;

    final quiz = state.quizzes.firstWhere(
      (q) => q.quizId == quizId,
      orElse: () => Quiz(
        quizId: '',
        creatorId: '',
        title: '',
        description: '',
        subject: '',
        visibility: '',
        status: '',
        timeLimit: 0,
        maxAttempt: 0,
        randomQuestions: false,
        randomAnswers: false,
        showAnswer: false,
        createdAt: DateTime.now(),
        tags: [],
        questions: [],
      ),
    );
    if (quiz.quizId.isEmpty || quiz.creatorId != currentUserId) {
      print('Không có quyền ẩn Quiz này');
      return;
    }
    try {
      await _db.child('quizzes').child(quizId).update({
        'visibility': 'private',
        'status': 'approved',
      });
      print('Đã ẩn quiz: $quizId');
    } catch (e) {
      print('Lỗi ẩn quiz: $e');
    }
  }

  Future<void> toggleVisibility(String quizId) async {
    final currentUserId = ref.read(authProvider).userId;
    final quiz = state.quizzes.firstWhere((q) => q.quizId == quizId);
    if (quiz.creatorId != currentUserId) return;
    String newVisibility = (quiz.visibility == 'public') ? 'private' : 'public';
    String newStatus = (newVisibility == 'public')
        ? 'pending_review'
        : 'approved';
    await _db.child('quizzes').child(quizId).update({
      'visibility': newVisibility,
      'status': newStatus,
    });
  }

  Future<void> assignQuizToClass(String quizId, String classId) async {
    await _db.child('quizzes').child(quizId).update({
      'classId': classId,
      'visibility': 'Class',
      'status': 'approved',
    });
  }
}

final quizProvider = NotifierProvider<QuizNotifier, QuizState>(() {
  return QuizNotifier();
});
