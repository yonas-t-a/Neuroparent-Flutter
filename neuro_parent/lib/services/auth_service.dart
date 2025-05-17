import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../services/exceptions/auth_exceptions.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3500'; // Change to your API base URL

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'token': data['token'], 'user': User.fromJson(data['user'])};
      } else if (response.statusCode == 401) {
        throw InvalidCredentialsException();
      } else {
        throw AuthException(data['error'] ?? 'Login failed');
      }
    } on http.ClientException catch (e) {
      throw AuthException('Network error: ${e.message}');
    }
  }

  Future<User> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      print('Register response: ${response.statusCode} ${response.body}');
      final data = jsonDecode(response.body);

      if ((response.statusCode == 201 || response.statusCode == 200) &&
          data['user'] != null) {
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['error'] ?? 'Registration failed');
      }
    } on http.ClientException catch (e) {
      throw AuthException('Network error: ${e.message}');
    }
  }
}
