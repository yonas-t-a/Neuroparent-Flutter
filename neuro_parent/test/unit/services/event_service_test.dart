import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:neuro_parent/models/event.dart';
import 'package:neuro_parent/services/event_service.dart';


class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late EventService eventService;

  setUp(() {
    mockDio = MockDio();
    eventService = EventService(dio: mockDio);

  
    registerFallbackValue(RequestOptions(path: '/'));
  });

  group('EventService', () {
    test('createEvent should send a POST request', () async {
      // Arrange
      when(() => mockDio.post('/', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          statusCode: 201,
          requestOptions: RequestOptions(path: '/'),
        ),
      );

      // Act
      await eventService.createEvent(
        Event(
          eventId: 1,
          eventTitle: 'Event 1',
          eventDescription: 'Description 1',
          eventDate: '2025-06-10',
          eventTime: '10:00 AM',
          eventLocation: 'Location 1',
          eventCategory: 'Category 1',
        ),
      );

      // Assert
      verify(() => mockDio.post('/', data: any(named: 'data'))).called(1);
    });

    test('deleteEvent should send a DELETE request', () async {
      // Arrange
      when(() => mockDio.delete('/1')).thenAnswer(
        (_) async => Response(
          statusCode: 204,
          requestOptions: RequestOptions(path: '/1'),
        ),
      );

      // Act
      await eventService.deleteEvent(1);

      // Assert
      verify(() => mockDio.delete('/1')).called(1);
    });

    test('updateEvent should send a PUT request', () async {
      // Arrange
      when(() => mockDio.put('/1', data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: '/1'),
        ),
      );

      // Act
      await eventService.updateEvent(
        Event(
          eventId: 1,
          eventTitle: 'Updated Event',
          eventDescription: 'Updated Description',
          eventDate: '2025-06-11',
          eventTime: '11:00 AM',
          eventLocation: 'Updated Location',
          eventCategory: 'Updated Category',
        ),
      );

      // Assert
      verify(() => mockDio.put('/1', data: any(named: 'data'))).called(1);
    });
  });
}
