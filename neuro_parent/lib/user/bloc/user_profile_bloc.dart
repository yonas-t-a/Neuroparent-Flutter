import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';
import '../../services/user_service.dart';
import '../../auth/auth_bloc.dart';


class UserProfileState {
  final User? user; 
  final bool isLoading;
  final String? error;

  UserProfileState({this.user, this.isLoading = false, this.error});

  UserProfileState copyWith({User? user, bool? isLoading, String? error}) {
    return UserProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error, 
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final UserRepository userRepository;
  final int? userId;
  final String? jwtToken;

  UserProfileNotifier({
    required this.userRepository,
    this.userId,
    this.jwtToken,
  }) : super(UserProfileState());

  Future<void> fetchUser() async {
    if (userId == null || jwtToken == null) {
      state = state.copyWith(error: 'User ID or JWT token not available.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final fetchedUser = await userRepository.getUserById(userId!);
      state = state.copyWith(user: fetchedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUser({
    String? name,
    String? email,
    String? password,
    String? oldPassword,
    String? newPassword,
  }) async {
    if (userId == null || jwtToken == null) {
      state = state.copyWith(error: 'User ID or JWT token not available.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await userRepository.updateUser(
        userId!,
        name: name,
        email: email,
        password: password,
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}