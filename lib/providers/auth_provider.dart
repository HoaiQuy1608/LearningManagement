import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

@immutable
class AuthState {
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.isLoading = false, this.errorMessage});

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 2. "Bộ não" (Notifier)
class AuthProvider extends Notifier<AuthState> {
  // Hàm tạo state ban đầu
  @override
  AuthState build() {
    return const AuthState();
  }

  // 3. Hàm Login (Trả về Future<bool>)
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    await Future.delayed(const Duration(seconds: 2));

    if (email == "test@gmail.com") {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Tài khoản hoặc mật khẩu không đúng',
      );
      return false;
    }
  }

  // 4. Hàm Register (Trả về Future<bool>)
  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(seconds: 2));

    if (email == "test@gmail.com") {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Email đã được sử dụng',
      );
      return false;
    } else {
      state = state.copyWith(isLoading: false);
      return true;
    }
  }
}

// 5. Provider để sử dụng trong UI
final authProvider = NotifierProvider<AuthProvider, AuthState>(() {
  return AuthProvider();
});
