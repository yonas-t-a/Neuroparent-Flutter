import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuro_parent/models/event.dart';
import 'package:neuro_parent/repositories/event_repository.dart';
import 'package:neuro_parent/services/event_service.dart';

class MockEventService extends Mock implements EventService {}

void main() {
  late MockEventService mockEventService;
  late EventRepository eventRepository;

  setUp(() {
    mockEventService = MockEventService();
    eventRepository = EventRepository(eventService: mockEventService);
  });

  group('EventRepository', () {
    final eventJson = {
      'eventId': 1,
      'eventTitle': 'Event 1',
      'eventDescription': 'Description 1',
      'eventDate': '2025-06-10',
      'eventTime': '10:00 AM',
      'eventLocation': 'Location 1',
      'eventCategory': 'Category 1',
    };

    final event = Event(
      eventId: 1,
      eventTitle: 'Event 1',
      eventDescription: 'Description 1',
      eventDate: '2025-06-10',
      eventTime: '10:00 AM',
      eventLocation: 'Location 1',
      eventCategory: 'Category 1',
    );

    test('getEventById should return a single event', () async {
      // Arrange
      when(
        () => mockEventService.getEventById(1),
      ).thenAnswer((_) async => event);

      // Act
      final result = await eventRepository.getEventById(1);

      // Assert
      expect(result, isA<Event>());
      expect(result.eventTitle, 'Event 1');
    });

    test('createEvent should call EventService.createEvent', () async {
      // Arrange
      when(
        () => mockEventService.createEvent(event),
      ).thenAnswer((_) async => Future.value());

      // Act
      await eventRepository.createEvent(event);

      // Assert
      verify(() => mockEventService.createEvent(event)).called(1);
    });

    test('updateEvent should call EventService.updateEvent', () async {
      // Arrange
      when(
        () => mockEventService.updateEvent(event),
      ).thenAnswer((_) async => Future.value());

      // Act
      await eventRepository.updateEvent(event);

      // Assert
      verify(() => mockEventService.updateEvent(event)).called(1);
    });

    test('deleteEvent should call EventService.deleteEvent', () async {
      // Arrange
      when(
        () => mockEventService.deleteEvent(1),
      ).thenAnswer((_) async => Future.value());

      // Act
      await eventRepository.deleteEvent(1);

      // Assert
      verify(() => mockEventService.deleteEvent(1)).called(1);
    });
  });
}
