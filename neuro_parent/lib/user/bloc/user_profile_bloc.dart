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
