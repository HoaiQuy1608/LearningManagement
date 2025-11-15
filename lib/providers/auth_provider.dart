import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

enum UserRole { sinhVien, giangVien, troGiang, kiemDuyet, admin }

@immutable
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final UserRole? userRole;
  final String? userId;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.userRole,
    this.userId,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    UserRole? userRole,
    String? userId,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userRole: userRole ?? this.userRole,
      userId: userId ?? this.userId,
    );
  }
}

class AuthProvider extends Notifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  @override
  AuthState build() {
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserRole(user.uid);
      } else {
        state = const AuthState(isAuthenticated: false);
      }
    });
    return const AuthState();
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getFirebaseErrorMessage(e),
      );
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _createDefaultUser(credential.user!.uid, email);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getFirebaseErrorMessage(e),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    state = const AuthState(isAuthenticated: false);
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      state = state.copyWith(isLoading: true, errorMessage: null);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getFirebaseErrorMessage(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Loi ket noi. Vui long thu lai.',
      );
      return false;
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu (ít nhất 6 ký tự).';
      case 'email-already-in-use':
        return 'Email đã được sử dụng.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Email hoặc mật khẩu không đúng.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      default:
        return 'Lỗi: ${e.message}';
    }
  }

  Future<void> _loadUserRole(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final snapshot = await _db.child('users').child(uid).get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<Object?, Object?>;
        final user = UserModel.fromMap(uid, data);
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userId: uid,
          userRole: user.role,
        );
      } else {
        await _createDefaultUser(uid, _auth.currentUser!.email!);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải thông tin người dùng: $e',
      );
    }
  }

  Future<void> _createDefaultUser(String uid, String email) async {
    final now = DateTime.now();
    final defaultUser = UserModel(
      uid: uid,
      email: email,
      role: UserRole.sinhVien,
      displayName: email.split('@')[0],
      createdAt: now,
      isActive: true,
      isEmailVerified: false,
    );
    await _db.child('users').child(uid).set(defaultUser.toMap());

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      userId: uid,
      userRole: UserRole.sinhVien,
    );
  }
}

final authProvider = NotifierProvider<AuthProvider, AuthState>(() {
  return AuthProvider();
});
