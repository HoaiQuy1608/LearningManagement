import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

@immutable
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthProvider extends Notifier<AuthState> {
  @override
  AuthState build() {
    // TODO: (Sau này) Kiểm tra "bộ nhớ" (secure storage)
    // xem người dùng đã đăng nhập từ lần trước chưa
    return const AuthState(isAuthenticated: false);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 2));

    if (email == "test@gmail.com") {
      // SỬA: Báo là đã ĐĂNG NHẬP THÀNH CÔNG
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tài khoản hoặc mật khẩu không đúng',
        isAuthenticated: false,
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 2));

    if (email == "test@gmail.com") {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Email đã được sử dụng',
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  // 5. HÀM MỚI: ĐĂNG XUẤT
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false, isAuthenticated: false);
  }
}

final authProvider = NotifierProvider<AuthProvider, AuthState>(() {
  return AuthProvider();
});
