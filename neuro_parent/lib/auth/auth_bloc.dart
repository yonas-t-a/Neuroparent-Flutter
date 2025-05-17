import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';
import '../models/user.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  RegisterRequested(this.name, this.email, this.password, this.role);
}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  final String? token;
  AuthSuccess(this.user, {this.token});

  @override
  List<Object?> get props => [user, token];
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<LoginRequested>(_handleLogin);
    on<RegisterRequested>(_handleRegister);
  }

  Future<void> _handleLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.login(event.email, event.password);
      emit(AuthSuccess(result['user'], token: result['token']));
    } catch (e) {
      // Improved error handling
      final errorMessage =
          e is AuthException ? e.message : 'Login failed. Please try again.';
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _handleRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.register(
        event.name,
        event.email,
        event.password,
        event.role,
      );
      emit(AuthSuccess(user));
    } catch (e) {
      // Improved error handling
      final errorMessage =
          e is AuthException
              ? e.message
              : 'Registration failed. Please try again.';
      emit(AuthFailure(errorMessage));
    }
  }
}

// Add this custom exception class
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password');
}
