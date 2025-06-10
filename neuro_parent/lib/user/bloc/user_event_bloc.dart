import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';
import '../../services/event_service.dart';

// State class for user events
class UserEventState {
  final List<Event> events;
  final bool isLoading;
  final String? error;

  UserEventState({this.events = const [], this.isLoading = false, this.error});

  UserEventState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
  }) {
    return UserEventState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserEventNotifier extends StateNotifier<UserEventState> {
  final EventRepository repository;
  UserEventNotifier(this.repository) : super(UserEventState());

  Future<void> fetchEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await repository.getEvents();
      state = state.copyWith(events: events, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchEventById(int eventId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final event = await repository.getEventById(eventId);
      // Update the list of events, add/replace the fetched event
      final updatedEvents = List<Event>.from(state.events);
      final index = updatedEvents.indexWhere((e) => e.eventId == eventId);
      if (index != -1) {
        updatedEvents[index] = event; // Update existing event
      } else {
        updatedEvents.add(event); // Add new event if not present
      }
      state = state.copyWith(
        events: updatedEvents,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userEventProvider =
    StateNotifierProvider<UserEventNotifier, UserEventState>((ref) {
      final repository = EventRepository(eventService: EventService());
      return UserEventNotifier(repository);
    });
