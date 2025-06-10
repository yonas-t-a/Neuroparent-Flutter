import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuro_parent/models/user.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late AuthService authService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    authService = AuthService(dio: mockDio);
  });

  group('AuthService', () {
    final userJson = {
      'user_id': 1,
      'name': 'Test User',
      'email': 'test@example.com',
      'role': 'user',
    };

    test('login returns token and user on successful authentication', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        data: {'token': 'test_token', 'user': userJson},
        statusCode: 200,
      );
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final result = await authService.login('test@example.com', 'password');

      expect(result['token'], 'test_token');
      expect(result['user'], isA<User>());
    });

    test('register returns user on successful registration', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/api/auth/register'),
        data: {'user': userJson},
        statusCode: 201,
      );
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final result = await authService.register(
        'Test User',
        'test@example.com',
        'password',
        'user',
      );

      expect(result.email, 'test@example.com');
    });
  });
}