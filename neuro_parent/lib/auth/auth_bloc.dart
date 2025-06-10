import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user.dart';
import '../services/exceptions/auth_exceptions.dart' as service_exceptions;

// States
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthRegistrationSuccess extends AuthState {
  const AuthRegistrationSuccess();
}

class AuthSuccess extends AuthState {
  final User user;
  final String? token;
  AuthSuccess(this.user, {this.token});
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  AuthNotifier(this.authRepository) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final result = await authRepository.login(email, password);
      state = AuthSuccess(result['user'], token: result['token']);
    } catch (e) {
      final errorMessage =
          e is service_exceptions.AuthException
              ? e.message
              : 'Login failed. Please try again.';
      state = AuthFailure(errorMessage);
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    state = AuthLoading();
    try {
      await authRepository.register(name, email, password, role);
      state = const AuthRegistrationSuccess();
    } catch (e) {
      final errorMessage =
          e is service_exceptions.AuthException
              ? e.message
              : 'Registration failed. Please try again.';
      state = AuthFailure(errorMessage);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthRepository());
});
