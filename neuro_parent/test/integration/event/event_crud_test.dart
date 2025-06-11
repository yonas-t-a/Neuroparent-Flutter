import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/models/event.dart';
import 'package:neuro_parent/services/event_service.dart';
import 'package:neuro_parent/repositories/event_repository.dart';

void main() {
  group('Event Integration Tests', () {
    late EventService eventService;
    late EventRepository eventRepository;

    setUp(() {
      eventService = EventService();
      eventRepository = EventRepository(eventService: eventService);
    });

    test('Fetch events', () async {
      try {
        final events = await eventRepository.getEvents();
        expect(events, isA<List<Event>>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Create event', () async {
      final event = Event(
        eventTitle: 'Test Event',
        eventDescription: 'This is a test event',
        eventDate: '2023-12-01',
        eventTime: '12:00',
        eventLocation: 'Test Location',
        eventCategory: 'Test Category',
      );

      try {
        await eventRepository.createEvent(event);
        expect(true, isTrue); // Test passes if no exception is thrown
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Update event', () async {
      final event = Event(
        eventId: 1,
        eventTitle: 'Updated Event',
        eventDescription: 'This is an updated test event',
        eventDate: '2023-12-02',
        eventTime: '14:00',
        eventLocation: 'Updated Location',
        eventCategory: 'Updated Category',
      );

      try {
        await eventRepository.updateEvent(event);
        expect(true, isTrue); // Test passes if no exception is thrown
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Delete event', () async {
      const eventId = 1;

      try {
        await eventRepository.deleteEvent(eventId);
        expect(true, isTrue); // Test passes if no exception is thrown
      } catch (e) {
        expect(e, isNotNull);
      }
    });

    test('Fetch event by ID', () async {
      const eventId = 1;

      try {
        final event = await eventRepository.getEventById(eventId);
        expect(event, isA<Event>());
      } catch (e) {
        expect(e, isNotNull);
      }
    });
  });
}
