import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuro_parent/models/event.dart';
import 'package:neuro_parent/repositories/event_repository.dart';
import 'package:neuro_parent/user/bloc/user_event_bloc.dart';

class MockEventRepository extends Mock implements EventRepository {}

void main() {
  late MockEventRepository mockEventRepository;
  late UserEventNotifier userEventNotifier;

  setUp(() {
    mockEventRepository = MockEventRepository();
    userEventNotifier = UserEventNotifier(mockEventRepository);
  });

  group('UserEventBloc', () {
    final event = Event(
      eventId: 1,
      eventTitle: 'Event 1',
      eventDescription: 'Description 1',
      eventDate: '2025-06-10',
      eventTime: '10:00 AM',
      eventLocation: 'Location 1',
      eventCategory: 'Category 1',
    );

    test('fetchEvents updates state with events', () async {
      // Arrange
      when(() => mockEventRepository.getEvents()).thenAnswer(
        (_) async => [event],
      );

      // Act
      await userEventNotifier.fetchEvents();

      // Assert
      expect(userEventNotifier.state.events, [event]);
      expect(userEventNotifier.state.isLoading, false);
      expect(userEventNotifier.state.error, isNull);
    });

    test('fetchEvents updates state with error on failure', () async {
      // Arrange
      when(() => mockEventRepository.getEvents()).thenThrow(Exception('Failed to fetch events'));

      // Act
      await userEventNotifier.fetchEvents();

      // Assert
      expect(userEventNotifier.state.events, isEmpty);
      expect(userEventNotifier.state.isLoading, false);
      expect(userEventNotifier.state.error, 'Exception: Failed to fetch events');
    });
  });
}