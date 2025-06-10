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



