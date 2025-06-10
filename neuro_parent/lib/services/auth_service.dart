import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/exceptions/auth_exceptions.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:3500';
  final Dio _dio;

  AuthService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'http://10.0.2.2:3500',
              headers: {'Content-Type': 'application/json'},
            ),
          );

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Sending login request to $baseUrl/api/auth/login');
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      print('Response: ${response.data}');
      return {
        'token': response.data['token'],
        'user': User.fromJson(response.data['user']),
      };
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'An unknown error occurred.';
      if (e.response != null) {
        errorMessage =
            'HTTP ${e.response?.statusCode}: ${e.response?.data['error'] ?? e.response?.statusMessage ?? 'Unknown API error'}';
        print(
          'Dio response error: Status Code: ${e.response?.statusCode}, Data: ${e.response?.data}',
        );
      } else {
        print('Dio network error: ${e.error}');
      }
      print('Dio error: $errorMessage');

      if (e.response != null) {
        if (e.response?.statusCode == 401) {
          throw InvalidCredentialsException();
        } else {
          throw AuthException(e.response?.data['error'] ?? 'Login failed');
        }
      } else {
        throw NetworkAuthException(e.message ?? 'Unknown network error');
      }
    }
  }

  Future<User> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      final data = response.data;
      // print('Register response: ${response.statusCode} $data');

      if ((response.statusCode == 201 || response.statusCode == 200) &&
          data['user'] != null) {
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      String errorMessage = e.message ?? 'An unknown error occurred.';
      if (e.response != null) {
        errorMessage =
            'HTTP ${e.response?.statusCode}: ${e.response?.data['error'] ?? e.response?.statusMessage ?? 'Unknown API error'}';
        print(
          'Dio response error: Status Code: ${e.response?.statusCode}, Data: ${e.response?.data}',
        );
      } else {
        print('Dio network error: ${e.error}');
      }
      print('Dio error: $errorMessage');

      if (e.response != null) {
        throw AuthException(e.response?.data['error'] ?? 'Registration failed');
      } else {
        throw NetworkAuthException(e.message ?? 'Unknown network error');
      }
    }
  }
}
