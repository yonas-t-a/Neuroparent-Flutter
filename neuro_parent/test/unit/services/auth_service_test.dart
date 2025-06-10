import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuro_parent/models/user.dart';
import 'package:neuro_parent/services/exceptions/auth_exceptions.dart';

class MockDio extends Mock implements Dio {}

class MockResponseBody extends Mock implements ResponseBody {}

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
    final user = User.fromJson(userJson);

    test('login returns token and user on successful authentication', () async {
      final response = Response(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        data: {'token': 'test_token', 'user': userJson},
        statusCode: 200,
      );
      when(
        () => mockDio.post('/api/auth/login', data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await authService.login('test@test.com', 'password');

      expect(result['token'], 'test_token');
      expect(result['user'], isA<User>());
      expect((result['user'] as User).email, 'test@example.com');
      verify(
        () => mockDio.post('/api/auth/login', data: any(named: 'data')),
      ).called(1);
    });

    test(
      'login throws InvalidCredentialsException for 401 status code',
      () async {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/api/auth/login'),
            statusCode: 401,
            data: {'error': 'Invalid email or password'},
          ),
          type: DioExceptionType.badResponse,
        );
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(dioError);

        expect(
          () => authService.login('test@test.com', 'wrongpass'),
          throwsA(isA<InvalidCredentialsException>()),
        );
        verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
      },
    );

    test('login throws AuthException for other API errors', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/login'),
          statusCode: 400,
          data: {'error': 'Bad Request'},
        ),
        type: DioExceptionType.badResponse,
      );
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(dioError);

      expect(
        () => authService.login('test@test.com', 'password'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Bad Request',
          ),
        ),
      );
      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });

    test('login throws AuthException for network errors', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        error: 'No internet connection',
        type: DioExceptionType.unknown,
      );
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(dioError);

      expect(
        () => authService.login('test@test.com', 'password'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Network error'),
          ),
        ),
      );
      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });

    test('register returns user on successful registration', () async {
      final userJsonForRegister = {
        'user_id': 1,
        'name': 'New User',
        'email': 'new@example.com',
        'role': 'user',
      };
      final userForRegister = User.fromJson(userJsonForRegister);

      final response = Response(
        requestOptions: RequestOptions(path: '/api/auth/register'),
        data: {'user': userJsonForRegister},
        statusCode: 201,
      );
      when(
        () => mockDio.post('/api/auth/register', data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      final result = await authService.register(
        'New User',
        'new@example.com',
        'password',
        'user',
      );

      expect(result, isA<User>());
      expect(result.email, 'new@example.com');
      verify(
        () => mockDio.post('/api/auth/register', data: any(named: 'data')),
      ).called(1);
    });

    test('register throws AuthException for registration failure', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/auth/register'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/auth/register'),
          statusCode: 409,
          data: {'error': 'Email already in use'},
        ),
        type: DioExceptionType.badResponse,
      );
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(dioError);

      expect(
        () => authService.register(
          'New User',
          'existing@example.com',
          'password',
          'user',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Email already in use',
          ),
        ),
      );
      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });

    test('register throws AuthException for network errors', () async {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/auth/register'),
        error: 'No internet connection',
        type: DioExceptionType.unknown,
      );
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(dioError);

      expect(
        () => authService.register(
          'New User',
          'new@example.com',
          'password',
          'user',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Network error'),
          ),
        ),
      );
      verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
    });
  });
}
