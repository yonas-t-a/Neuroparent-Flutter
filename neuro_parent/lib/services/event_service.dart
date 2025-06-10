import 'package:dio/dio.dart';
import '../models/event.dart';

class EventService {
  static const String baseUrl = 'http://10.0.2.2:3500/api/events';

  final Dio _dio;

  EventService({String? jwtToken, Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: {
                'Content-Type': 'application/json',
                if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
              },
            ),
          );

  Future<List<Event>> getEvents() async {
    try {
      final response = await _dio.get('/');
      return (response.data as List).map((e) => Event.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  Future<Event> getEventById(int id) async {
    try {
      final response = await _dio.get('/$id');
      return Event.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load event: $e');
    }
  }

  Future<void> createEvent(Event event) async {
    try {
      final response = await _dio.post('/', data: event.toJson());
      if (response.statusCode != 201) {
        throw Exception('Failed to create event: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  Future<void> deleteEvent(int eventId) async {
    try {
      final response = await _dio.delete('/$eventId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete event: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  Future<void> updateEvent(Event event) async {
    if (event.eventId == null) {
      throw Exception('Event ID is required for update');
    }
    try {
      final response = await _dio.put(
        '/${event.eventId}',
        data: event.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update event: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // You can also add getByCategory, getByDate, getByLocation here
}
