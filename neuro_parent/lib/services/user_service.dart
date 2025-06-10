import 'package:dio/dio.dart';
import '../models/user.dart';

class UserService {
  static const String baseUrl = 'http://10.0.2.2:3500/api/users';
  final Dio _dio;

  UserService({String? jwtToken})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            if (jwtToken != null) 'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

  Future<User> getUserById(int id) async {
    try {
      final response = await _dio.get('/$id');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch user: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }

  Future<User> updateUser(
    int id, {
    String? name,
    String? email,
    String? password,
    String? oldPassword,
    String? newPassword,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (oldPassword != null) data['oldPassword'] = oldPassword;
      if (newPassword != null) data['newPassword'] = newPassword;

      final response = await _dio.put('/$id', data: data);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to update user: ${e.response?.data['error'] ?? e.message}',
      );
    }
  }
}
