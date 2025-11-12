import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

@immutable
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? userRole;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.userRole,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    String? userRole,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userRole: userRole ?? this.userRole,
    );
  }
}

class AuthProvider extends Notifier<AuthState> {
  final Map<String, Map<String, String>> _fakeUserDb = {
    "student@gmail.com": {"password": "1", "role": "SinhVien"},
    "teacher@gmail.com": {"password": "1", "role": "GiangVien"},
    "mod@gmail.com": {"password": "1", "role": "KiemDuyet"},
    "admin@gmail.com": {"password": "1", "role": "Admin"},
  };
  @override
  AuthState build() {
    return const AuthState(isAuthenticated: false, userRole: null);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1)); // Giả lập mạng
    if (!_fakeUserDb.containsKey(email)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tài khoản không tồn tại',
      );
      return false;
    }
    if (_fakeUserDb[email]!['password'] != password) {
      state = state.copyWith(isLoading: false, errorMessage: 'Sai mật khẩu');
      return false;
    }
    final userRole = _fakeUserDb[email]!['role'];
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      userRole: userRole,
    );
    return true;
  }

  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 1));
    if (_fakeUserDb.containsKey(email)) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Email đã được sử dụng',
      );
      return false;
    }
    // (Thêm user mới vào "Database" giả lập trong bộ nhớ)
    // (Mặc định: Role là "SinhVien")
    _fakeUserDb[email] = {"password": password, "role": "SinhVien"};

    print('Database giả lập đã cập nhật:');
    print(_fakeUserDb);

    state = state.copyWith(isLoading: false);
    return true;
  }

  // 5. HÀM MỚI: ĐĂNG XUẤT
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = const AuthState(isAuthenticated: false, userRole: null);
  }
}

final authProvider = NotifierProvider<AuthProvider, AuthState>(() {
  return AuthProvider();
});
