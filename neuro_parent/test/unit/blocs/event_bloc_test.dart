import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuro_parent/models/event.dart';
import 'package:neuro_parent/repositories/event_repository.dart';
import 'package:neuro_parent/admin/bloc/event_bloc.dart';

class MockEventRepository extends Mock implements EventRepository {}

void main() {
  late MockEventRepository mockEventRepository;
  late EventNotifier eventNotifier;

  setUp(() {
    mockEventRepository = MockEventRepository();
    eventNotifier = EventNotifier(mockEventRepository);
  });

  group('EventBloc', () {
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

      when(
        () => mockEventRepository.getEvents(),
      ).thenAnswer((_) async => [event]);


      await eventNotifier.fetchEvents();


      expect(eventNotifier.state.events, [event]);
      expect(eventNotifier.state.isLoading, false);
      expect(eventNotifier.state.error, isNull);
    });

    test('createEvent updates state and fetches events', () async {

      when(
        () => mockEventRepository.createEvent(event),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockEventRepository.getEvents(),
      ).thenAnswer((_) async => [event]);


      await eventNotifier.createEvent(event);


      expect(eventNotifier.state.isCreating, false);
      expect(eventNotifier.state.events, [event]);
      expect(eventNotifier.state.error, isNull);
    });

    test('deleteEvent updates state and fetches events', () async {

      when(
        () => mockEventRepository.deleteEvent(1),
      ).thenAnswer((_) async => Future.value());
      when(() => mockEventRepository.getEvents()).thenAnswer((_) async => []);


      await eventNotifier.deleteEvent(1);


      expect(eventNotifier.state.isDeleting, false);
      expect(eventNotifier.state.events, isEmpty);
      expect(eventNotifier.state.error, isNull);
    });
  });
}
