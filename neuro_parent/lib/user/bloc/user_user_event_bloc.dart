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


class UserUserEventNotifier extends StateNotifier<UserUserEventState> {
  final UserEventRepository userEventRepository;
  final int? userId;

  UserUserEventNotifier({required this.userEventRepository, this.userId})
    : super(UserUserEventState());

  Future<void> fetchRegisteredEvents() async {
    if (userId == null) {
      state = state.copyWith(error: 'User ID not available.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userEvents = await userEventRepository.fetchUserEventsByUserId(
        userId!,
      );
      final registeredIds =
          userEvents.map((ue) => ue.eventId).whereType<int>().toSet();
      state = state.copyWith(
        registeredEventIds: registeredIds,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> registerEvent(int eventId) async {
    if (userId == null) {
      state = state.copyWith(error: 'User ID not available for registration.');
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newUserEvent = await userEventRepository.createUserEvent(
        userId!,
        eventId,
      );
      state = state.copyWith(
        registeredEventIds: Set.from(state.registeredEventIds)..add(eventId),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> unregisterEvent(int eventId) async {
    if (userId == null) {
      state = state.copyWith(
        error: 'User ID not available for unregistration.',
      );
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final allUserEvents = await userEventRepository.fetchUserEventsByUserId(
        userId!,
      ); 
      final userEventToDelete = allUserEvents.firstWhere(
        (ue) => ue.userId == userId && ue.eventId == eventId,
        orElse:
            () => throw Exception('User event not found for unregistration'),
      );

      if (userEventToDelete.userEventId == null) {
        throw Exception('User event ID is null for unregistration');
      }
      await userEventRepository.deleteUserEvent(
        userEventToDelete.userEventId!,
      ); 
      state = state.copyWith(
        registeredEventIds: Set.from(state.registeredEventIds)..remove(eventId),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}


final userUserEventProvider =
    StateNotifierProvider<UserUserEventNotifier, UserUserEventState>((ref) {
      final authState = ref.watch(authProvider);
      int? userId;
      String? token;

      if (authState is AuthSuccess) {
        userId = authState.user.userId;
        token = authState.token;
      }

      final userEventRepository = UserEventRepository(
        userEventService: UserEventService(jwtToken: token),
      );
      return UserUserEventNotifier(
        userEventRepository: userEventRepository,
        userId: userId,
      );
    });
