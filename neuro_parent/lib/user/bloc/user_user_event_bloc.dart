import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/user_event_repository.dart';
import '../../auth/auth_bloc.dart';
import '../../services/user_event_service.dart';


class UserUserEventState {
  final Set<int>
  registeredEventIds; 
  final bool isLoading;
  final String? error;

  UserUserEventState({
    this.registeredEventIds = const {},
    this.isLoading = false,
    this.error,
  });

  UserUserEventState copyWith({
    Set<int>? registeredEventIds,
    bool? isLoading,
    String? error,
  }) {
    return UserUserEventState(
      registeredEventIds: registeredEventIds ?? this.registeredEventIds,
      isLoading: isLoading ?? this.isLoading,
      error: error, 
    );
  }
}





