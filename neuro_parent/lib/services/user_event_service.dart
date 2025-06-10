import 'package:dio/dio.dart';
import '../models/user_event.dart';

class UserEventService {
  static const String baseUrl = 'http://10.0.2.2:3500/api/userEvents';
  final Dio _dio;

  UserEventService({String? jwtToken})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

  Future<UserEvent> createUserEvent(int userId, int eventId) async {
    try {
      final response = await _dio.post(
        '/',
        data: {'user_id': userId, 'event_id': eventId},
      );
      return UserEvent.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to register for event: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<void> deleteUserEvent(int userEventId) async {
    try {
      await _dio.delete('/$userEventId');
    } on DioException catch (e) {
      throw Exception(
        'Failed to unregister from event: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<List<UserEvent>> fetchUserEventsByUserId(int userId) async {
    try {
      final response = await _dio.get(
        '/',
      ); // Assuming the API returns all user events and we filter by userId if needed, or backend handles the filter
      // The backend getUserEvent currently returns all. If the backend needs to filter by userId,
      // the route or controller needs modification, e.g., '/user/$userId' or a query param.
      // For now, assuming backend returns all and we filter, or the backend handles filtering.
      // Based on back-end/controller/userEventController.js, getUserEvent returns all.
      // So, we will get all and filter in the repository/bloc if necessary,
      // or adjust the backend if the volume is too large.
      final List<dynamic> data = response.data;
      return data.map((json) => UserEvent.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch user events: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }
}
