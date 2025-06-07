import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';
import '../../services/event_service.dart';

// State class for events
class EventState {
  final List<Event> events;
  final bool isLoading;
  final String? error;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final int? deletingEventId;

  EventState({
    this.events = const [],
    this.isLoading = false,
    this.error,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.deletingEventId,
  });

  EventState copyWith({
    List<Event>? events,
    bool? isLoading,
    String? error,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    int? deletingEventId,
  }) {
    return EventState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      deletingEventId: deletingEventId,
    );
  }
}

class EventNotifier extends StateNotifier<EventState> {
  final EventRepository repository;
  EventNotifier(this.repository) : super(EventState());

  Future<void> fetchEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await repository.getEvents();
      state = state.copyWith(events: events, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createEvent(Event event) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      await repository.createEvent(event);
      await fetchEvents();
      state = state.copyWith(isCreating: false);
    } catch (e) {
      state = state.copyWith(isCreating: false, error: e.toString());
    }
  }

  Future<void> updateEvent(Event event) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await repository.updateEvent(event);
      await fetchEvents();
      state = state.copyWith(isUpdating: false);
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
    }
  }

  Future<void> deleteEvent(int eventId) async {
    state = state.copyWith(
      isDeleting: true,
      deletingEventId: eventId,
      error: null,
    );
    try {
      await repository.deleteEvent(eventId);
      await fetchEvents();
      state = state.copyWith(isDeleting: false, deletingEventId: null);
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        deletingEventId: null,
        error: e.toString(),
      );
    }
  }
}

final eventProvider = StateNotifierProvider<EventNotifier, EventState>((ref) {
  // You may want to inject the repository differently depending on your app structure
  final repository = EventRepository(eventService: EventService());
  return EventNotifier(repository);
});
